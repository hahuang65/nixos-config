-- https://github.com/numToStr/Comment.nvim
return {
  "numToStr/Comment.nvim",
  name = "comment.nvim",
  event = { "BufReadPre", "BufNewFile" },
  config = function()
    require("Comment").setup()
  end,
}
