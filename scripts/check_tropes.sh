#!/usr/bin/env bash
# Static, no-LLM tropes check enforcing https://tropes.fyi/ house style.
# It flags negative-parallelism phrasing ("not X, but/it's Y" and the em-dash
# reframe), the single most common AI writing tell. Each pattern requires both
# halves of the parallelism so ordinary "is not X" prose does not trip it.
set -uo pipefail

mapfile -t files < <(git ls-files '*.md' '*.qmd')
[ "${#files[@]}" -eq 0 ] && { echo "tropes check: no markdown files"; exit 0; }

patterns=(
  "(it'?s|that'?s|this is|here'?s)[[:space:]]+not[[:space:]]+[^.!?]{1,80}[[:space:]]it'?s[[:space:]]"
  "\bnot[[:space:]]+(just|only|merely|simply)[[:space:]]+[^.!?]{1,80}[[:space:]](but|rather)\b"
  "\bnot[[:space:]]+because[[:space:]]+[^.!?]{1,80}[[:space:]]but\b"
  "\bthe[[:space:]]+(question|point|issue|goal|problem)[[:space:]]+isn'?t\b"
  "\bnot[[:space:]]+[^.!?—]{1,80}—[[:space:]]*(it'?s|but|rather)\b"
)

found=0
for f in "${files[@]}"; do
  for p in "${patterns[@]}"; do
    while IFS= read -r line; do
      echo "tropes: $f:$line"
      found=1
    done < <(grep -nEi "$p" "$f" 2>/dev/null)
  done
done

if [ "$found" -ne 0 ]; then
  echo
  echo "Negative-parallelism / AI-tell phrasing found (see https://tropes.fyi/)."
  echo "Rewrite as a plain declarative statement."
  exit 1
fi
echo "tropes check: clean (${#files[@]} files)"
