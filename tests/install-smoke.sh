#!/usr/bin/env bash
# Install quazi-mode.el with `package-install-file' into an isolated
# package directory, then start a fresh Emacs that only activates installed
# packages and run the Eglot smoke against the installed mode with `qz' only
# on PATH. Visiting a `.qz' file must select quazi-mode through the package
# autoloads.
set -euo pipefail

: "${EMACS:=emacs}"
: "${QZ:=qz}"
repository_dir=$(CDPATH= cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)
qz_path=$(type -P -- "$QZ")
work_dir=$(mktemp -d)
trap 'rm -rf -- "$work_dir"' EXIT
mkdir "$work_dir/bin"
ln -s "$qz_path" "$work_dir/bin/qz"

packages="(setq package-user-dir \"$work_dir/elpa\" package-archives nil)"
HOME=$work_dir "$EMACS" --batch -Q \
  --eval "(progn $packages (package-initialize) (package-install-file \"$repository_dir/quazi-mode.el\"))"
env -u QUAZI_LSP_COMMAND HOME="$work_dir" PATH="$work_dir/bin:$PATH" QUAZI_SMOKE_INSTALLED=1 \
  "$EMACS" --batch -Q --eval "(progn $packages (package-initialize))" \
  -l "$repository_dir/tests/eglot-smoke.el"
printf 'PASS Emacs package install smoke\n'
