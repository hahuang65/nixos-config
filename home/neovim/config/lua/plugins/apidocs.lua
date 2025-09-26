-- https://github.com/emmanueltouzery/apidocs.nvim

return {
  "emmanueltouzery/apidocs.nvim",
  name = "vimplugin-emmanueltouzery-apidocs.nvim",
  dependencies = {
    "nvim-treesitter/nvim-treesitter",
    "folke/snacks.nvim",
  },
  cmd = { "ApidocsSearch", "ApidocsInstall", "ApidocsOpen", "ApidocsSelect", "ApidocsUninstall" },
  config = function()
    require("apidocs").setup({ picker = "snacks" })
    require("apidocs").ensure_install({
      "bash",
      "docker",
      "duckdb",
      "fastapi",
      "gnu_make",
      "go",
      "html",
      "jq",
      "love",
      "lua~5.1",
      "man",
      "markdown",
      "nix",
      "pandas~2",
      "postgresql~18",
      "python~3.14",
      "redis",
      "ruby~3.4",
      "rails~8.0",
      "vue~3",
    })
  end,
  keys = {
    { "<leader>d", "<cmd>ApidocsOpen<cr>", desc = "Search Docs" },
  },
}
