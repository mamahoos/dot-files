#!/usr/bin/env python3
"""Smoke-test check_decision.py against the template and a too-short packet."""

from __future__ import annotations

import subprocess
import sys
import tempfile
from pathlib import Path

SCRIPT = Path(__file__).resolve().parent / "check_decision.py"
TEMPLATE = Path(__file__).resolve().parent.parent / "templates" / "decision.md"


def run(*args: str) -> subprocess.CompletedProcess[str]:
    return subprocess.run(
        [sys.executable, str(SCRIPT), *args],
        capture_output=True,
        text=True,
        check=False,
    )


def main() -> int:
    passed = run(str(TEMPLATE))
    if passed.returncode != 0:
        print(passed.stderr, file=sys.stderr)
        return 1
    with tempfile.NamedTemporaryFile("w", suffix=".md", delete=False, encoding="utf-8") as handle:
        handle.write("# Decision: TITLE\n\n## Hand\n\n## Problem\n\n## Options\n")
        short_path = handle.name
    failed = run("--short", short_path)
    if failed.returncode != 1:
        print("expected exit 1 when ## Decision is missing", file=sys.stderr)
        return 1
    print("OK")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
