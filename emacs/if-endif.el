;;; IF-ENDIF.EL - Short description here
;;; Copyright (C) 2017 Dr.Sc.KAWAMOTO,Takuji (Ext)
;;;
;;; This program is free software; you can redistribute it and/or modify
;;; it under the terms of the GNU General Public License as published by
;;; the Free Software Foundation; either version 1, or (at your option)
;;; any later version.
;;;
;;; This program is distributed in the hope that it will be useful,
;;; but WITHOUT ANY WARRANTY; without even the implied warranty of
;;; MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
;;; GNU General Public License for more details.
;;;
;;; A copy of the GNU General Public License can be obtained from this
;;; program's author (send electronic mail to <kawamoto@spike.anavas>) or from
;;; the Free Software Foundation, Inc., 675 Mass Ave, Cambridge, MA
;;; 02139, USA.
;;;

;;;
;;; ifendif command related
;;;      gray out C/C++ source lines invalidated by `if directives'.
;;;
;;; After installation, install ifendif, cmdrecplay and clang too.
;;; Write the followings in your `init.el` file.
;;;
;;;     (autoload 'if-endif-gray-out-invalidated "if-endif"
;;;        "Gray out C/C++ source lines invalidated by `if directives'." t)
;;;     (autoload 'if-endif-gray-out-invalidated-all-buffers "if-endif"
;;;        "Gray out C/C++ source lines invalidated by `if directives'." t)
;;;     (add-hook 'c-mode-common-hook 'if-endif-gray-out-invalidated)
;;;     (global-set-key (kbd "C-c i") 'if-endif-gray-out-invalidated)
;;;     (global-set-key (kbd "C-c I") 'if-endif-gray-out-invalidated-all-buffers)
;;;
;;; To associate with the `compile' command, write as follows too.
;;;
;;;     (require 'if-endif)
;;;     (setq compile-command "LANG=C cmdrec -- make -k ")
;;;     (advice-add 'compile :around #'if-endif-advice-around-compile)
;;;     (advice-add 'recompile :around #'if-endif-advice-around-compile)
;;;
;;; First, compile your soruce codes by,
;;;
;;;     cmdrec -- clang -D...<etc> your_source_code.c
;;;
;;; or
;;;
;;;     cmdrec -- make
;;;
;;; Next, execute emacs and find-file 'your_source_code.c'.
;;; When editing is repeated and the display becomes distorted, enter 'C-c i' and
;;; redisplay it.
;;; Also, if you change the macro definition of the makefile, re-execute
;;; 'cmdrec - make' and enter 'C-c i' to redisplay it.
;;;

(defgroup if-endif nil
  "gray out invalidated code by #if #endif directives."
  :group 'c)

(defface if-endif-shadow '((t (:inherit shadow)))
  "Face for shadowing regions invalidated by #if #endif directives."
  :group 'if-endif
  :version "23.1")

(defun if-endif-gray-out-region (start end)
  (remove-overlays start end 'if-endif t)
  (let ((o (make-overlay start end)))
    (overlay-put o 'if-endif t)
    (overlay-put o 'face 'if-endif-shadow)))

(defun if-endif-show-region (start end)
  "Everything between START and END is made visible."
  (remove-overlays start end 'if-endif t))

(defun if-endif-gray-out-line (point)
  "Gray out the line containing point."
  (save-excursion
    (goto-char point)
    (if-endif-gray-out-region (line-beginning-position)
                              (progn (end-of-line) (point)))))

(defun if-endif-show-line (point)
  "Show the line containing point."
  (save-excursion
    (goto-char point)
    (if-endif-show-region (line-beginning-position)
                          (progn (end-of-line) (point)))))

(defun if-endif-gray-out-lines (start-line-number end-line-number)
  "Gray out the lines."
  (save-excursion
    (if-endif-gray-out-region
     (progn (goto-line start-line-number) (line-beginning-position) (point))
     (progn (goto-line end-line-number) (end-of-line) (point)))))

(defun if-endif-show-lines (start-line-number end-line-number)
  "Show the lines."
  (save-excursion
    (if-endif-show-region
     (progn (goto-line start-line-number) (line-beginning-position) (point))
     (progn (goto-line end-line-number) (end-of-line) (point)))))

(defun if-endif-show-lines-to-end-of-file (start-line-number)
  "Show the lines."
  (save-excursion
    (if-endif-show-region
     (progn (goto-line start-line-number) (line-beginning-position) (point))
     (point-max))))

(defun if-endif-show-all ()
  "Show all lines."
  (interactive)
  (if-endif-show-region 1 (point-max)))

(defun if-endif-gray-out-current-line ()
  "Gray out the current line."
  (interactive)
  (if-endif-gray-out-line (point)))

(defun if-endif-show-current-line ()
  "Show the current line."
  (interactive)
  (if-endif-show-line (point)))

(defun if-endif-gray-out-invalidated ()
  "Gray out the lines invalidated by #if #endif directives."
  (interactive)
  (let ((arg (format "%s" buffer-file-name))
        (nextline 1)
        (doexec nil))
    ;;(message (format "if-endif-gray-out-invalidated buffer-name=%s" (buffer-name)))
    ;;(message (format "if-endif-gray-out-invalidated buffer-file-name=%s" arg))
    (when buffer-file-name
      (save-excursion
        (set-buffer "*if-endif output*")
        (erase-buffer)
        (call-process "ifendif" nil "*if-endif output*" nil "-e" arg)
        (goto-line 2)
        (setq nextline (- (point) 1))
        (setq doeval (string= (buffer-substring 1 2) "("))
        (if doeval
            nil
          (goto-char 1)
          (search-forward " ")
          (message (buffer-substring (point) nextline))
          ))
      (if doeval (eval-buffer (get-buffer "*if-endif output*"))))))

(defun if-endif-gray-out-invalidated-buffer (buffer)
  (save-excursion
    (set-buffer buffer)
    (if (or (eq major-mode 'c-mode) (eq major-mode 'c++-mode))
        (if-endif-gray-out-invalidated))))

(defun if-endif-gray-out-invalidated-all-buffers ()
  "Gray out the lines invalidated by #if #endif directives for all buffers."
  (interactive)
  (mapcar 'if-endif-gray-out-invalidated-buffer (buffer-list)))

(defun if-endif-sentinel (process event)
  (when (string= event "finished\n")
    (mapcar 'if-endif-gray-out-invalidated-buffer (buffer-list))))

(defun if-endif-advice-around-compile (f &rest args)
  "Gray out the lines invalidated by #if #endif directives for all buffers."
  (let ((ret (apply f args)))
    (message "if-endif-advice-around-compile called")
    (set-process-sentinel (get-buffer-process ret) 'if-endif-sentinel)
    ret))

(add-hook 'after-save-hook 'if-endif-gray-out-invalidated-all-buffers)

(get-buffer-create "*if-endif output*")

(provide 'if-endif)
