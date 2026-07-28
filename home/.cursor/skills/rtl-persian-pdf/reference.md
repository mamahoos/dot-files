# Reference: RTL Persian PDF

This reference contains implementation details used by `SKILL.md`.

## HTML Baseline Template

```html
<!doctype html>
<html lang="fa" dir="rtl">
<head>
  <meta charset="utf-8" />
  <style>
    @font-face {
      font-family: "Vazirmatn";
      src: url("pdf-assets/fonts/Vazirmatn-Regular.ttf") format("truetype");
      font-weight: 400;
      font-style: normal;
    }
    body {
      direction: rtl;
      text-align: right;
      font-family: "Vazirmatn", "Noto Sans Arabic", Tahoma, sans-serif;
      line-height: 1.8;
      font-size: 11pt;
      -webkit-print-color-adjust: exact;
      print-color-adjust: exact;
      text-rendering: optimizeLegibility;
    }
    p, li, h1, h2, h3, h4, h5, h6 {
      direction: rtl;
      text-align: right;
    }
    .ltr {
      direction: ltr;
      unicode-bidi: isolate;
      display: inline-block;
    }
    @page { size: A4; margin: 14mm; }
  </style>
</head>
<body>
  <!-- Persian content -->
</body>
</html>
```

## Primary Renderer

```bash
chromium --headless --disable-gpu --no-pdf-header-footer \
  --print-to-pdf="output.pdf" \
  "file:///ABSOLUTE/PATH/input.html"
```

Platform variants:

- Linux: `chromium` or `google-chrome`
- macOS: `/Applications/Google Chrome.app/Contents/MacOS/Google Chrome`
- Windows: installed `chrome.exe` path

## Markdown Conversion Path

Use Markdown -> HTML first for deterministic CSS control, then render with Chromium.

## Validation Commands

Metadata:

```bash
pdfinfo output.pdf
```

First-page raster spot-check:

```bash
pdftoppm -png -r 140 -f 1 -l 1 output.pdf /tmp/pdf-check
```

## Controlled Fallbacks

### Fallback A: Font/Shaping Repair

- switch to `Noto Naskh Arabic` or another known-good Persian font
- avoid generic serif defaults for Persian body text
- wrap mixed Latin snippets with `.ltr`

### Fallback B: Alternate Renderer

```bash
pandoc input.md -o output.pdf \
  --pdf-engine=xelatex \
  -V geometry:margin=14mm \
  -V mainfont="Vazirmatn"
```

## Failure Signals

- disconnected Persian glyphs
- incorrect punctuation order near Latin tokens
- line direction inconsistencies in list items or headings
- unexpected layout drift between environments

## Portability Notes

- prefer project-relative asset paths
- avoid user-specific absolute paths in reusable examples
- keep commands POSIX-friendly when possible
