---
name: rtl-persian-pdf
description: Generate production-grade Persian RTL PDFs from Markdown or HTML with reliable shaping, bidi safety, and deterministic print output. Use when the user asks for Persian PDF export, RTL rendering, right-aligned typography, Arabic/Persian text shaping, or portable PDF generation across environments.
disable-model-invocation: true
---

# RTL Persian PDF

## Purpose

Orchestrate a deterministic Persian RTL PDF pipeline from user request to verified artifact.

## Single Responsibility Contract

This file handles orchestration only:

- decide the pipeline path
- enforce validation gates
- report output contract

Detailed implementation (HTML baseline, commands, fallback internals, troubleshooting) lives in `reference.md`.

## Inputs

- source path (`.md` or `.html`)
- output path (`.pdf`)
- optional page settings (default `A4`, margin `14mm`)
- optional style intent (default formal and minimal)

## Outputs

- generated PDF path
- renderer used (primary or fallback)
- fonts used
- validation status and residual risks

## Core Workflow

1. Confirm input/output contract.
1. Choose route:
   - HTML input -> normalize and render
   - Markdown input -> convert then render
1. Use primary renderer first (Chromium).
1. Run validation gates.
1. If validation fails, apply controlled fallback path.
1. Return output contract.

## Validation Gates (Mandatory)

- PDF exists and is non-empty
- `pdfinfo` passes and metadata is sane
- first-page visual spot-check completed
- mixed Persian/Latin bidi is visually acceptable

## Guardrails

- Do not skip validation gates.
- Do not silently change page size, margin, or font stack.
- Do not rely on unverifiable claims about output quality.
- Prefer local explicit fonts over system-dependent defaults.

## Additional Resources

- For command recipes and templates, see `reference.md`.
