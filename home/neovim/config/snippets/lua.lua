local ls = require("luasnip")
local c = ls.choice_node
local d = ls.dynamic_node
local f = ls.function_node
local i = ls.insert_node
local s = ls.s
local sn = ls.snippet_node
local t = ls.text_node
local fmt = require("luasnip.extras.fmt").fmta

local function split_path(path)
  local parts = vim.split(path, "[./]", false)
  return parts[#parts] or ""
end

local function endif()
  -- This function represents a snippet choice for
  -- 1) `end`ing
  -- 2) `else...end`ing
  -- 3) `elseif...then...end`ing
  -- an `if statement. If using the `elseif`, the `end` can recursively call itself
  -- such that another `elseif...then...end` or `else...end` can be used.
  return sn(nil, {
    c(1, {
      t("end"),
      sn(
        nil,
        fmt(
          [[
          else
            <>
          end
        ]],
          {
            i(1),
          }
        )
      ),
      sn(
        nil,
        fmt(
          [[
          elseif <1> then
            <2>
          <3>
        ]],
          {
            i(1),
            i(2),
            d(3, endif, {}),
          }
        )
      ),
    }),
  })
end

return {
  s(
    "if",
    fmt(
      [[
        if <1> then
          <2>
        <3>
      ]],
      {
        i(1),
        i(2),
        d(3, endif, {}),
      }
    )
  ),

  s(
    "req",
    fmt(
      [[local <> = require("<>")]],
      { f(function(import_name)
        return split_path(import_name[1][1])
      end, { 1 }), i(1) }
    )
  ),

  s(
    "mod",
    fmt(
      [[
        local M = {}

        <1>
          
        return M
      ]],
      {
        i(1),
      }
    )
  ),
}
