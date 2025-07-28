# Bugs

# Features

- feat: add tree-sitter
- feat: add colors

## Explorer

- bug: fix refreshing the view
- feat: shortcut to open explorer in the directory of the file being edited (nerd-tree-find equivalent)
- feat: when creating a file outsite the project require a confirmation
- feat: when moving a file outsite the project require a confirmation
- feat: when navigating to "up" directory stop at project level

## DirView

- feat: nested view
- bug: create directory

# Technical Debt

- refactor: further nest `utils` with extra files (`tbl`, `fs`, `path`, etc)
- refactor: create a module that is aware of the project and supplies the other modules with relevant functionality


