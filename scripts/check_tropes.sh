#!/usr/bin/env bash
# Static, no-LLM tropes check enforcing https://tropes.fyi/ house style.
# Two rules:
#   1. Negative parallelism ("not X, but/it's Y" and the em-dash reframe), the
#      single most common AI writing tell. Each pattern requires both halves of
#      the parallelism so ordinary "is not X" prose does not trip it.
#   2. Bold lead-in list items ("- **Term:** explanation" / "1. **Term.** text"),
#      a bullet that opens with a bolded label then a colon or period.
set -uo pipefail

mapfile -t files < <(git ls-files '*.md' '*.qmd')
[ "${#files[@]}" -eq 0 ] && { echo "tropes check: no markdown files"; exit 0; }

parallelism=(
  "(it'?s|that'?s|this is|here'?s)[[:space:]]+not[[:space:]]+[^.!?]{1,80}[[:space:]]it'?s[[:space:]]"
  "\bnot[[:space:]]+(just|only|merely|simply)[[:space:]]+[^.!?]{1,80}[[:space:]](but|rather)\b"
  "\bnot[[:space:]]+because[[:space:]]+[^.!?]{1,80}[[:space:]]but\b"
  "\bthe[[:space:]]+(question|point|issue|goal|problem)[[:space:]]+isn'?t\b"
  "\bnot[[:space:]]+[^.!?—]{1,80}—[[:space:]]*(it'?s|but|rather)\b"
)
# Catch the colon/period both inside the bold ("**Term:**") and after it ("**Term**:").
bold_list=(
  '^[[:space:]]*([-*+]|[0-9]+\.)[[:space:]]+\*\*[^*]+\*\*[[:space:]]*[:.]'
  '^[[:space:]]*([-*+]|[0-9]+\.)[[:space:]]+\*\*[^*]*[:.]\*\*'
)

found=0
for f in "${files[@]}"; do
  for p in "${parallelism[@]}"; do
    while IFS= read -r line; do
      echo "tropes(parallelism): $f:$line"
      found=1
    done < <(grep -nEi "$p" "$f" 2>/dev/null)
  done
  for p in "${bold_list[@]}"; do
    while IFS= read -r line; do
      echo "tropes(bold-list): $f:$line"
      found=1
    done < <(grep -nE "$p" "$f" 2>/dev/null)
  done
done

if [ "$found" -ne 0 ]; then
  echo
  echo "AI-tell phrasing found (see https://tropes.fyi/)."
  echo "  parallelism: rewrite \"not X, but/it's Y\" as a plain declarative statement."
  echo "  bold-list:   drop the bold lead-in; write the list item as a sentence."
  exit 1
fi
echo "tropes check: clean (${#files[@]} files)"
