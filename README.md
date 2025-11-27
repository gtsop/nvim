# My nvim config

## Installation

1. Clone repo in `$HOME/.config/`
2. Suggested aliases for `$HOME/.bashrc`

```
alias nvmini="nvim -u NONE -S $HOME/.config/nvim/init.lua -i NONE"
alias n="nvmini"
```

3. Install tools

```
npm install -g vscode-langservers-extracted typescript-language-server eslint prettier
```

## Development

1. Install [luarocks](https://luarocks.org/#quick-start)
2. Install buster `sudo luarocks install busted`
3. (watch mode) install `entr`

# Alacritty conf

```
[[keyboard.bindings]]
key = "F"
mods = "Control|Shift"
chars = "\u2007"
```
