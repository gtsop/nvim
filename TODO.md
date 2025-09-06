# TODO

## Formatter

- feat: automatically pick local prettier bin, or global npm or npx
- feat: run eslint

## LSP

- feat: autocomplete
- feat: autoimports
- feat: markdown support

## Explorer

- feat: when user is in the window and there is overflow, expand the width of the window. Restore to initial width when user navigates elsewhere
- bug: fix refreshing the view recursively
- bug: create directory causes a crash
  <trace>
  New file: /home/johhnd/.config/nvim/skata/E5108: Error executing lua: Vim:E482: Can't open file /home/johhnd/.config/nvim/skata/ for writing: illegal operation on a directory
  stack traceback:
  [C]: in function 'writefile'
  /home/johhnd/.config/nvim/lua/ide/init.lua:71: in function 'on_confirm'
  /usr/share/nvim/runtime/lua/vim/ui.lua:104: in function 'input'
  /home/johhnd/.config/nvim/lua/ide/init.lua:68: in function 'create_file'
  ...hhnd/.config/nvim/lua/components/explorer/controller.lua:134: in function 'callback'
  ...hhnd/.config/nvim/lua/components/explorer/controller.lua:76: in function 'using_hovered_node'
  ...hhnd/.config/nvim/lua/components/explorer/controller.lua:133: in function <...hhnd/.config/nvim/lua/components/explorer/controller.lua:132>
  </trace>

- feat: when creating a file outsite the project require a confirmation
- feat: when moving a file outsite the project require a confirmation
- feat: when navigating to "up" directory stop at project level

## Bridge

- feat: map between .feature and step.js files
- reafctor: create a table datastructure that maps from code file to test file, so we remove all the if/else code and instead configure everything with a table

## Highlight

- bug: fix visual mode highlight
- feat: html support
- feat: css support
- feat: markdown support

## Treesitter Syntax

- feat: gherkin comments

## File Finder

- feat: improve the scoring of files to make the basename of the flie to score higher. Also, give more points for consecutive characters
- test: add unit tests
- refactor: convert file-finder into a an MVC arch

# Technical Debt

- refactor?: create a module that is aware of the project and supplies the other modules with relevant functionality

