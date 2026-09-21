---
last_verified: 2026-09-21
tool_version: n/a
---

# Figuring out Helm values merges (--set vs -f)

I already had the basic quickstart flow working (`helm create`, `install`, `upgrade`), so today I wanted to answer a narrower question: when I pass values three different ways, which one actually wins? I kept guessing wrong, so I tried it on a scratch chart and watched what came out with `helm template`.

## What I was trying to learn

My chart's `values.yaml` had something like:

```yaml
replicaCount: 1
image:
  tag: "stable"
service:
  port: 80
```

I wanted to know the order when I combine the chart default, an extra values file with `-f`, and a `--set` flag on the command line. The suggestion in my earlier note was to try exactly this, so this is the follow-up.

## Steps I ran

First I scaffolded a throwaway chart and rendered it untouched, just to have a baseline:

```bash
helm create merge-demo
helm template my-release ./merge-demo
```

Then I wrote a small override file, `my-values.yaml`, next to the chart:

```yaml
replicaCount: 2
image:
  tag: "from-file"
```

and rendered with it:

```bash
helm template my-release ./merge-demo -f my-values.yaml
```

The replica count flipped to 2 and the image tag flipped to `from-file`, which matched what I expected — the `-f` file beats the chart's built-in `values.yaml`.

Then I layered `--set` on top:

```bash
helm template my-release ./merge-demo -f my-values.yaml --set image.tag=from-flag
```

The tag came out as `from-flag` while `replicaCount` stayed at 2. So the order I observed is: chart default < `-f` file < `--set` flag, with the rightmost `--set` winning. I ran it once more with two `--set` flags for the same key and the last one on the line won, which fits the same "last writer wins" idea.

I also tried two `-f` files at once:

```bash
helm template my-release ./merge-demo -f base.yaml -f override.yaml
```

and the second file won for keys they both set. Same pattern.

## Got stuck on

The thing that tripped me up was `helm template --debug`. I assumed `--debug` would print the merged values table. It doesn't — it renders the manifests and adds the computed template output details, so I still couldn't *see* the merge itself. What finally made it click was rendering twice with only one thing changed each time and diffing the output by eye, instead of trying to get Helm to explain the merge directly.

Second snag: I edited `my-values.yaml` and re-ran `helm template`, and nothing changed — because I had a typo in the filename and Helm was reading a stale `my-values.yaml` from a different directory. Running `helm template` with a relative `-f` path picks up whatever is in the current directory, and I was in the wrong one. Once I passed the explicit path it behaved.

Third small thing: `--set service.port=8080` sets a number-looking value as a string in some charts, which surprised me when the rendered manifest quoted it. Using a values file kept the type as I wrote it in YAML, so for anything type-sensitive I now prefer `-f` and keep `--set` for quick one-off string tweaks.

## What I'd try next

Next I want to try this for real with `helm upgrade --install` using one checked-in values file per environment plus a `--set image.tag=...` from the pipeline for the built tag. That keeps the file as the readable record and the flag as the per-run override. I also want to look at how `required` and `default` template functions interact with missing values, since that's the next place I expect to get bitten.
