// last_verified: 2026-09-18 · prom n/a
// rules-evaluator.go — tiny Prometheus-style rules evaluator with Go template expansion.
//
// Purpose: read a rules file (recording + alerting rules) and a samples file,
// evaluate each rule against the samples, and print what each rule produces.
// Annotation values are expanded with text/template using .Labels and .Value,
// the same idea Prometheus uses for alert annotations.
//
// Steps:
//  1. Write a rules file (see the example below) and a samples JSON file.
//  2. Run: go run rules-evaluator.go --rules rules.yaml --samples samples.json
//  3. Read the per-rule output: recorded values for `record` rules,
//     FIRING/OK plus expanded annotations for `alert` rules.
//
// Verify: run with the example files and check the printed lines match the
// sample values (e.g. cpu_usage above the threshold fires, below it stays OK).
// A non-zero exit means the rules file or samples file could not be read or
// an expression could not be evaluated; the error is printed to stderr.
//
// Example rules.yaml:
//   groups:
//     - name: demo
//       rules:
//         - record: job:cpu_usage:high
//           expr: cpu_usage > 0.8
//           labels:
//             team: backend
//         - alert: CpuUsageHigh
//           expr: cpu_usage > 0.8
//           labels:
//             severity: warning
//             instance: web-1
//           annotations:
//             summary: "CPU high on {{ .Labels.instance }} (value {{ .Value }})"
//
// Example samples.json:
//   {"cpu_usage": 0.95}
package main

import (
	"bufio"
	"encoding/json"
	"flag"
	"fmt"
	"os"
	"regexp"
	"strconv"
	"strings"
	"text/template"
)

// Rule is one recording or alerting rule parsed from the rules file.
type Rule struct {
	Kind        string // "record" or "alert"
	Name        string // record name or alert name
	Expr        string
	Labels      map[string]string
	Annotations map[string]string
}

// TemplateData is what annotation templates are rendered against.
type TemplateData struct {
	Labels map[string]string
	Value  float64
}

var exprRe = regexp.MustCompile(`^([a-zA-Z_:][a-zA-Z0-9_:]*)\s*(>=|<=|==|!=|>|<)\s*([0-9]*\.?[0-9]+)\s*$`)
var bareRe = regexp.MustCompile(`^([a-zA-Z_:][a-zA-Z0-9_:]*)\s*$`)

func main() {
	rulesPath := flag.String("rules", "", "path to rules file (YAML subset)")
	samplesPath := flag.String("samples", "", "path to samples JSON file (metric -> number)")
	flag.Parse()

	if *rulesPath == "" || *samplesPath == "" {
		fmt.Fprintln(os.Stderr, "usage: rules-evaluator --rules rules.yaml --samples samples.json")
		os.Exit(2)
	}

	rules, err := loadRules(*rulesPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error reading rules: %v\n", err)
		os.Exit(1)
	}

	samples, err := loadSamples(*samplesPath)
	if err != nil {
		fmt.Fprintf(os.Stderr, "error reading samples: %v\n", err)
		os.Exit(1)
	}

	failed := false
	for _, r := range rules {
		value, firing, err := evalExpr(r.Expr, samples)
		if err != nil {
			fmt.Fprintf(os.Stderr, "rule %q: %v\n", r.Name, err)
			failed = true
			continue
		}
		if r.Kind == "record" {
			fmt.Printf("record %s = %g\n", r.Name, value)
			continue
		}
		if firing {
			fmt.Printf("ALERT %s FIRING (value %g)\n", r.Name, value)
			data := TemplateData{Labels: r.Labels, Value: value}
			for k, tmplText := range r.Annotations {
				out, err := renderTemplate(tmplText, data)
				if err != nil {
					fmt.Fprintf(os.Stderr, "rule %q annotation %q: %v\n", r.Name, k, err)
					failed = true
					continue
				}
				fmt.Printf("  %s: %s\n", k, out)
			}
		} else {
			fmt.Printf("ALERT %s OK (value %g)\n", r.Name, value)
		}
	}
	if failed {
		os.Exit(1)
	}
}

// loadSamples reads a JSON object mapping metric names to numbers.
func loadSamples(path string) (map[string]float64, error) {
	raw, err := os.ReadFile(path)
	if err != nil {
		return nil, err
	}
	var samples map[string]float64
	if err := json.Unmarshal(raw, &samples); err != nil {
		return nil, fmt.Errorf("samples file must be JSON like {\"cpu_usage\": 0.9}: %w", err)
	}
	return samples, nil
}

// evalExpr evaluates "metric OP number" or a bare "metric".
// It returns the metric value and whether a comparison holds.
func evalExpr(expr string, samples map[string]float64) (float64, bool, error) {
	expr = strings.TrimSpace(expr)
	if m := exprRe.FindStringSubmatch(expr); m != nil {
		val, ok := samples[m[1]]
		if !ok {
			return 0, false, fmt.Errorf("unknown metric %q in expr %q", m[1], expr)
		}
		threshold, _ := strconv.ParseFloat(m[3], 64)
		var firing bool
		switch m[2] {
		case ">":
			firing = val > threshold
		case "<":
			firing = val < threshold
		case ">=":
			firing = val >= threshold
		case "<=":
			firing = val <= threshold
		case "==":
			firing = val == threshold
		case "!=":
			firing = val != threshold
		}
		return val, firing, nil
	}
	if m := bareRe.FindStringSubmatch(expr); m != nil {
		val, ok := samples[m[1]]
		if !ok {
			return 0, false, fmt.Errorf("unknown metric %q in expr %q", m[1], expr)
		}
		return val, val != 0, nil
	}
	return 0, false, fmt.Errorf("unsupported expr %q (want \"metric > number\" or \"metric\")", expr)
}

// renderTemplate expands one annotation value with .Labels and .Value.
func renderTemplate(text string, data TemplateData) (string, error) {
	tmpl, err := template.New("annotation").Parse(text)
	if err != nil {
		return "", err
	}
	var sb strings.Builder
	if err := tmpl.Execute(&sb, data); err != nil {
		return "", err
	}
	return sb.String(), nil
}

// loadRules parses the small YAML subset used in the example above.
// It understands "- record:" / "- alert:", "expr:", and nested
// "labels:" / "annotations:" maps with "key: value" entries.
func loadRules(path string) ([]Rule, error) {
	f, err := os.Open(path)
	if err != nil {
		return nil, err
	}
	defer f.Close()

	var rules []Rule
	var cur *Rule
	section := "" // "", "labels", "annotations"

	flush := func() {
		if cur != nil {
			if cur.Labels == nil {
				cur.Labels = map[string]string{}
			}
			if cur.Annotations == nil {
				cur.Annotations = map[string]string{}
			}
			rules = append(rules, *cur)
			cur = nil
		}
	}

	sc := bufio.NewScanner(f)
	sc.Buffer(make([]byte, 64*1024), 1024*1024)
	for sc.Scan() {
		line := sc.Text()
		trimmed := strings.TrimSpace(line)
		if trimmed == "" || strings.HasPrefix(trimmed, "#") {
			continue
		}
		indent := len(line) - len(strings.TrimLeft(line, " "))
		// A new rule starts a "- record:" or "- alert:" entry.
		if strings.HasPrefix(trimmed, "- record:") || strings.HasPrefix(trimmed, "- alert:") {
			flush()
			kind := "record"
			name := strings.TrimSpace(strings.TrimPrefix(trimmed, "- record:"))
			if strings.HasPrefix(trimmed, "- alert:") {
				kind = "alert"
				name = strings.TrimSpace(strings.TrimPrefix(trimmed, "- alert:"))
			}
			cur = &Rule{Kind: kind, Name: unquote(name), Labels: map[string]string{}, Annotations: map[string]string{}}
			section = ""
			continue
		}
		if cur == nil {
			continue // group headers and other lines carry no rule data
		}
		if indent <= 8 {
			section = ""
		}
		switch {
		case strings.HasPrefix(trimmed, "expr:"):
			cur.Expr = unquote(strings.TrimSpace(strings.TrimPrefix(trimmed, "expr:")))
			section = ""
		case trimmed == "labels:":
			section = "labels"
		case trimmed == "annotations:":
			section = "annotations"
		default:
			if idx := strings.Index(trimmed, ":"); idx > 0 && (section == "labels" || section == "annotations") {
				k := strings.TrimSpace(trimmed[:idx])
				v := unquote(strings.TrimSpace(trimmed[idx+1:]))
				if section == "labels" {
					cur.Labels[k] = v
				} else {
					cur.Annotations[k] = v
				}
			}
		}
	}
	if err := sc.Err(); err != nil {
		return nil, err
	}
	flush()
	if len(rules) == 0 {
		return nil, fmt.Errorf("no rules found (want '- record:' or '- alert:' entries)")
	}
	for _, r := range rules {
		if r.Expr == "" {
			return nil, fmt.Errorf("rule %q has no expr", r.Name)
		}
	}
	return rules, nil
}

// unquote strips one layer of matching single or double quotes.
func unquote(s string) string {
	s = strings.TrimSpace(s)
	if len(s) >= 2 {
		if (s[0] == '"' && s[len(s)-1] == '"') || (s[0] == '\'' && s[len(s)-1] == '\'') {
			return s[1 : len(s)-1]
		}
	}
	return s
}
