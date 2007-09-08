;; emacs init.el - Florian Ebeling

(add-to-list 'load-path "~/.emacs.d")

(setq default-frame-alist '((top . 1) (left . 1) (width . 130) (height . 44)))
(speedbar)

(defun ruby-spec-p (filename)
  (string-match "spec\.rb$" filename))

(defun ruby-test-p (filename)
  (string-match "test\.rb$" filename))

(defun ruby-any-test-p (filename)
  (or (ruby-spec-p filename)
      (ruby-test-p filename)))

(defun odd-p (i) (= 1 (mod i 2)))

(defun even-p (i) (= 0 (mod i 2)))

(defun select (ls fn)
  (let ((res nil))
    (dolist (elt ls res)
      (if (funcall fn elt)
	  (sefq res (cons elt res))))))

(defun select (fn ls)
  (let ((result nil))
    (dolist (item ls)
      (if (funcall fn item)
	  (setq result (cons item res))))
    (reverse result)))

(defun ruby-run-buffer-file-as-test ()
  "Run buffer's file or first visible window file as ruby test (rspec or test/unit)."
  (interactive)
  (let ((file (buffer-file-name))
	(fname "ruby-run-buffer-file-as-test"))
    (flet ((run-spec (file)
		     (message "Running spec...")
		     (shell-command (format "spec %s" file))
		     (message "Spec done."))
	   (run-test (file)
		     (message "Running unit tests...")
		     (shell-command (format "/opt/local/bin/ruby %s" file)) ;; fix with interactive shell, etc.
		     (message "Tests done.")))
      (if file 
	  (cond
	   ((ruby-spec-p file) (run-spec file))
	   ((ruby-test-p file) (run-test file))
	   (t (let ((test-file)
		    (select 'ruby-any-test-p (mapcar 
					      (lambda (wn) 
						(buffer-file-name wn))
					      (window-list))))
		(if visible-test-file
		    (cond
		     ((ruby-spec-p visible-test-file)
		      (run-spec visible-test-file))
		     ((ruby-test-p visible-test-file)
		      (run-test visible-test-file))
		     (t (message "SHOULD NOT GET HERE.")))
		  (message "No test among visible buffers.")))))))))

(global-set-key (kbd "C-x t") 'ruby-run-buffer-file-as-test)

(defun pull-line-up ()
  "Drags a line up by one, and moves point accordingly."
  (interactive)
  (transpose-lines 1)
  (forward-line -2))

(global-set-key [M-up] 'pull-line-up)

(defun pull-line-down ()
  "Drags a line down by one, and moves point accordingly."
  (interactive)
  (forward-line 1)
  (transpose-lines 1)
  (forward-line -1))

(global-set-key [M-down] 'pull-line-down)

(defun indent-buffer ()
  ;; Author: Mathias Creutz
  "Indent every line in the buffer."
  (interactive)
  (indent-region (point-min) (point-max) nil))

;; shadows tab-to-tab-stop binding.
(global-set-key "\M-i" 'indent-buffer)

(defun symq ()
  "symbol quote, puts double quotes around word."
  (interactive)
  (save-excursion 
    (if (not (word-beginning-p)) 
	(backward-word 1))
    (insert-char ?\" 1)
    (forward-word 1)
    (insert-char ?\" 1))
  (forward-word 2))

(global-set-key [f8] 'symq)

(defun word-beginning-p ()
  (interactive)
  (word-boundary 'car))

(defun word-ending-p ()
  (interactive)
  (word-boundary 'cdr))

(defun word-boundary (func)
  (if (equal (funcall func (bounds-of-thing-at-point 'word)) (point))
      (progn 
	(message "cursor is at a word boundary")
	t)
    nil))

(let ((hostname (system-name)))
  (cond
   ((equal hostname "dev14.iconmobile.de")
    (message "Intializing for host %s" hostname)
    (require 'psvn)
    (find-file "~/TODO"))
   (nil ;; todo: somehow test for ubuntu laptop
    (message "Intializing for host %s" hostname)
    (let ((slime-dir-path "~/slime"))
      (if (file-exists-p slime-dir-path)
	  (add-to-list 'load-path slime-dir-path)
	(with-output-to-temp-buffer "*slime init warnings*" 
	  (princ (format "slime-dir-path does not exist: '%s'" slime-dir-path))))))
   ((equal hostname "flomac.local")
    (message "Initializing for host %s" hostname)
    (setq otp-path "/opt/local/lib/erlang/lib/tools-2.5.5/emacs/")
    (setq load-path (cons otp-path load-path))
    (setq erlang-root-dir "/opt/local/bin")
    (setq exec-path (cons "/opt/local/lib/erlang" exec-path))
    (require 'erlang-start)
    (load "osx" t))
))

(ido-mode)

;;(setq make-backup-files nil)
(setq default-case-fold-search t)
(setq auto-compression-mode t)
(setq-default uniquify-buffer-name-style 'post-forward)
(setq-default tab-width 8)

(global-font-lock-mode 1)
(show-paren-mode 1)

;; for emacsclient
(server-start) 

(defalias 'qrr 'query-replace-regexp)
(defalias 'qr 'query-replace)
(defalias 'cr 'comment-region)
(defalias 'ucr 'uncomment-region)
(defalias 'ir 'indent-region)
(defalias 'bb 'beginning-of-buffer)
(defalias 'eb 'end-of-buffer)

(setq-default abbrev-file-name "~/.emacs.d/abbrev_defs")
(setq-default abbrev-mode t)
(read-abbrev-file)
(setq save-abbrevs nil)

(defun insert-date ()
  "Insert the current date at point"
  (interactive)
  (insert (format-time-string "%d.%m.%y")))

(if (fboundp 'scroll-bar-mode) (scroll-bar-mode -1)) 
(if (fboundp 'tool-bar-mode) (tool-bar-mode -1)) 
;(if (fboundp 'menu-bar-mode) (menu-bar-mode -1)) 

;; enable copy-paste within X Window under Linux
(setq x-select-enable-clipboard t)
(if x-no-window-manager
    (progn 
      (setq interprogram-paste-function 'x-cut-buffer-or-selection-value)
      (message "cut-and-paste with x enabled")))

(defun scroll-up-1 ()
  (interactive)
  (scroll-up 1))

(define-key global-map [S-down] 'scroll-up-1)

(defun scroll-down-1 ()
  (interactive)
  (scroll-down 1))

(define-key global-map [S-up] 'scroll-down-1)

;;; general key remapping

;; free strokes
;; C-# -> as new/custom duplicate-line keybinding  
;; M-p 
;; C-. 
;; C-f8 -> make ruby local_var from region

(global-set-key (kbd "C-.") 'find-file-at-point)

(fset 'to-java-string
      [?\C-a ?" ?\C-e ?" ?  ?+ down])
(global-set-key [f6] 'to-java-string)
(fset 'purge-line
      [?\C-a ?\C-  ?\C-n ?\C-c ?\C-k])
(global-set-key [\C-K] 'purge-line)
(fset 'mark-as-done
      [?\C-e ?  ?( ?\M-x ?i ?n ?s ?e ?r ?t ?- ?d ?a ?t ?e return ?) ?\C-a ?\C-k ?\C-k ?\C-s ?D ?O ?N ?E ?\C-m return ?\C-y ?\C-k ?\C-r ?T ?O ?D ?O ?\C-m ?\C-n])
(global-set-key [f2] 'mark-as-done)
(fset 'ruby-extract-local
   [?\C-x ?\C-k ?\C-p ?\C-e return ?\C-y ?\C-a tab ?= ?  ?\C-b ?\C-b])
(global-set-key [C-f6] 'ruby-extract-local)

(global-set-key [f5] 'call-last-kbd-macro)
(global-set-key [f3] 'edit-last-kbd-macro)
(global-set-key (kbd "C-S-l") 'goto-line)
(global-set-key (kbd "C-+") 'other-window)
(global-set-key (kbd "C-z") 'yank) ;; using a us key layout, this makes sense.
(global-set-key [C-tab] 'indent-line)



(global-set-key "\C-c\C-m" 'execute-extended-command)
;(global-set-key "\C-x\C-m" 'execute-extended-command)

(global-set-key "\C-w" 'backward-kill-word)
;(global-set-key "\C-c\C-k" 'kill-region)
(global-set-key "\C-x\C-k" 'kill-region)

;;;;;
;; (defvar ffap-ruby-path '("~/dev/rptn/test/" "~/dev/rptn/lib/"))

;; (defun ffap-ruby-mode (name)
;;   (message "ffap-ruby-mode, in")
;;   (message "name: %s" name)
;;   (ffap-locate-file name '(".rb" ".rhtml" ".cap" "") ffap-ruby-path t)
;;   (message "ffap-ruby-mode, return"))

;; (add-to-list 'ffap-alist '("\\.rb\\'" . ffap-ruby-mode))

;;ffap-alist

;;auto-mode-alist


;;(setq auto-mode-alist (cdr auto-mode-alist))
;;;;;

(autoload 'css-mode "css-mode")
(setq auto-mode-alist       
      (cons '("\\.css\\'" . css-mode) auto-mode-alist))

(add-to-list 'auto-mode-alist '("\\.[Cc][Ss][Vv]\\'" . csv-mode))
(autoload 'csv-mode "csv-mode"
  "Major mode for editing comma-separated value files." t)


(add-hook 'nxml-mode-hook '(lambda () (define-key nxml-mode-map [C-tab] 'nxml-complete)))

(require 'snippet)

(snippet-with-abbrev-table 
 'c-mode-abbrev-table
 ("tc" . "START_TEST ($${test_name})
{
$.fail(\"+++\");
}
END_TEST
")
 ("inc" . "#include \"$${header}.h\"")
 ("ins" . "#include <$${header}.h>")
 ("hf" . "#ifndef $${name}_H
#define $${name}_H

$.

#endif /* $${name}_H */
")
 ("tca" . "tcase_add_test(tc_core, test_$${name});$>"))

(snippet-with-abbrev-table 
 'ruby-mode-abbrev-table
 ("def" . "def$.

  end"))

(add-hook 'cperl-mode-hook 
	  '(lambda () 
	     (snippet-with-abbrev-table 
	      'cperl-mode-abbrev-table
	      ("head" . "=head3$.\n\n=cut\n"))))

(require 'slime)
;;; Optionally, specify the lisp program to use. Default is "lisp"
;(setq inferior-lisp-program "cmucl") 
;(setq inferior-lisp-program "clisp -K full") 
(setq inferior-lisp-program "sbcl")
;(setq inferior-lisp-program "guile")
;(setq inferior-lisp-program "scheme48")
(slime-setup)

(add-hook 'slime-mode-hook
	  (lambda ()
	    (unless (slime-connected-p)
	      (save-excursion (slime)))))

(setq slime-net-coding-system 'utf-8-unix)

;; from slime/HACKING:
(defun show-outline-structure ()
  "Show the outline-mode structure of the current buffer."
  (interactive)
  (occur (concat "^" outline-regexp)))

(require 'ruby-mode)

(setq auto-mode-alist (cons '("\\.cap\\'" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.rb\\'" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.rake\\'" . ruby-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.rhtml\\'" . html-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.smil\\'" . sgml-mode) auto-mode-alist))
(setq auto-mode-alist (cons '("\\.asd\\'" . lisp-mode) auto-mode-alist))

;; (add-to-list 'load-path "~/Development/emacs-rails-svn")
;; (defun try-complete-abbrev (old)
;;   (if (expand-abbrev) t nil))
;; (setq hippie-expand-try-functions-list
;;       '(try-complete-abbrev
;; 	try-complete-file-name
;; 	try-expand-dabbrev))
;; (condition-case ()
;;     (require 'rails)
;;   (error (message "  rails not present - error on loading")))

(custom-set-variables
  ;; custom-set-variables was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(safe-local-variable-values (quote ((cperl-indent-level . 4) (cperl-indent-level . 2)))))
(custom-set-faces
  ;; custom-set-faces was added by Custom.
  ;; If you edit it by hand, you could mess it up, so be careful.
  ;; Your init file should contain only one such instance.
  ;; If there is more than one, they won't work right.
 '(default ((t (:stipple nil :background "white" :foreground "black" :inverse-video nil :box nil :strike-through nil :overline nil :underline nil :slant normal :weight normal :height 160 :width normal :family "apple-monaco")))))
