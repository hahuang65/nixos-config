-- https://github.com/nvzone/typr

return {
  "nvzone/typr",
  name = "vimplugin-nvzone-typr",
  dependencies = {
    "nvzone/volt",
    name = "vimplugin-nvzone-volt",
  },
  cmd = { "Typr", "TyprStats" },
  config = function()
    require("cmp").setup.filetype("typr", {
      enabled = false,
    })
  end,
}
