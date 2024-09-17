-- https://github.com/nat-418/boole.nvim

require('boole').setup({
  -- Just here because the plugin requires the mappings key
  mappings = {
    increment = "<C-a>",
    decrement = "<C-x>",
  },
  -- User defined loops
  additions = {
    { "foo", "bar", "baz", "qux", "quux", "corge", "grault", "garply", "waldo", "fred", "plugh", "xyzzy" },
  },
  allow_caps_additions = {},
})
