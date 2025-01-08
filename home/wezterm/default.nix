{ config, lib, ... }:

let
  inherit (lib) mkEnableOption mkIf;
in
{
  options = {
    wezterm = {
      enable = mkEnableOption "wezterm";
    };
  };

  config = mkIf config.wezterm.enable {
    programs.wezterm = {
      enable = true;
      extraConfig = ''
        local wezterm = require("wezterm")
        local io = require("io")
        local os = require("os")

        -- Boolean function that returns true of a string starts with the passed in argument.
        local function starts_with(str, start)
          return str:sub(1, #start) == start
        end

        local a5_base_url = "https://alpha5sp.atlassian.net/browse/"

        local hyperlink_rules = wezterm.default_hyperlink_rules()
        local hyperlink_regexes = {}
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

          -- A5 Jira tickets
          {
            regex = "\\b([aA]5-\\d+)\\b",
            format = a5_base_url .. "$1",
          },
        }) do
          table.insert(hyperlink_rules, rule)
        end

        for _, v in ipairs(hyperlink_rules) do
          table.insert(hyperlink_regexes, v["regex"])
        end

        -- Derive from Stylix
        local primary_font = "${config.stylix.fonts.monospace.name}"
        local font_size = (setmetatable({
          ["ilum"] = 12,
          ["bespin"] = 16,
          ["endor"] = 12,
          ["6649L06"] = 16,
        }, {
          __index = function()
            return 16 -- Default value
          end,
        }))[wezterm.hostname()]

        local decorations = "RESIZE"
        if wezterm.target_triple == "x86_64-unknown-linux-gnu" then
          decorations = "NONE"
        end

        -- Useful keybinds:
        -- Scrollback: https://wezfurlong.org/wezterm/scrollback.html
        -- Ctrl-Shift-E to open scrollback in nvim
        -- Ctrl-Shift-F to search scrollback
        -- Ctrl-Shift-H to search for git hashes (implemented below)
        -- Ctrl-Shift-U to scroll back 1 page (implemented in keybinds)
        -- Ctrl-Shift-D to scroll forward 1 page (implemented in keybinds)
        -- Ctrl-N/Ctrl-P to cycle thru search results
        -- Ctrl-Shift-Space to open Quick Select https://wezfurlong.org/wezterm/quickselect.html
        -- Ctrl-Shift-X to open Copy Mode https://wezfurlong.org/wezterm/copymode.html

        -- https://wezfurlong.org/wezterm/config/lua/wezterm/on.html
        wezterm.on("trigger-nvim-with-scrollback", function(window, pane)
          -- Retrieve the current viewport's text.
          -- Pass an optional number of lines (eg: 2000) to retrieve
          -- that number of lines starting from the bottom of the viewport.
          local scrollback = pane:get_lines_as_text(2000)

          -- Create a temporary file to pass to vim
          local name = os.tmpname()
          local f = io.open(name, "w+")
          if f ~= nil then
            f:write(scrollback)
            f:flush()
            f:close()
          end

          -- Open a new window running vim and tell it to open the file
          window:perform_action(
            wezterm.action({
              SpawnCommandInNewWindow = {
                args = { "nvim", name },
              },
            }),
            pane
          )

          -- wait "enough" time for vim to read the file before we remove it.
          -- The window creation and process spawn are asynchronous
          -- wrt. running this script and are not awaitable, so we just pick
          -- a number.  We don't strictly need to remove this file, but it
          -- is nice to avoid cluttering up the temporary file directory
          -- location.
          wezterm.sleep_ms(2000)
          os.remove(name)
        end)

        -- Ran into an issue in nightly build where Alt-` stopped working.
        -- It should be fixed now, but if it ever doesn't work, then
        -- `use_dead_keys = true` should fix it.
        return {
          default_cursor_style = "BlinkingBlock",
          hide_mouse_cursor_when_typing = false,
          -- Troubleshoot fonts with `wezterm ls-fonts`
          -- e.g. `wezterm ls-fonts --text "$(echo -e "\U0001f5d8")"` to find what font contains that glyph
          font = wezterm.font_with_fallback({
            primary_font,
            { family = "Noto Color Emoji", scale = 0.75 },
            { family = "Symbols Nerd Font Mono", scale = 0.75 },
            { family = "Powerline Extra Symbols", scale = 0.75 },
            { family = "codicon", scale = 0.75 },
            { family = "Noto Sans Symbols", scale = 0.75 },
            { family = "Noto Sans Symbols2", scale = 0.75 },
            { family = "Font Awesome 6 Free", scale = 0.75 },
          }),
          font_size = font_size,
          enable_tab_bar = true,
          hide_tab_bar_if_only_one_tab = true,
          enable_wayland = true,
          front_end = "WebGpu",
          window_decorations = decorations,
          window_padding = {
            left = "4px",
            right = "4px",
            top = "2px",
            bottom = "2px",
          },
          scrollback_lines = 10000,
          window_close_confirmation = "NeverPrompt",
          keys = {
            -- Open scrollback in nvim
            { key = "E", mods = "SHIFT|CTRL", action = wezterm.action({ EmitEvent = "trigger-nvim-with-scrollback" }) },
            -- search for things that look like git hashes
            { key = "H", mods = "SHIFT|CTRL", action = wezterm.action({ Search = { Regex = "[a-f0-9]{6,}" } }) },
            -- Scroll the scrollback
            { key = "D", mods = "SHIFT|CTRL", action = wezterm.action({ ScrollByPage = 0.5 }) },
            { key = "U", mods = "SHIFT|CTRL", action = wezterm.action({ ScrollByPage = -0.5 }) },
            -- Open browser with quickselect https://github.com/wez/wezterm/issues/1362#issuecomment-1000457693
            {
              key = "O",
              mods = "SHIFT|CTRL",
              action = wezterm.action({
                QuickSelectArgs = {
                  patterns = hyperlink_regexes,
                  action = wezterm.action_callback(function(window, pane)
                    local url = window:get_selection_text_for_pane(pane)
                    if starts_with(url, "A5-") or starts_with(url, "a5-") then
                      url = a5_base_url .. url
                    end

                    wezterm.log_info("Opening: " .. url)
                    wezterm.open_with(url)
                  end),
                },
              }),
            },
          },
          hyperlink_rules = hyperlink_rules,
        }
      '';
    };
  };
}
