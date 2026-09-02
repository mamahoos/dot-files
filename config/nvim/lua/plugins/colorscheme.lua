return {
  {
    name = "ghostty-green-theme",
    priority = 1000,
    lazy = false,
    config = function()
      require("ghostty-green").setup()
    end,
  },
}
