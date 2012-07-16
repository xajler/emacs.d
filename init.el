;;; init.el --- Prelude's configuration entry point.
;;
;; Copyright (c) 2011 Bozhidar Batsov
;;
;; Author: Bozhidar Batsov <bozhidar@batsov.com>
;; URL: http://batsov.com/prelude
;; Version: 1.0.0
;; Keywords: convenience

;; This file is not part of GNU Emacs.

;;; Commentary:

;; This file simply sets up the default load path and requires
;; the various modules defined within Emacs Prelude.

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

;; Turn off mouse interface early in startup to avoid momentary display
;; You really don't need these; trust me.
(if (fboundp 'menu-bar-mode) (menu-bar-mode -1))
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1))
(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1))
(setq dotfiles-dir (file-name-directory
                    (or (buffer-file-name) load-file-name)))

(setq org-src-fontify-natively t)
(setq load-path (cons "~/.emacs.d/vendor/org-mode/lisp" load-path))
(setq load-path (cons "~/.emacs.d/vendor/org-mode/contrib/lisp" load-path))
(setq autoload-file (concat dotfiles-dir "loaddefs.el"))

(message "Prelude is powering up... Be patient, Master %s!" (getenv "USER"))

(defvar prelude-dir (file-name-directory load-file-name)
  "The root dir of the Emacs Prelude distribution.")
(defvar prelude-modules-dir (concat prelude-dir "prelude/")
  "This directory houses all of the built-in Prelude module. You should
avoid modifying the configuration there.")
(defvar prelude-personal-dir (concat prelude-dir "personal/")
  "Users of Emacs Prelude are encouraged to keep their personal configuration
changes in this directory. All Emacs Lisp files there are loaded automatically
by Prelude.")
(defvar prelude-vendor-dir (concat prelude-dir "vendor/")
  "This directory house Emacs Lisp packages that are not yet available in
ELPA (or MELPA).")
(defvar prelude-snippets-dir (concat prelude-dir "snippets/")
  "This folder houses addition yasnippet bundles distributed with Prelude.")

;; add Prelude's directories to Emacs's `load-path'
(add-to-list 'load-path prelude-modules-dir)
(add-to-list 'load-path prelude-vendor-dir)

;; the core stuff
(require 'prelude-packages)
(require 'prelude-ui)
(require 'prelude-core)
(require 'prelude-mode)
(require 'prelude-editor)
(require 'prelude-global-keybindings)

(require 'ac-slime)

;; OSX specific settings
(when (eq system-type 'darwin)
  (require 'prelude-osx))

;; config changes made through the customize UI will be store here
(setq custom-file (concat prelude-personal-dir "custom.el"))

;; load the personal settings (this includes `custom-file')
(when (file-exists-p prelude-personal-dir)
  (mapc 'load (directory-files prelude-personal-dir 't "^[^#].*el$")))

(message "Prelude is ready to do thy bidding, Master %s!" (getenv "USER"))

(prelude-eval-after-init
 ;; greet the use with some useful tip
 (run-at-time 5 nil 'prelude-tip-of-the-day))

;; Make sure all backup files only live in one place
(setq backup-directory-alist '(("." . "~/.emacs.d/backups")))

(menu-bar-mode -1)
(scroll-bar-mode -1)
(add-hook 'prog-mode-hook 'prelude-turn-off-whitespace t)
(guru-mode -1)

(require 'org-install)
(require 'ob)
(require 'htmlize)
(require 'ruby-mode)

;; (setq org-export-htmlize-output-type 'css)

(org-babel-do-load-languages
 'org-babel-load-languages
 '((R . t)
   (emacs-lisp . t)
   (gnuplot . t)
   (python . t)
   (ruby . t)
   (sh . t)))

;;Shift the selected region right if distance is postive, left if
;; negative

(defun shift-region (distance)
  (let ((mark (mark)))
    (save-excursion
      (indent-rigidly (region-beginning) (region-end) distance)
      (push-mark mark t t)
      ;; Tell the command loop not to deactivate the mark
      ;; for transient mark mode
      (setq deactivate-mark nil))))

(defun shift-right ()
  (interactive)
  (shift-region 2))

(defun shift-left ()
  (interactive)
  (shift-region -2))

(defun max-frame ()
  (interactive)
  (tool-bar-mode 1)
  (tool-bar-mode 0)
  (set-frame-width (selected-frame) 203)
  (set-frame-position (selected-frame) 0 -13))

(require 'auto-complete)
(require 'auto-complete-config)

(add-hook 'slime-mode-hook 'set-up-slime-ac)
(add-hook 'slime-repl-mode-hook 'set-up-slime-ac)
(eval-after-load "auto-complete"
  '(add-to-list 'ac-modes 'slime-repl-mode))

(add-to-list 'load-path "~/.emacs.d/vendor/emacs-powerline")
(require 'powerline)

(setq powerline-arrow-shape 'arrow)

;; (custom-set-faces
;;    ;; Mode-line / status line
;;    '(mode-line
;;      ((t (:background "#0b283d" :box nil :foreground "#0c86e4" :height 85))))

;;    '(mode-line-inactive
;;      ((t (:weight light :box nil :background "#002339" :foreground "#000000" :inherit (mode-line)))))
;;    '(mode-line-emphasis
;;      ((t (:weight bold))))

;;    '(mode-line-highlight
;;      ((t (:box nil (t (:inherit (highlight)))))))

;;    '(mode-line-buffer-id
;;      ((t (:weight bold :box nil)))) )

(display-time-mode 1)

(setq display-time-day-and-date t
      display-time-24hr-format t)
(display-time)

(require 'smart-tab)
(define-key read-expression-map [(tab)] 'hippie-expand)

(add-to-list 'hippie-expand-try-functions-list
             'yas/hippie-try-expand) ;put yasnippet in hippie-expansion list

(setq smart-tab-using-hippie-expand t)
(global-smart-tab-mode t)
;; (global-cua-mode t)

(defun hippie-unexpand ()
  (interactive)
  (hippie-expand 0))

(define-key read-expression-map [(shift tab)] 'hippie-unexpand)


;; Bind (shift-right) and (shift-left) function to your favorite keys. I use
;; the following so that Ctrl-Shift-Right Arrow moves selected text one
;; column to the right, Ctrl-Shift-Left Arrow moves selected text one
;; column to the left:

(global-set-key [C-S-right] 'shift-right)
(global-set-key [C-S-left] 'shift-left)

;; Jump to a definition in the current file. (This is awesome.)
(global-set-key "\C-x\C-i" 'ido-imenu)

(global-set-key (kbd "C-x C-p") 'find-file-at-point)
(global-set-key (kbd "C-c f") 'max-frame)

;; Use command as the meta key
;; (setq ns-command-modifier (quote meta))

(ac-set-trigger-key "M-TAB")

;; (global-unset-key "C-_")
;; global-set-key (kbd "C-z") 'undo)
(global-set-key (kbd "C-c x") 'repeat-complex-command)

(add-to-list 'custom-theme-load-path "~/.emacs.d/themes")

(when (window-system)
  (require 'hideshowvis)

  (add-to-list 'hs-special-modes-alist
               '(ruby-mode
                 "\\(def\\|do\\|{\\)" "\\(end\\|end\\|}\\)" "#"
                 (lambda (arg) (ruby-end-of-block)) nil))

  (dolist (hook (list 'emacs-lisp-mode-hook
                      'lisp-mode-hook
                      'ruby-mode-hook
                      'perl-mode-hook
                      'php-mode-hook
                      'python-mode-hook
                      'lua-mode-hook
                      'c-mode-hook
                      'java-mode-hook
                      'js-mode-hook
                      'css-mode-hook
                      'c++-mode-hook))
    (add-hook hook 'hideshowvis-enable)))

(provide 'init-hideshowvis)

(define-fringe-bitmap 'hs-marker [0 24 24 126 126 24 24 0])

(defcustom hs-fringe-face 'hs-fringe-face
  "*Specify face used to highlight the fringe on hidden regions."
  :type 'face
  :group 'hideshow)

(defface hs-fringe-face
  '((t (:foreground "#888" :box (:line-width 2 :color "grey75" :style released-button))))
  "Face used to highlight the fringe on folded regions"
  :group 'hideshow)

(defcustom hs-face 'hs-face
  "*Specify the face to to use for the hidden region indicator"
  :type 'face
  :group 'hideshow)

(defface hs-face
  '((t (:background "#444" :box t)))
  "Face to hightlight the ... area of hidden regions"
  :group 'hideshow)

(defun display-code-line-counts (ov)
  (when (eq 'code (overlay-get ov 'hs))
    (let* ((marker-string "*fringe-dummy*")
           (marker-length (length marker-string))
           (display-string (format "(%d)..." (count-lines (overlay-start ov) (overlay-end ov))))
           )
      (overlay-put ov 'help-echo "Hiddent text. C-c,= to show")
      (put-text-property 0 marker-length 'display (list 'left-fringe 'hs-marker 'hs-fringe-face) marker-string)
      (overlay-put ov 'before-string marker-string)
      (put-text-property 0 (length display-string) 'face 'hs-face display-string)
      (overlay-put ov 'display display-string)
      )))

(setq hs-set-up-overlay 'display-code-line-counts)

;; comment/uncomment region
(global-set-key "\C-c\C-c" 'comment-or-uncomment-region)

;;M-up/down -> start/end of buffer.
;;(global-set-key (kbd "M-<up>")) 'beginning-of-buffer
;;(global-set-key (kbd "M-<down>") 'end-of-buffer)
(global-set-key (kbd "M-[") 'beginning-of-buffer)
(global-set-key (kbd "M-]") 'end-of-buffer)

(global-unset-key (kbd "M-<up>"))
(global-unset-key (kbd "M-<down>"))

;; Window manipulation
(global-set-key (kbd "M-<left>")  'enlarge-window-horizontally)
(global-set-key (kbd "M-<right>") 'shrink-window-horizontally)
(global-set-key (kbd "M-<down>")  'enlarge-window)
(global-set-key (kbd "M-<up>")    'shrink-window)

;; Find stuff
(global-set-key [(f2)]              'ack-default-directory)
(global-set-key [(control f2)]      'ack-same)
(global-set-key [(control meta f2)] 'ack)
(global-set-key [(meta f2)]         'find-name-dired)
(global-set-key [(shift f2)]        'occur)

(setq org-todo-keywords
      '((sequence "TODO(t)" "|" "DONE(d)")
        (sequence "BUG(b)" "IN PROGRESS(i)"  "|" "FIXED(f)")
        (sequence "|" "CANCELED(c)")))

(setq org-fast-tag-selection-include-todo t)
(setq org-use-fast-todo-selection t)

;; (global-linum-mode 1)



;;; init.el ends here
