local wezterm = require("wezterm")
local io = require("io")
local os = require("os")

-- Boolean function that returns true of a string starts with the passed in argument.
local function starts_with(str, start)
  return str:sub(1, #start) == start
end

-- Check if a string looks like a URL
local function is_url(str)
  return str:match("^%w+://") ~= nil
end

-- Parse a filepath that may include :line and :line:col suffixes
local function parse_filepath(raw)
  local path, line, col = raw:match("^(.+):(%d+):(%d+)$")
  if path then
    return path, tonumber(line), tonumber(col)
  end
  path, line = raw:match("^(.+):(%d+)$")
  if path then
    return path, tonumber(line), nil
  end
  return raw, nil, nil
end

-- Resolve a filepath to an absolute path
local function resolve_filepath(path, cwd)
  -- Expand ~ to HOME
  if path:sub(1, 1) == "~" then
    local home = os.getenv("HOME") or ""
    return home .. path:sub(2)
  end
  -- Expand $ENV_VAR at the start
  local env_var = path:match("^%$(%w+)")
  if env_var then
    local val = os.getenv(env_var)
    if val then
      return val .. path:sub(#env_var + 2) -- +2 for $ and the var name
    end
  end
  -- Already absolute
  if path:sub(1, 1) == "/" then
    return path
  end
  -- Relative path — prepend CWD
  if cwd then
    return cwd .. "/" .. path
  end
  return path
end

-- Default variables (can be overridden by local config)
local primary_font = "Maple Mono"
local decorations = "RESIZE"
if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
  local desktop = os.getenv("XDG_CURRENT_DESKTOP") or ""
  if desktop:lower() == "sway" then
    decorations = "NONE"
  else
    decorations = "TITLE | RESIZE"
  end
end
local url_transforms = {}

-- Try to load local config module
local local_config
local ok, result = pcall(function()
  return require("local")
end)

if ok then
  local_config = result
  -- Override variables if exported by local module

  if local_config.primary_font then
    primary_font = local_config.primary_font
  end

  if local_config.decorations then
    decorations = local_config.decorations
  end

  if local_config.url_transforms then
    for _, transform in ipairs(local_config.url_transforms) do
      table.insert(url_transforms, transform)
    end
  end
end

local hyperlink_rules = wezterm.default_hyperlink_rules()
local hyperlink_regexes = {}

-- Extract regexes from default rules first
for _, rule in ipairs(hyperlink_rules) do
  table.insert(hyperlink_regexes, rule.regex)
end

-- Add custom rules (build both arrays together)
for _, rule in ipairs({
  -- Things that look like URLs with numeric addresses as hosts.
  -- E.g. http://127.0.0.1:8000 for a local development server,
  -- or http://192.168.1.1 for the web interface of many routers.
  {
    regex = [[\b\w+://(?:[\d]{1,3}\.){3}[\d]{1,3}\S*\b]],
    format = "$0",
  },

  -- Things with localhost addresses.
  {
    regex = "\\bhttp://localhost:[0-9]+(?:/\\S*)?\\b",
    format = "$0",
  },
}) do
  table.insert(hyperlink_rules, rule)
  table.insert(hyperlink_regexes, rule.regex)
end

-- Append local hyperlink rules if available
if local_config and local_config.hyperlink_rules then
  for _, rule in ipairs(local_config.hyperlink_rules) do
    table.insert(hyperlink_rules, rule)
    table.insert(hyperlink_regexes, rule.regex)
  end
end

-- Filepath patterns for QuickSelect (combined with hyperlink_regexes in Ctrl-Shift-O)
-- Note: leading \b doesn't work before non-word chars (/, ~, $, .) so those patterns omit it
local filepath_patterns = {
  -- Absolute paths (Unix), optionally with :line or :line:col
  [[/[\w.\-]+(?:/[\w.\-]+)+(?::\d+)?(?::\d+)?\b]],
  -- Relative paths starting with ./ or ../
  [[\.\.?/[\w.\-]+(?:/[\w.\-]+)*(?::\d+)?(?::\d+)?\b]],
  -- Home-relative paths ~/...
  [[~/[\w.\-]+(?:/[\w.\-]+)*(?::\d+)?(?::\d+)?\b]],
  -- Environment variable paths $VAR/...
  [[\$\w+/[\w.\-]+(?:/[\w.\-]+)*(?::\d+)?(?::\d+)?\b]],
  -- Bare relative paths with file extension (to avoid matching random words)
  -- Matches: src/main.rs, lib/foo/bar.lua, config.lua (but not "hello/world")
  [[\b[\w.\-]+(?:/[\w.\-]+)*\.[\w]+(?::\d+)?(?::\d+)?\b]],
  -- Single-quoted filenames (e.g. ls output with spaces)
  [['[^']+\.[\w]+']],
}

-- Append local filepath patterns if available
if local_config and local_config.filepath_patterns then
  for _, pattern in ipairs(local_config.filepath_patterns) do
    table.insert(filepath_patterns, pattern)
  end
end

-- Combine hyperlink regexes and filepath patterns for unified QuickSelect
local open_patterns = {}
for _, regex in ipairs(hyperlink_regexes) do
  table.insert(open_patterns, regex)
end
for _, pattern in ipairs(filepath_patterns) do
  table.insert(open_patterns, pattern)
end

-- Useful keybinds:
-- Scrollback: https://wezfurlong.org/wezterm/scrollback.html
-- Ctrl-Shift-E to open scrollback in nvim
-- Ctrl-Shift-F to search scrollback
-- Ctrl-Shift-H to search for git hashes (implemented below)
-- Ctrl-Shift-U to scroll back 1 page (implemented in keybinds)
-- Ctrl-Shift-D to scroll forward 1 page (implemented in keybinds)
-- Ctrl-N/Ctrl-P to cycle thru search results
-- Ctrl-Shift-O to open URLs (browser) or filepaths (prompted command)
-- Ctrl-Shift-Space to open Quick Select https://wezfurlong.org/wezterm/quickselect.html
-- Ctrl-Shift-X to open Copy Mode https://wezfurlong.org/wezterm/copymode.html

wezterm.on("trigger-nvim-with-scrollback", function(window, pane)
  local scrollback = pane:get_logical_lines_as_text(pane:get_dimensions().scrollback_rows)

  local name = os.tmpname()
  local f = io.open(name, "w+")
  if f ~= nil then
    f:write(scrollback)
    f:flush()
    f:close()
  end

  window:perform_action(
    wezterm.action({
      SpawnCommandInNewWindow = {
        args = { "nvim", "+normal G", name },
      },
    }),
    pane
  )
end)

-- Ran into an issue in nightly build where Alt-` stopped working.
-- It should be fixed now, but if it ever doesn't work, then
-- `use_dead_keys = true` should fix it.
local config = wezterm.config_builder()

config.default_cursor_style = "BlinkingBlock"
config.hide_mouse_cursor_when_typing = false
-- Troubleshoot fonts with `wezterm ls-fonts`
-- e.g. `wezterm ls-fonts --text "$(echo -e "\U0001f5d8")"` to find what font contains that glyph
config.font = wezterm.font_with_fallback({
  primary_font,
  { family = "Noto Color Emoji", scale = 0.75 },
  { family = "Symbols Nerd Font Mono", scale = 0.75 },
  { family = "Powerline Extra Symbols", scale = 0.75 },
  { family = "codicon", scale = 0.75 },
  { family = "Noto Sans Symbols", scale = 0.75 },
  { family = "Noto Sans Symbols2", scale = 0.75 },
  { family = "Font Awesome 6 Free", scale = 0.75 },
})
config.font_size = 14
config.enable_tab_bar = true
config.hide_tab_bar_if_only_one_tab = true
config.enable_wayland = true
config.front_end = "OpenGL"
config.window_decorations = decorations
config.window_padding = {
  left = "4px",
  right = "4px",
  top = "2px",
  bottom = "2px",
}
config.color_scheme = "Catppuccin Mocha"
config.scrollback_lines = 10000
config.window_close_confirmation = "NeverPrompt"
config.keys = {
  -- Open scrollback in nvim
  { key = "E", mods = "SHIFT|CTRL", action = wezterm.action({ EmitEvent = "trigger-nvim-with-scrollback" }) },
  -- search for things that look like git hashes
  { key = "H", mods = "SHIFT|CTRL", action = wezterm.action({ Search = { Regex = "[a-f0-9]{6,}" } }) },
  -- Scroll the scrollback
  { key = "D", mods = "SHIFT|CTRL", action = wezterm.action({ ScrollByPage = 0.5 }) },
  { key = "U", mods = "SHIFT|CTRL", action = wezterm.action({ ScrollByPage = -0.5 }) },
  -- Open URLs in browser, filepaths with user-specified command
  {
    key = "O",
    mods = "SHIFT|CTRL",
    action = wezterm.action({
      QuickSelectArgs = {
        label = "open",
        patterns = open_patterns,
        action = wezterm.action_callback(function(window, pane)
          local raw = window:get_selection_text_for_pane(pane)

          -- 1. Direct URL: open in browser
          if is_url(raw) then
            wezterm.log_info("Opening URL: " .. raw)
            wezterm.open_with(raw)
            return
          end

          -- 2. URL transform match: transform and open in browser
          for _, transform in ipairs(url_transforms) do
            for _, prefix in ipairs(transform.prefixes) do
              if starts_with(raw, prefix) then
                local url = transform.format(raw)
                wezterm.log_info("Opening URL: " .. url)
                wezterm.open_with(url)
                return
              end
            end
          end

          -- 3. Filepath: strip quotes, resolve, and prompt for command
          -- Strip surrounding single quotes (e.g. from ls output)
          if raw:sub(1, 1) == "'" and raw:sub(-1) == "'" then
            raw = raw:sub(2, -2)
          end
          local path, line, col = parse_filepath(raw)

          local cwd = nil
          local cwd_url = pane:get_current_working_dir()
          if cwd_url then
            cwd = cwd_url.file_path
          end

          local resolved = resolve_filepath(path, cwd)
          wezterm.log_info("Selected filepath: " .. resolved
            .. (line and (":" .. line) or "")
            .. (col and (":" .. col) or ""))

          -- Prompt user for the command to open the file with
          window:perform_action(
            wezterm.action({
              PromptInputLine = {
                description = "Open " .. resolved .. " with command (empty for system default):",
                action = wezterm.action_callback(function(inner_window, inner_pane, cmd)
                  if cmd == nil then
                    return -- user cancelled
                  end

                  if cmd == "" then
                    wezterm.log_info("Opening with system default: " .. resolved)
                    wezterm.open_with(resolved)
                    return
                  end

                  -- Build args: split cmd on spaces for the command name
                  local args = {}
                  for word in cmd:gmatch("%S+") do
                    table.insert(args, word)
                  end

                  -- Line number handling per command type:
                  -- "+line" style: editors that take +N before the filepath
                  -- ":line" style: test runners that take filepath:N
                  local line_arg_cmds = { nvim = true, vim = true, vi = true, nano = true, code = true, emacs = true }
                  local col_cmds = { nvim = true, vim = true, vi = true }
                  local line_suffix_cmds = { rspec = true, pytest = true }
                  if line and col and col_cmds[args[1]] then
                    table.insert(args, "+call cursor(" .. line .. "," .. col .. ")")
                    table.insert(args, resolved)
                  elseif line and line_arg_cmds[args[1]] then
                    table.insert(args, "+" .. line)
                    table.insert(args, resolved)
                  elseif line and line_suffix_cmds[args[1]] then
                    table.insert(args, resolved .. ":" .. line)
                  else
                    table.insert(args, resolved)
                  end

                  wezterm.log_info("Opening: " .. table.concat(args, " "))
                  inner_window:perform_action(
                    wezterm.action({ SpawnCommandInNewWindow = { args = args } }),
                    inner_pane
                  )
                end),
              },
            }),
            pane
          )
        end),
      },
    }),
  },
  {
    key = "N",
    mods = "SHIFT|CTRL",
    action = wezterm.action.DisableDefaultAssignment,
  },
  {
    key = "P",
    mods = "SHIFT|CTRL",
    action = wezterm.action.DisableDefaultAssignment,
  },
  { key = "PageUp", action = wezterm.action.ScrollByPage(-0.33) },
  { key = "PageDown", action = wezterm.action.ScrollByPage(0.33) },
  -- Send CSI u sequence for Shift+Enter so apps like Claude Code can distinguish it
  { key = "Enter", mods = "SHIFT", action = wezterm.action({ SendString = "\x1b[13;2u" }) },
}
config.hyperlink_rules = hyperlink_rules
config.initial_cols = 160
config.initial_rows = 48

-- Apply local config overrides if available
if local_config and local_config.apply_to_config then
  local_config.apply_to_config(config)
end

return config
