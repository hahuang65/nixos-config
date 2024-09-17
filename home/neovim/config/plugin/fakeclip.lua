-- https://github.com/kana/vim-fakeclip

if not vim.fn.empty(vim.env.WAYLAND_DISPLAY) then
  vim.g.fakeclip_provide_clipboard_key_mappings = true
end
