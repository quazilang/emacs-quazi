# Quazi for Emacs

`quazi-mode` registers `.qz`, provides highlighting, and starts `qz lsp`
through Eglot. Put this directory on `load-path` and add `(require 'quazi-mode)`.
Customize `quazi-lsp-command` if `qz` is not on `PATH`.

The canonical [LSP contract](https://github.com/quazilang/quazistrap/blob/main/docs/tooling/lsp.md) lists supported
features and limitations. Verify with `emacs --batch -Q -L . -f batch-byte-compile quazi-mode.el`.

## Real-client check

`tests/eglot-smoke.el` drives Eglot headless: it opens a temporary Quazi
project through `quazi-mode`, lets Eglot start `qz lsp`, and requires hover
on a literal and go-to-definition of a function to be answered:

```bash
QUAZI_LSP_COMMAND=/absolute/path/to/qz emacs --batch -l tests/eglot-smoke.el
```

It prints `PASS emacs eglot: ...` and exits non-zero on any failure (verified
with Emacs 31.1).
