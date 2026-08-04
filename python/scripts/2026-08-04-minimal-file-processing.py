# last_verified: 2026-08-04 · Python n/a

# minimal-file-processing.py — read a file, count lines/words, write summary
# Doing this as a script because the tutorial's functions chapter showed
# how to structure logic into reusable blocks, and a file-processing task
# is the simplest way to practice that pattern.

import sys
import os


def count_lines_and_words(path):
    """Read a text file and return the line and word counts."""
    line_count = 0
    word_count = 0
    with open(path, "r", encoding="utf-8") as f:
        for line in f:
            line_count += 1
            word_count += len(line.split())
    return line_count, word_count


def write_summary(path, lines, words, out_dir):
    """Write a one-line summary to a new file in the output directory."""
    os.makedirs(out_dir, exist_ok=True)
    out_path = os.path.join(out_dir, os.path.basename(path) + ".summary")
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(f"{path}: {lines} lines, {words} words\n")
    return out_path


def main():
    if len(sys.argv) < 2:
        print("Usage: python minimal-file-processing.py <file1> [file2 ...]")
        sys.exit(1)

    out_dir = "summaries"
    for filepath in sys.argv[1:]:
        if not os.path.isfile(filepath):
            print(f"Skipping {filepath}: not a file")
            continue
        lines, words = count_lines_and_words(filepath)
        summary_path = write_summary(filepath, lines, words, out_dir)
        print(f"Wrote summary to {summary_path}")


if __name__ == "__main__":
    main()