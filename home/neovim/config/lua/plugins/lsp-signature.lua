-- https://github.com/ray-x/lsp_signature.nvim

return {
  "ray-x/lsp_signature.nvim",
  event = "InsertEnter",
  opts = {
    debug = false, -- set to true to enable debug logging
    log_path = "/tmp/lsp_signature.log", -- debug log path
    verbose = false, -- show debug line number
    bind = true, -- This is mandatory, otherwise border config won't get registered.
    -- If you want to hook lspsaga or other signature handler, pls set to false
    doc_lines = 10, -- will show two lines of comment/doc(if there are more than two lines in doc, will be truncated);
    -- set to 0 if you DO NOT want any API comments be shown
    -- This setting only take effect in insert mode, it does not affect signature help in normal
    -- mode, 10 by default
    max_height = 12, -- max height of signature floating_window
    max_width = 80, -- max_width of signature floating_window
    wrap = false, -- allow doc/signature text wrap inside floating_window, useful if your lsp return doc/sig is too long
    floating_window = true, -- show hint in a floating window, set to false for virtual text only mode
    floating_window_above_cur_line = true, -- try to place the floating above the current line when possible Note:
    -- will set to true when fully tested, set to false will use whichever side has more space
    -- this setting will be helpful if you do not want the PUM and floating win overlap
    fix_pos = false, -- set to true, the floating window will not auto-close until finish all parameters
    hint_enable = true, -- virtual hint enable
    hint_prefix = " ",
    hint_scheme = "String",
    hi_parameter = "LspSignatureActiveParameter", -- how your parameter will be highlight
    handler_opts = {
      border = "rounded", -- double, rounded, single, shadow, none
    },
    always_trigger = true, -- sometime show signature on new line or in middle of parameter can be confusing, set it to false for #58
    auto_close_after = nil, -- autoclose signature float win after x sec, disabled if nil.
    check_completion_visible = true, -- adjust position of signature window relative to completion popup
    extra_trigger_chars = {}, -- Array of extra characters that will trigger signature completion, e.g., {"(", ","}
    zindex = 200, -- by default it will be on top of all floating windows, set to <= 50 send it to bottom
    padding = "", -- character to pad on left and right of signature can be ' ', or '|'  etc
    transparency = nil, -- disabled by default, allow floating win transparent value 1~100
    shadow_blend = 36, -- if you using shadow as border use this set the opacity
    shadow_guibg = "Black", -- if you using shadow as border use this set the color e.g. 'Green' or '#121315'
    timer_interval = 200, -- default timer check interval set to lower value if you want to reduce latency
    toggle_key = nil, -- toggle signature on and off in insert mode,  e.g. toggle_key = '<M-x>'
    select_signature_key = nil, -- cycle to next signature, e.g. '<M-n>' function overloading
    move_cursor_key = nil, -- imap, use nvim_set_current_win to move cursor between current win and floating
  },
  config = function(_, opts)
    require("lsp_signature").setup(opts)
  end,
}
