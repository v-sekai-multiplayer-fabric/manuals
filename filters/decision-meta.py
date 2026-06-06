#!/usr/bin/env python3
"""Show a decision's tier and status (from YAML frontmatter) at the top of the page.

Frontmatter stays the single source of truth: the decisions index lists tier and
status as columns, and this puts them on each page, so authors never repeat them in
the body. A ``superseded by <file>.md`` status renders as a link to that decision.
"""
import re

from panflute import Link, Para, Space, Str, Strong, run_filter

_SUPERSEDED = re.compile(r"^superseded by\s+(\S+)\.md\s*$", re.IGNORECASE)


def _status_inlines(status):
    match = _SUPERSEDED.match(status)
    if match:
        stem = match.group(1)
        return [Str("superseded by"), Space(), Link(Str(stem), url=stem + ".html")]
    return [Str(status)]


def action(elem, doc):
    return None


def finalize(doc):
    inlines = []

    def add(label, parts):
        if inlines:
            inlines.extend([Space(), Str("·"), Space()])
        inlines.append(Strong(Str(label + ":")))
        inlines.append(Space())
        inlines.extend(parts)

    tier = doc.get_metadata("tier")
    status = doc.get_metadata("status")
    if tier:
        add("Tier", [Str(str(tier))])
    if status:
        add("Status", _status_inlines(str(status)))
    if inlines:
        doc.content.insert(0, Para(*inlines))


def main(doc=None):
    return run_filter(action, finalize=finalize, doc=doc)


if __name__ == "__main__":
    main()
