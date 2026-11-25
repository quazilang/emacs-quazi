# Quazi for Emacs

`quazi-mode` registers `.qz`, provides highlighting, and starts `qz lsp`
through Eglot (Emacs 29.1 or newer). Install it as a package with
`M-x package-install-file RET /path/to/quazi-mode.el`; visiting a `.qz` file
then selects `quazi-mode` through the package autoloads. Alternatively put this
directory on `load-path` and add `(require 'quazi-mode)`. Customize
`quazi-lsp-command` if `qz` is not on `PATH`.

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

`tests/install-smoke.sh` checks the package installation: it runs
`package-install-file` into an isolated package directory, starts a fresh
Emacs that only activates installed packages with `qz` only on `PATH`, and
runs the same Eglot smoke against the installed mode (which must be selected
by visiting the file, without a `require`):

```bash
EMACS=/path/to/emacs QZ=/absolute/path/to/qz bash tests/install-smoke.sh
```
