# TODO

## Formatter

- feat: automatically pick local prettier bin, or global npm or npx
- feat: run eslint

## LSP

- feat: autocomplete
- feat: autoimports
- feat: markdown support

## Explorer

- bug: fix refreshing the view recursively
- feat: when creating a file outsite the project require a confirmation
- feat: when moving a file outsite the project require a confirmation
- feat: when navigating to "up" directory stop at project level

## Bridge

- feat: map between .feature and step.js files
- reafctor: create a table datastructure that maps from code file to test file, so we remove all the if/else code and instead configure everything with a table

## Highlight

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

