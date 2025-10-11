local ls = require("luasnip")
local f = ls.function_node
local s = ls.s
local fmt = require("luasnip.extras.fmt").fmt

local function is_shell_nix()
  local filename = vim.fn.expand("%:t")
  return filename == "shell.nix"
end

local function is_envrc()
  local filename = vim.fn.expand("%:t")
  return filename == ".envrc"
end

local function shell_nix_snippet(name, content)
  -- Delimiter is something absurd because we don't want substituted text in these snippets
  return s(name, fmt(content, {}, { delimiters = "#@" }), {
    condition = is_shell_nix,
  })
end

return { -- Available in all filetypes
  s(
    "time",
    f(function()
      return os.date("%H:%M:%S")
    end)
  ),

  s(
    "date",
    f(function()
      return os.date("%D")
    end)
  ),

  s(
    "!nix",
    fmt(
      [[
if [ -f /etc/NIXOS ]; then
  use nix
fi
  ]],
      {}
    ),
    {
      condition = is_envrc,
    }
  ),

  shell_nix_snippet(
    "!go",
    [[
{
  pkgs ? import <nixpkgs> { },
}:

pkgs.mkShell {
  packages = with pkgs; [
    act
    go
    golangci-lint
    gotestsum
  ];

  shellHook = ''
    export GOPATH=$(pwd)/.go
  '';
}
  ]]
  ),

  shell_nix_snippet(
    "!rails",
    [[
{
  pkgs ? import <nixpkgs> { },
}:

let
  rubyEnv = pkgs.ruby.withPackages (rp: [
    pkgs.bundler
  ]);
in
pkgs.mkShell {
  buildInputs = [
    rubyEnv
    pkgs.gcc
    pkgs.gnumake
    pkgs.pkg-config
    pkgs.zlib
    pkgs.openssl
    pkgs.libyaml
    pkgs.readline
  ];
  shellHook = ''
    export GEM_HOME=$(pwd)/.gem
    export PATH="$GEM_HOME/bin:$PATH"

    bundle config set path $GEM_HOME

    if ! command -v rails >/dev/null 2>&1; then
      gem install rails
    fi

    if  [ ! -f "config/application.rb" ]; then
      rails new . -m <(cat <<'EOF'
        gem_group :development do
          gem 'ruby-lsp'
        end

        gem_group :development, :test do
          gem "rubocop-minitest", require: false
          gem "rubocop-performance", require: false
        end

        append_to_file '.gitignore', <<~TXT

        /.gem
        TXT

        append_to_file '.rubocop.yml', <<~YAML

        plugins:
          - rubocop-minitest
          - rubocop-performance
        YAML

        after_bundle do
          git :init
          git add: "."
          git commit: %Q{ -m 'Initial commit, Rails-generated project' }
        end
    EOF)
    fi

    if [ ! -d "$GEM_HOME/gems" ]; then
      bundle install
    fi
  '';
}
  ]]
  ),
}
