return {
  {
    name = "ghostty-green-theme",
    dir = vim.fn.stdpath("config"),
    priority = 1000,
    lazy = false,
    config = function()
      require("ghostty-green").setup()
    end,
  },
}
