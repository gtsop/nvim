# TODO

- feat: comment out (undo)

## Bridge

- reafctor: create a table datastructure that maps from code file to test file, so we remove all the if/else code and instead configure everything with a table

## Explorer

- bug: fix refreshing the view recursively
- feat: when creating a file outsite the project require a confirmation
- feat: when moving a file outsite the project require a confirmation
- feat: when navigating to "up" directory stop at project level

## File Finder

- test: add unit tests
- refactor: convert file-finder into a an MVC arch

## Formatter

- feat: automatically pick local prettier bin, or global npm or npx

## Highlight

- feat: yaml support
- feat: css support
- feat: markdown support

## LSP

- feat: markdown support
- feat: cucumber support

## Find-Text

- feat: exlude project exlude directories
- feat: navigate to file but keep open when clicking shift+enter
- feat: syntax highlight
- feat: more beautiful ui
- feat: expand/collapse search results mode
- feat: expand/collapse height when navigating in and out

## Treesitter Syntax

- feat: gherkin comments

# Technical Debt

- refactor?: create a module that is aware of the project and supplies the other modules with relevant functionality
