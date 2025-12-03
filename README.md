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
npm install -g vscode-langservers-extracted@4.8.0 typescript-language-server typescript eslint prettier eslint_d
```

## Development

1. Install [luarocks](https://luarocks.org/#quick-start)
2. Install buster `sudo luarocks install busted`
3. (watch mode) install `entr`

# Alacritty conf

```
[env]
TERM = "xterm-256color"

[[keyboard.bindings]]
key = "F"
mods = "Control|Shift"
chars = "\u2007"
```

# Tmux config

set -g default-terminal "tmux-256color"
set -ag terminal-overrides ",xterm-256color:RGB,_:Tc"
set -as terminal-overrides ',_:Smulx=\E[4::%p1%dm'
set -as terminal-overrides ',\*:Setulc=\E[58::2::::%p1%{65536}%/%d::%p1%{256}%/%{255}%&%d::%p1%{255}%&%d%;m'
