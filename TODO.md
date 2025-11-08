# TODO

## Bridge

- feat: map between .feature and step.js files
- reafctor: create a table datastructure that maps from code file to test file, so we remove all the if/else code and instead configure everything with a table

## Explorer

- bug: fix refreshing the view recursively
- feat: when creating a file and have hovered on a directory, auto populate this directory to the default input
- feat: when creating a file outsite the project require a confirmation
- feat: when moving a file outsite the project require a confirmation
- feat: when navigating to "up" directory stop at project level

## File Finder

- feat: improve the scoring of files to make the basename of the flie to score higher. Also, give more points for consecutive characters
- test: add unit tests
- refactor: convert file-finder into a an MVC arch

## Formatter

- feat: automatically pick local prettier bin, or global npm or npx
- feat: run eslint

## Highlight

- feat: css support
- feat: yaml support
- feat: json support
- feat: jsx support
- feat: markdown support

## LSP

- feat: autocomplete
- feat: autoimports
- feat: markdown support

## Seeker

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

