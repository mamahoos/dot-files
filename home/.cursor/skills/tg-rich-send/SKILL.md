---
name: tg-rich-send
description: Send a Markdown document or message to the user's Telegram through the ~/dev/scripts/tg-rich CLI (Bot API sendRichMessage, rich markdown style, RTL, automatic fence-aware chunking). Use when the user asks to send something "به تلگرام", "to telegram", "vasam befrest", or wants a long markdown analysis/report delivered to their Telegram.
---

# tg-rich-send

Send Markdown to the user's Telegram. All logic (env, chunking, retries) lives in the
script — call it, do not re-implement it.

## Quick start

```bash
python3 ~/dev/scripts/tg-rich FILE.md          # send a file
cat doc.md | python3 ~/dev/scripts/tg-rich -   # send stdin
python3 ~/dev/scripts/tg-rich FILE.md --dry-run  # preview chunking only
```

Write the Markdown to a temp file first if it only exists in the conversation
(`/tmp/opencode/` is the approved scratch dir).

## What the script does

- Reads `TELEGRAM_BOT_TOKEN` / `TELEGRAM_CHAT_ID` from env or `~/dev/.env`
- Sends via `sendRichMessage` with `rich_message.markdown` (rich markdown style:
  `#` headings, `>` quotes, lists, `---` dividers, ``` fences) and `is_rtl: true`
- Chunks at top-level `---` boundaries, never inside code fences (limit 3900 chars)
- Prints `part i/N: ok=True · message_id=...` per chunk; exits non-zero on failure

## Flags

| Flag | Effect |
|------|--------|
| `--dry-run` | show chunk sizes without sending |
| `--no-rtl` | left-to-right (English/LTR-only content) |
| `--limit N` | chunk size in chars |
| `--chat ID` | override chat id |

## Notes

- On failure the script prints the Telegram API error body — report it verbatim.
- Missing env → check `~/dev/.env`; do not hard-code the token anywhere.
- Order of chunks is preserved; tell the user how many parts were sent.
