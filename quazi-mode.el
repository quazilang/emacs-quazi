;;; quazi-mode.el --- Quazi major mode and Eglot integration -*- lexical-binding: t; -*-

;; Copyright (C) 2026 by quazilang

;; Version: 0.1.0
;; Package-Requires: ((emacs "29.1"))
;; Keywords: languages
;; URL: https://github.com/quazilang/emacs-quazi
;; SPDX-License-Identifier: 0BSD

;;; Commentary:

;; Major mode for Quazi (`.qz') source files.  It highlights Quazi syntax and
;; starts the contained language server (`qz lsp') through Eglot.

;;; Code:

(require 'prog-mode)

(defgroup quazi nil "Quazi language support." :group 'languages)
(defcustom quazi-lsp-command '("qz" "lsp") "Quazi LSP command." :type '(repeat string) :group 'quazi)
(defcustom quazi-enable-eglot t "Start Eglot in Quazi buffers." :type 'boolean :group 'quazi)

(defconst quazi--font-lock-keywords
  `((,(regexp-opt '("fn" "struct" "union" "enum" "trait" "impl" "type" "import" "pub" "const" "var" "ret" "if" "else" "while" "for" "in" "match" "break" "continue" "unsafe" "as") 'symbols) . font-lock-keyword-face)
    ("@[[:alpha:]_][[:alnum:]_]*" . font-lock-preprocessor-face)
    ("\\_<\\(true\\|false\\|none\\)\\_>" . font-lock-constant-face)
    ("\\_<[[:upper:]][[:alnum:]_]*\\_>" . font-lock-type-face)))

;; Defined by eglot, which is loaded on demand below.
(defvar eglot-server-programs)
(declare-function eglot-ensure "eglot" ())

;;;###autoload
(define-derived-mode quazi-mode prog-mode "Quazi" "Major mode for Quazi source files."
  :syntax-table (let ((table (make-syntax-table)))
                  (modify-syntax-entry ?_ "w" table)
                  (modify-syntax-entry ?/ ". 12" table)
                  (modify-syntax-entry ?\n ">" table) table)
  (setq-local font-lock-defaults '(quazi--font-lock-keywords))
  (setq-local comment-start "// ")
  (when (and quazi-enable-eglot (require 'eglot nil t))
    (add-to-list 'eglot-server-programs `(quazi-mode . ,quazi-lsp-command))
    (eglot-ensure)))

;;;###autoload
(add-to-list 'auto-mode-alist '("\\.qz\\'" . quazi-mode))
(provide 'quazi-mode)
;;; quazi-mode.el ends here
