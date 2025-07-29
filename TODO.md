# Bugs

# Features

- feat: add tree-sitter
- feat: add colors

## Explorer

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

- feat: copy file
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


