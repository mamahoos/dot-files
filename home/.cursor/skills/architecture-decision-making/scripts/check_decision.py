#!/usr/bin/env python3
"""Validate an architecture Decision packet has the required headings."""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path

FULL_HEADINGS = (
    "Hand",
    "Problem",
    "Constraints",
    "Requirements",
    "Options",
    "Trade-offs",
    "Failure modes",
    "Operational cost",
    "Decision",
)

SHORT_HEADINGS = (
    "Hand",
    "Problem",
    "Options",
    "Decision",
)

HEADING_RE = re.compile(r"^##\s+(.*\S)\s*$")


def parse_headings(text: str) -> list[str]:
    found: list[str] = []
    for line in text.splitlines():
        match = HEADING_RE.match(line)
        if match:
            found.append(match.group(1).strip())
    return found


def missing(required: tuple[str, ...], found: list[str]) -> list[str]:
    found_set = {h.casefold() for h in found}
    return [h for h in required if h.casefold() not in found_set]


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("path", type=Path, help="Decision markdown file")
    parser.add_argument(
        "--short",
        action="store_true",
        help="Two-way door: only Hand, Problem, Options, Decision",
    )
    args = parser.parse_args()
    path: Path = args.path
    if not path.is_file():
        print(f"not a file: {path}", file=sys.stderr)
        return 2
    required = SHORT_HEADINGS if args.short else FULL_HEADINGS
    absent = missing(required, parse_headings(path.read_text(encoding="utf-8")))
    if absent:
        print(f"missing headings in {path}: {', '.join(absent)}", file=sys.stderr)
        return 1
    print("OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
