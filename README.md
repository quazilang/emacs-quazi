# Quazi for Emacs

`quazi-mode` registers `.qz`, provides highlighting, and starts `qz lsp`
through Eglot. Put this directory on `load-path` and add `(require 'quazi-mode)`.
Customize `quazi-lsp-command` if `qz` is not on `PATH`.

The canonical [LSP contract](https://github.com/quazilang/quazistrap/blob/main/docs/tooling/lsp.md) lists supported
features and limitations. Verify with `emacs --batch -Q -L . -f batch-byte-compile quazi-mode.el`.
