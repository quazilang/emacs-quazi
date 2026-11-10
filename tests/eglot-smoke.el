;;; eglot-smoke.el --- Real-client Eglot smoke test for quazi-mode -*- lexical-binding: t; -*-

;; Run headless:
;;   QUAZI_LSP_COMMAND=/absolute/path/to/qz emacs --batch -l tests/eglot-smoke.el
;; Opens a temporary Quazi project through quazi-mode, lets Eglot start
;; `qz lsp`, and checks hover and go-to-definition answers.

(require 'eglot)
(add-to-list 'load-path (expand-file-name ".." (file-name-directory load-file-name)))

(let ((command (getenv "QUAZI_LSP_COMMAND")))
  (unless (and command (not (string-empty-p command)))
    (error "Set QUAZI_LSP_COMMAND to the qz executable"))
  (setq quazi-lsp-command (list command "lsp")))
(require 'quazi-mode)

(defvar quazi-smoke--root (make-temp-file "quazi-eglot-smoke-" t))
(add-hook 'project-find-functions
          (lambda (directory)
            (when (file-in-directory-p directory quazi-smoke--root)
              (cons 'transient quazi-smoke--root))))

(defun quazi-smoke--wait (predicate description)
  (let ((deadline (+ (float-time) 20)))
    (while (and (not (funcall predicate)) (< (float-time) deadline))
      (accept-process-output nil 0.1))
    (unless (funcall predicate) (error "Timed out waiting for %s" description))))

(defun quazi-smoke--request (server method params)
  "Repeat METHOD until the server answers (analysis finishes after didOpen)."
  (let ((deadline (+ (float-time) 20)) (result nil))
    (while (and (null result) (< (float-time) deadline))
      (setq result (jsonrpc-request server method params))
      (unless result (accept-process-output nil 0.2)))
    result))

(defun quazi-smoke--position-of (text)
  (goto-char (point-min))
  (search-forward text)
  (eglot--pos-to-lsp-position (match-beginning 0)))

(unwind-protect
    (progn
      (with-temp-file (expand-file-name "quazi.toml" quazi-smoke--root)
        (insert "[package]\nname = \"eglot-smoke\"\n\n[build]\nentry = \"main.qz\"\n"))
      (let ((source (expand-file-name "main.qz" quazi-smoke--root)))
        (with-temp-file source
          (insert "fn helper(value: i32) i32 { ret value; }\n\n"
                  "fn main() i32 {\n    const answer: i32 = 42;\n    ret helper(answer);\n}\n"))
        (find-file source)
        (unless (eq major-mode 'quazi-mode) (error "quazi-mode was not selected"))
        (eglot-ensure)
        ;; In batch mode the deferred start runs on the next command loop.
        (run-hooks 'post-command-hook)
        (quazi-smoke--wait #'eglot-current-server "the Eglot connection")
        (let ((server (eglot-current-server)))
          (quazi-smoke--wait (lambda () (eglot--server-capable :hoverProvider))
                             "server capabilities")
          (let* ((hover (quazi-smoke--request
                         server :textDocument/hover
                         (list :textDocument (eglot--TextDocumentIdentifier)
                               :position (quazi-smoke--position-of "42"))))
                 (contents (format "%S" (plist-get hover :contents))))
            (unless (string-match-p "i32" contents)
              (error "Hover did not describe the literal: %s" contents)))
          (let* ((definition (quazi-smoke--request
                              server :textDocument/definition
                              (list :textDocument (eglot--TextDocumentIdentifier)
                                    :position (quazi-smoke--position-of "helper(answer"))))
                 (location (if (vectorp definition) (aref definition 0) definition))
                 (line (plist-get (plist-get (plist-get location :range) :start) :line)))
            (unless (equal line 0)
              (error "Definition of helper is not on line 0: %S" definition)))
          (eglot-shutdown server)
          (princ "PASS emacs eglot: quazi-mode, qz lsp connection, hover and definition\n"))))
  (delete-directory quazi-smoke--root t))
