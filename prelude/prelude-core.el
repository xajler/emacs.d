;;; prelude-core.el --- Emacs Prelude: core Prelude defuns.
;;
;; Copyright (c) 2011-2012 Bozhidar Batsov
;;
;; Author: Bozhidar Batsov <bozhidar@batsov.com>
;; URL: http://batsov.com/emacs-prelude
;; Version: 1.0.0
;; Keywords: convenience

;; This file is not part of GNU Emacs.

;;; Commentary:

;; Here are the definitions of most of the functions added by Prelude.

;;; License:

;; This program is free software; you can redistribute it and/or
;; modify it under the terms of the GNU General Public License
;; as published by the Free Software Foundation; either version 3
;; of the License, or (at your option) any later version.
;;
;; This program is distributed in the hope that it will be useful,
;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;; GNU General Public License for more details.
;;
;; You should have received a copy of the GNU General Public License
;; along with GNU Emacs; see the file COPYING.  If not, write to the
;; Free Software Foundation, Inc., 51 Franklin Street, Fifth Floor,
;; Boston, MA 02110-1301, USA.

;;; Code:

(require 'cl)
(require 'thingatpt)

(defun ido-imenu ()
  "Update the imenu index and then use ido to select a symbol to navigate to.
Symbols matching the text at point are put first in the completion list."
  (interactive)
  (imenu--make-index-alist)
  (let ((name-and-pos '())
        (symbol-names '()))
    (flet ((addsymbols (symbol-list)
                       (when (listp symbol-list)
                         (dolist (symbol symbol-list)
                           (let ((name nil) (position nil))
                             (cond
                              ((and (listp symbol) (imenu--subalist-p symbol))
                               (addsymbols symbol))

                              ((listp symbol)
                               (setq name (car symbol))
                               (setq position (cdr symbol)))

                              ((stringp symbol)
                               (setq name symbol)
                               (setq position (get-text-property 1 'org-imenu-marker symbol))))

                             (unless (or (null position) (null name))
                               (add-to-list 'symbol-names name)
                               (add-to-list 'name-and-pos (cons name position))))))))
      (addsymbols imenu--index-alist))
    ;; If there are matching symbols at point, put them at the beginning of `symbol-names'.
    (let ((symbol-at-point (thing-at-point 'symbol)))
      (when symbol-at-point
        (let* ((regexp (concat (regexp-quote symbol-at-point) "$"))
               (matching-symbols (delq nil (mapcar (lambda (symbol)
                                                     (if (string-match regexp symbol) symbol))
                                                   symbol-names))))
          (when matching-symbols
            (sort matching-symbols (lambda (a b) (> (length a) (length b))))
            (mapc (lambda (symbol) (setq symbol-names (cons symbol (delete symbol symbol-names))))
                  matching-symbols)))))
    (let* ((selected-symbol (ido-completing-read "Symbol? " symbol-names))
           (position (cdr (assoc selected-symbol name-and-pos))))
      (goto-char position))))


(defun prelude-add-subfolders-to-load-path (parent-dir)
  "Adds all first level `parent-dir' subdirs to the
Emacs load path."
  (dolist (f (directory-files parent-dir))
    (let ((name (concat parent-dir f)))
      (when (and (file-directory-p name)
                 (not (equal f ".."))
                 (not (equal f ".")))
        (add-to-list 'load-path name)))))

(defun prelude-open-with ()
  "Simple function that allows us to open the underlying
file of a buffer in an external program."
  (interactive)
  (when buffer-file-name
    (shell-command (concat
                    (if (eq system-type 'darwin)
                        "open"
                      (read-shell-command "Open current file with: "))
                    " "
                    buffer-file-name))))

(defun prelude-buffer-mode (buffer-or-name)
  (with-current-buffer buffer-or-name major-mode))

(defun prelude-visit-term-buffer ()
  (interactive)
  (if (not (get-buffer "*ansi-term*"))
      (ansi-term "/bin/bash")
    (switch-to-buffer "*ansi-term*")))

(defun prelude-google ()
  "Googles a query or region if any."
  (interactive)
  (browse-url
   (concat
    "http://www.google.com/search?ie=utf-8&oe=utf-8&q="
    (url-hexify-string (if mark-active
         (buffer-substring (region-beginning) (region-end))
       (read-string "Google: "))))))

(defun prelude-indent-rigidly-and-copy-to-clipboard (begin end indent)
  "Copy the selected code region to the clipboard, indented according
to Markdown blockquote rules."
  (let ((buffer (current-buffer)))
    (with-temp-buffer
      (insert-buffer-substring-no-properties buffer begin end)
      (indent-rigidly (point-min) (point-max) indent)
      (clipboard-kill-ring-save (point-min) (point-max)))))

(defun prelude-indent-blockquote-and-copy-to-clipboard (begin end)
  "Copy the selected code region to the clipboard, indented according
to markdown blockquote rules (useful to copy snippets to StackOverflow, Assembla, Github."
  (interactive "r")
  (prelude-indent-rigidly-and-copy-to-clipboard begin end 4))

(defun prelude-indent-nested-blockquote-and-copy-to-clipboard (begin end)
  "Copy the selected code region to the clipboard, indented according
to markdown blockquote rules. Useful to add snippets under bullet points."
  (interactive "r")
  (prelude-indent-rigidly-and-copy-to-clipboard begin end 6))

(defun prelude-insert-empty-line ()
  "Insert an empty line after the current line and positon
the curson at its beginning, according to the current mode."
  (interactive)
  (move-end-of-line nil)
  (open-line 1)
  (next-line 1)
  (indent-according-to-mode))

(defun prelude-move-line-up ()
  "Move up the current line."
  (interactive)
  (transpose-lines 1)
  (previous-line 2))

(defun prelude-move-line-down ()
  "Move down the current line."
  (interactive)
  (next-line 1)
  (transpose-lines 1)
  (previous-line 1))

;; add the ability to copy and cut the current line, without marking it
(defadvice kill-ring-save (before slick-copy activate compile)
  "When called interactively with no active region, copy a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (message "Copied line")
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(defadvice kill-region (before slick-cut activate compile)
  "When called interactively with no active region, kill a single line instead."
  (interactive
   (if mark-active (list (region-beginning) (region-end))
     (list (line-beginning-position)
           (line-beginning-position 2)))))

(defun prelude-indent-buffer ()
  "Indents the entire buffer."
  (interactive)
  (indent-region (point-min) (point-max)))

(defun prelude-indent-region-or-buffer ()
  "Indents a region if selected, otherwise the whole buffer."
  (interactive)
  (save-excursion
    (if (region-active-p)
        (progn
          (indent-region (region-beginning) (region-end))
          (message "Indented selected region."))
      (progn
        (prelude-indent-buffer)
        (message "Indented buffer.")))))

(defun prelude-annotate-todo ()
  "Put fringe marker on TODO: lines in the curent buffer."
  (interactive)
  (save-excursion
    (goto-char (point-min))
    (while (re-search-forward "TODO:" nil t)
      (let ((overlay (make-overlay (- (point) 5) (point))))
        (overlay-put overlay
                     'before-string
                     (propertize (format "A")
                                 'display '(left-fringe right-triangle)))))))

(defun prelude-copy-file-name-to-clipboard ()
  "Copy the current buffer file name to the clipboard."
  (interactive)
  (let ((filename (if (equal major-mode 'dired-mode)
                      default-directory
                    (buffer-file-name))))
    (when filename
      (kill-new filename)
      (message "Copied buffer file name '%s' to the clipboard." filename))))

(defun prelude-duplicate-current-line-or-region (arg)
  "Duplicates the current line or region ARG times.
If there's no region, the current line will be duplicated. However, if
there's a region, all lines that region covers will be duplicated."
  (interactive "p")
  (let (beg end (origin (point)))
    (if (and mark-active (> (point) (mark)))
        (exchange-point-and-mark))
    (setq beg (line-beginning-position))
    (if mark-active
        (exchange-point-and-mark))
    (setq end (line-end-position))
    (let ((region (buffer-substring-no-properties beg end)))
      (dotimes (i arg)
        (goto-char end)
        (newline)
        (insert region)
        (setq end (point)))
      (goto-char (+ origin (* (length region) arg) arg)))))

;; TODO doesn't work with uniquify
(defun prelude-rename-file-and-buffer ()
  "Renames current buffer and file it is visiting."
  (interactive)
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not (and filename (file-exists-p filename)))
        (message "Buffer '%s' is not visiting a file!" name)
      (let ((new-name (read-file-name "New name: " filename)))
        (cond ((get-buffer new-name)
               (message "A buffer named '%s' already exists!" new-name))
              (t
               (rename-file name new-name 1)
               (rename-buffer new-name)
               (set-visited-file-name new-name)
               (set-buffer-modified-p nil)))))))

(defun prelude-delete-file-and-buffer ()
  "Kills the current buffer and deletes the file it is visiting"
  (interactive)
  (let ((filename (buffer-file-name)))
    (when filename
      (delete-file filename)
      (message "Deleted file %s" filename)))
  (kill-buffer))

(defun duplicate-line ()
  (interactive)
  (move-beginning-of-line 1)
  (kill-line)
  (yank)
  (open-line 1)
  (next-line 1)
  (yank))


(defun prelude-view-url ()
  "Open a new buffer containing the contents of URL."
  (interactive)
  (let* ((default (thing-at-point-url-at-point))
         (url (read-from-minibuffer "URL: " default)))
    (switch-to-buffer (url-retrieve-synchronously url))
    (rename-buffer url t)
    ;; TODO: switch to nxml/nxhtml mode
    (cond ((search-forward "<?xml" nil t) (xml-mode))
          ((search-forward "<html" nil t) (html-mode)))))

;; We have a number of turn-on-* functions since it's advised that lambda
;; functions not go in hooks. Repeatedly evaluating an add-to-list with a
;; hook value will repeatedly add it since there's no way to ensure
;; that a lambda doesn't already exist in the list.

(defun prelude-turn-on-whitespace ()
  (whitespace-mode +1))

(defun prelude-turn-off-whitespace ()
  (whitespace-mode -1))

(defun prelude-turn-on-abbrev ()
  (abbrev-mode +1))

(defun prelude-turn-off-abbrev ()
  (abbrev-mode -1))

(defun prelude-untabify-buffer ()
  (interactive)
  (untabify (point-min) (point-max)))

(defun prelude-cleanup-buffer ()
  "Perform a bunch of operations on the whitespace content of a buffer."
  (interactive)
  (prelude-indent-buffer)
  (prelude-untabify-buffer)
  (whitespace-cleanup))

(defun prelude-eval-and-replace ()
  "Replace the preceding sexp with its value."
  (interactive)
  (backward-kill-sexp)
  (condition-case nil
      (prin1 (eval (read (current-kill 0)))
             (current-buffer))
    (error (message "Invalid expression")
           (insert (current-kill 0)))))

(defun prelude-recompile-init ()
  "Byte-compile all your dotfiles again."
  (interactive)
  (byte-recompile-directory prelude-dir 0))

(defun prelude-sudo-edit (&optional arg)
  (interactive "p")
  (if (or arg (not buffer-file-name))
      (find-file (concat "/sudo:root@localhost:" (ido-read-file-name "File: ")))
    (find-alternate-file (concat "/sudo:root@localhost:" buffer-file-name))))

(defun prelude-switch-or-start (function buffer)
  "If the buffer is current, bury it, otherwise invoke the function."
  (if (equal (buffer-name (current-buffer)) buffer)
      (bury-buffer)
    (if (get-buffer buffer)
        (switch-to-buffer buffer)
      (funcall function))))

(defun prelude-insert-date ()
  "Insert a time-stamp according to locale's date and time format."
  (interactive)
  (insert (format-time-string "%c" (current-time))))

(defun prelude-conditionally-enable-paredit-mode ()
  "Enable paredit-mode in the minibuffer, during eval-expression."
  (if (eq this-command 'eval-expression)
      (paredit-mode 1)))

(add-hook 'minibuffer-setup-hook 'prelude-conditionally-enable-paredit-mode)

(defun prelude-recentf-ido-find-file ()
  "Find a recent file using ido."
  (interactive)
  (let ((file (ido-completing-read "Choose recent file: " recentf-list nil t)))
    (when file
      (find-file file))))

(defun prelude-swap-windows ()
  "If you have 2 windows, it swaps them."
  (interactive)
  (if (/= (count-windows) 2)
      (message "You need exactly 2 windows to do this.")
    (let* ((w1 (first (window-list)))
           (w2 (second (window-list)))
           (b1 (window-buffer w1))
           (b2 (window-buffer w2))
           (s1 (window-start w1))
           (s2 (window-start w2)))
      (set-window-buffer w1 b2)
      (set-window-buffer w2 b1)
      (set-window-start w1 s2)
      (set-window-start w2 s1)))
  (other-window 1))

(defun prelude-kill-other-buffers ()
  "Kill all buffers but the current one. Doesn't mess with special buffers."
  (interactive)
  (dolist (buffer (buffer-list))
    (unless (or (eql buffer (current-buffer)) (not (buffer-file-name buffer)))
      (kill-buffer buffer))))

(require 'repeat)

(defun make-repeatable-command (cmd)
  "Returns a new command that is a repeatable version of CMD.
The new command is named CMD-repeat.  CMD should be a quoted
command.

This allows you to bind the command to a compound keystroke and
repeat it with just the final key.  For example:

  (global-set-key (kbd \"C-c a\") (make-repeatable-command 'foo))

will create a new command called foo-repeat.  Typing C-c a will
just invoke foo.  Typing C-c a a a will invoke foo three times,
and so on."
  (fset (intern (concat (symbol-name cmd) "-repeat"))
        `(lambda ,(help-function-arglist cmd) ;; arg list
           ,(format "A repeatable version of `%s'." (symbol-name cmd)) ;; doc string
           ,(interactive-form cmd) ;; interactive form
           ;; see also repeat-message-function
           (setq last-repeatable-command ',cmd)
           (repeat nil)))
  (intern (concat (symbol-name cmd) "-repeat")))

(defvar prelude-tips
  '("Press <C-c o> to open a file with external program."
    "Press <C-c p f> to navigate a project's files with ido."
    "Press <C-c h> to navigate a project in Helm."
    "Press <C-c g> to search in Google."
    "Press <C-c r> to rename the current buffer and file it's visiting."
    "Press <C-c t> to open a terminal in Emacs."))

(defun prelude-tip-of-the-day ()
  (interactive)
  (message (concat "Prelude tip: " (nth (random (length prelude-tips)) prelude-tips))))

(defun prelude-eval-after-init (form)
  "Add `(lambda () FORM)' to `after-init-hook'.

    If Emacs has already finished initialization, also eval FORM immediately."
  (let ((func (list 'lambda nil form)))
    (add-hook 'after-init-hook func)
    (when after-init-time
      (eval form))))

(provide 'prelude-core)
;;; prelude-core.el ends here