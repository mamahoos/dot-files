-- Colors matched to config/ghostty/config.ghostty (green terminal aesthetic).

local M = {}

local palette = {
  bg = "#020603",
  fg = "#B8E8BC",
  black = "#020603",
  red = "#D65C5C",
  green = "#4ED66D",
  yellow = "#C9D66A",
  blue = "#5C8FD6",
  magenta = "#A66AD6",
  cyan = "#5CCFCF",
  white = "#B8E8BC",
  bright_black = "#28402C",
  bright_red = "#FF6B6B",
  bright_green = "#63FF82",
  bright_yellow = "#E5F56B",
  bright_blue = "#70A5FF",
  bright_magenta = "#C17CFF",
  bright_cyan = "#6FFFE9",
  bright_white = "#E8FFE9",
  cursor = "#7CFF88",
  selection_bg = "#145C25",
  selection_fg = "#E8FFE9",
}

function M.setup()
  vim.cmd.hi("clear")
  if vim.fn.exists("syntax_on") then
    vim.cmd.syntax("reset")
  end
  vim.g.colors_name = "ghostty-green"

  local hl = vim.api.nvim_set_hl
  local c = palette

  hl(0, "Normal", { bg = c.bg, fg = c.fg })
  hl(0, "NormalNC", { bg = c.bg, fg = c.fg })
  hl(0, "Cursor", { bg = c.cursor, fg = c.bg })
  hl(0, "CursorLine", { bg = c.bright_black })
  hl(0, "CursorLineNr", { fg = c.bright_green, bold = true })
  hl(0, "Visual", { bg = c.selection_bg, fg = c.selection_fg })
  hl(0, "Search", { bg = c.yellow, fg = c.bg, bold = true })
  hl(0, "IncSearch", { bg = c.bright_yellow, fg = c.bg, bold = true })
  hl(0, "MatchParen", { bg = c.selection_bg, bold = true })

  hl(0, "Comment", { fg = c.bright_black, italic = true })
  hl(0, "Constant", { fg = c.bright_yellow })
  hl(0, "String", { fg = c.bright_green })
  hl(0, "Character", { fg = c.cyan })
  hl(0, "Number", { fg = c.blue })
  hl(0, "Boolean", { fg = c.yellow })
  hl(0, "Identifier", { fg = c.fg })
  hl(0, "Function", { fg = c.green })
  hl(0, "Keyword", { fg = c.cyan })
  hl(0, "Operator", { fg = c.cyan })
  hl(0, "Type", { fg = c.yellow })
  hl(0, "StorageClass", { fg = c.cyan })
  hl(0, "Structure", { fg = c.yellow })
  hl(0, "Special", { fg = c.bright_cyan })
  hl(0, "Delimiter", { fg = c.fg })
  hl(0, "Error", { fg = c.bright_red })
  hl(0, "WarningMsg", { fg = c.bright_yellow })
  hl(0, "LineNr", { fg = c.bright_black })
  hl(0, "SignColumn", { fg = c.bright_black })
  hl(0, "Folded", { bg = c.bright_black, fg = c.fg })
  hl(0, "FoldColumn", { fg = c.bright_black })

  hl(0, "StatusLine", { bg = c.selection_bg, fg = c.selection_fg })
  hl(0, "StatusLineNC", { bg = c.bg, fg = c.bright_black })
  hl(0, "WinSeparator", { fg = c.bright_black })

  hl(0, "Pmenu", { bg = c.bright_black, fg = c.fg })
  hl(0, "PmenuSel", { bg = c.selection_bg, fg = c.selection_fg })
  hl(0, "PmenuSbar", { bg = c.bg })
  hl(0, "PmenuThumb", { bg = c.green })

  hl(0, "Directory", { fg = c.bright_blue })
  hl(0, "Title", { fg = c.bright_green, bold = true })

  -- Treesitter (when enabled in a stacked PR)
  hl(0, "@comment", { link = "Comment" })
  hl(0, "@string", { link = "String" })
  hl(0, "@function", { link = "Function" })
  hl(0, "@function.builtin", { fg = c.bright_green })
  hl(0, "@keyword", { link = "Keyword" })
  hl(0, "@type", { link = "Type" })
  hl(0, "@number", { link = "Number" })
  hl(0, "@variable", { link = "Identifier" })
  hl(0, "@markup.link", { fg = c.bright_blue, underline = true })

  -- GitSigns (when enabled in a stacked PR)
  hl(0, "GitSignsAdd", { fg = c.bright_green })
  hl(0, "GitSignsChange", { fg = c.yellow })
  hl(0, "GitSignsDelete", { fg = c.bright_red })
end

return M
