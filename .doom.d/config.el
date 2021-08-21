;;; EMACS INSTALL:
;;;

;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;;; BREW COMMMAND: --with-natural-title-bar

;;; EMACS-BUILD COMMAND: ./build-emacs-for-macos --git-sha fd9e9308d27138a16e2e93417bd7ad4448fea40a feature/native-comp --native-full-aot

;; startup fullscreen
;(toggle-frame-maximized)
(map! "C-M-<return>" #'toggle-frame-maximized)

;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets.
(setq user-full-name "Andy Han"
      user-mail-address "minqhan@gmail.com")

;; 80 character test:
;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;;

;;;;; MONOSPACE
;;; S TIER
;; (setq doom-font (font-spec :family "mononoki" :size 14))  ;; v nice but no ligs
(setq doom-font (font-spec :name "Operator Mono Lig Book" :size 15))  ;; super nice, with ligs
;; (setq doom-font (font-spec :family "Fantasque Sans Mono" :size 16))  ;; love it. and the size 16 means size 16
;; (setq doom-font (font-spec :family "Hack" :size 14))  ;; also good
;; (setq doom-font (font-spec :family "Dank Mono" :size 14)) ;; good

;;; A TIER
;; (setq doom-font (font-spec :family "Fira Code" :size 13))  ;; spacing is a bit much

;;; B TIER
;; (setq doom-font (font-spec :family "Monoid" :size 12))

;;; C TIER
;; (setq doom-font (font-spec :family "Gintronic" :size 14)) ;; so bad lol
;; (setq doom-font (font-spec :family "Go Mono"))  ;; do NOT like the serifs

;;; UNTIERED
;; (setq doom-font (font-spec :family "Sudo" :size 17))  ;; pretty narrow
;; (setq doom-font (font-spec :family "APL385 Unicode" :size 14))  ;; kinda... flat?
;; (setq doom-font (font-spec :family "Iosevka" :size 15))
;; (setq doom-font (font-spec :family "Cascadia Code" :size 14))  ;; like this one!
;; (setq doom-font (font-spec :family "IBM Plex Mono" :size 14))  ;; nah
;; (setq doom-font (font-spec :family "Source Code Variable" :size 14))
;; (setq doom-font (font-spec :family "Noto Mono" :size 14))  ;; line spacing kinda tight
;; (setq doom-font (font-spec :family "Victor Mono" :size 14)) ;; pretty cool but thin

;;;;;; sans serif
;;; S TIER
;; (setq doom-variable-pitch-font (font-spec :family "Ideal Sans"))
;;(setq doom-variable-pitch-font (font-spec :family "Tisa Sans Pro" :size 16))

;;; A TIER

;;; UNTIERED

;; (setq doom-variable-pitch-font (font-spec :family "Overpass" :size 14))
(setq doom-variable-pitch-font (font-spec :family "Source Sans Pro"))

;; (setq doom-variable-pitch-font (font-spec :family "Tofino Personal" :size 14))  ;; too thin
;; (setq doom-variable-pitch-font (font-spec :family "PF Bague Sans Pro" :size 14))  ;; too thick
;; (setq doom-variable-pitch-font (font-spec :family "VAG Rounded Next" :size 14))
;; (setq doom-variable-pitch-font (font-spec :family "Alegreya Sans" :size 14))
;; (setq doom-variable-pitch-font "IBM Plex Sans-16")
;; (setq doom-variable-pitch-font "Optima")

;; serif
;; (setq doom-variable-pitch-font (font-spec :family "Archer Screensmart"))
;; (setq doom-variable-pitch-font (font-spec :family "Sentinel"))
;; (setq doom-variable-pitch-font (font-spec :family "Mercury Text G4"))
;; (setq doom-variable-pitch-font (font-spec :family "Charter" :size 14))  ; don't love
;; (setq doom-variable-pitch-font (font-spec :family "Arvo" :size 16))
;; (setq doom-variable-pitch-font (font-spec :family "Cardo" :size 14))
;; (setq doom-variable-pitch-font (font-spec :family "Lehigh Commercial" :size 14))
;; (setq doom-variable-pitch-font (font-spec :family "Tisa Pro" :size 14))
;; (setq doom-variable-pitch-font (font-spec :family "Alegreya" :size 14))

(setq doom-font-increment 1)

(setq doom-scratch-initial-major-mode #'emacs-lisp-mode)

(setq doom-theme 'doom-palenight)
(setq amh-light-themes
      '(doom-one-light
        doom-nord-light
        doom-acario-light
        doom-opera-light
        doom-solarized-light
        doom-tomorrow-day
        doom-gruvbox-light  ; yellow background is kinda weird but ok
        ;doom-fairy-floss  ;; too soft but i like how this makes keywords italic
        ))
(setq amh-dark-themes
      '(
        ;; doom-one  ;; comments not italic
        doom-palenight  ;; comments not italic
        ; doom-nord  ;; too soft. can't read shit.
        doom-laserwave  ;; comments not italic 
        doom-dracula  ;; comments not italic
        doom-gruvbox  ;; comments not italic
        doom-vibrant  ;; comments not italic
        ;; doom-acario-dark  ; black background. don't fw
        doom-challenger-deep  ;; comments not italic
        doom-dark+  ;; comments not italic
        doom-horizon  ;; ooh i like this one but org todos are colored bad. comments italic
        doom-manegarm  ;; comments weirdly big and slanted (not italic)
        doom-moonlight  ;; comments not italic
        ;doom-outrun-electric  ;; too bold. black background.
        doom-snazzy  ;; comments not italic
        ; doom-spacegrey  ; a little too minimalistic. org headings don't stand out
        ; doom-ephemeral  ; too light on comments
        doom-rouge  ; i like this one a lot! comments italic. but no hl-line
        doom-henna
        ))

(defun amh-set-theme (&optional luminence)
  "With prefix, pick random light theme. Otherwise, dark theme."
  (interactive "P")
  (let ((luminence-list nil)
        (theme-number 0))
    (if luminence  ; select the right luminence
        ;; light case
        (setq luminence-list amh-light-themes)
      ;; dark case
      (setq luminence-list amh-dark-themes))
    ; pick a random theme index
    (progn
      (setq theme-number (random (list-length luminence-list)))
      (setq doom-theme (nth theme-number luminence-list))
      (doom/reload-theme))
    (message "loaded theme %s" doom-theme)))

;; set random theme if graphic window. if terminal, use doom-rouge.
;; (if (display-graphic-p)
;;     (amh-set-theme)
;;   (setq doom-theme 'doom-rouge))

(custom-set-faces! '(font-lock-comment-face :slant italic))

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
(setq display-line-numbers-type nil)
(setq display-line-numbers-width 0)
; (add-hook! 'org-mode-hook (setq display-line-numbers nil))
; (add-hook! 'prog-mode-hook (setq display-line-numbers 'relative))

;; disable smooth scrolling
(setq mac-mouse-wheel-mode nil)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/org/")
; set default major mode to fundamental
(setq-default major-mode 'fundamental-mode)
;; hide // and == in org

(after! ox-latex
  (add-to-list 'org-latex-classes
               '("scrartcl" "\\documentclass{scrartcl}"
                 ("\\section{%s}" . "\\section*{%s}")
                 ("\\subsection{%s}" . "\\subsection*{%s}")
                 ("\\subsubsection{%s}" . "\\subsubsection*{%s}")
                 ("\\paragraph{%s}" . "\\paragraph*{%s}")
                 ("\\subparagraph{%s}" . "\\subparagraph*{%s}"))))

(after! org
  ;; make html export html5
  (setq org-html-doctype "html5")
  (setq org-latex-compiler "xelatex")
  (set-company-backend! 'org-mode 'company-emoji)
  (setq org-hide-emphasis-markers t)
  (setq org-log-into-drawer 'LOGBOOK)
  (setq org-ellipsis " ▼ ")
  ;; make org list bullets change after demote
  ;(setq org-list-demote-modify-bullet '(("+" . "-") ("-" . "+") ("*" . "+")))
  ;; make latex previews high res and good size
  (setq org-latex-create-formula-image-program 'dvisvgm
        org-format-latex-options (plist-put org-format-latex-options :scale 1.2))

  (map! "\C-c1" 'org-time-stamp-inactive)
  (map! "s-SPC" '+org/dwim-at-point)
  (map! :map org-mode-map
        "C-," #'nil
        "C-<" #'org-promote-subtree
        "C->" #'org-demote-subtree)

  (add-hook! 'org-mode-hook #'mixed-pitch-mode)
                                        ; (add-hook! 'org-mode-hook #'org-fragtog-mode)  ; seems to slow down C-h k
  (setq org-capture-templates
        '(("t" "Personal todo" entry
           (file+headline +org-capture-todo-file "Inbox")
           "* TODO %?\n%i\n%a" :prepend t)
          ;; ("n" "Personal notes" entry
          ;;  (file+headline +org-capture-notes-file "Inbox")
          ;;  "* %u %?\n%i\n%a" :prepend t)
          ;; ("j" "Journal" entry
          ;;  (file+olp+datetree +org-capture-journal-file)
          ;;  "* %U %?\n%i\n%a" :prepend t)
          ;; ("p" "Templates for projects")
          ;; ("pt" "Project-local todo" entry
          ;;  (file+headline +org-capture-project-todo-file "Inbox")
          ;;  "* TODO %?\n%i\n%a" :prepend t)
          ;; ("pn" "Project-local notes" entry
          ;;  (file+headline +org-capture-project-notes-file "Inbox")
          ;;  "* %U %?\n%i\n%a" :prepend t)
          ;; ("pc" "Project-local changelog" entry
          ;;  (file+headline +org-capture-project-changelog-file "Unreleased")
          ;;  "* %U %?\n%i\n%a" :prepend t)
          ;; ("o" "Centralized templates for projects")
          ;; ("ot" "Project todo" entry #'+org-capture-central-project-todo-file "* TODO %?\n %i\n %a" :heading "Tasks" :prepend nil)
          ;; ("on" "Project notes" entry #'+org-capture-central-project-notes-file "* %U %?\n %i\n %a" :heading "Notes" :prepend t)
          ;; ("oc" "Project changelog" entry #'+org-capture-central-project-changelog-file "* %U %?\n %i\n %a" :heading "Changelog" :prepend t)
          )
        )

  ;; My custom todo stuff. Primarily adds a SCHD keyword, which uses. My custom
  ;; faces need to have different names than Doom's.
  (with-no-warnings
    (custom-declare-face '+org-todo-act  '((t (:inherit (bold all-the-icons-blue-alt org-todo)))) "")
    (custom-declare-face '+org-todo-proj '((t (:inherit (bold all-the-icons-lpink org-todo)))) "")
    (custom-declare-face '+org-todo-scheduled '((t (:inherit (bold all-the-icons-lcyan org-todo)))) "")
    (custom-declare-face '+org-todo-maybe '((t (:inherit (bold all-the-icons-dsilver org-todo)))) "")
    (custom-declare-face '+org-todo-wait '((t (:inherit (bold all-the-icons-lyellow org-todo)))) ""))
  (setq org-todo-keywords
        '((sequence
           "TODO(t)"  ; A task that is in the inbox
           "PROJ(p)"  ; A project, which usually contains other tasks
                                        ;"LOOP(r)"  ; A recurring task
                                        ;"STRT(s)"  ; A task that is in progress
           "NEXT(n)" 
           "SCHD(s)"  ; A task that's scheduled
           "WAIT(w)"  ; Something external is holding up this task
           "HOLD(h)"  ; This task is paused/on hold because of me
           "MAYB(m)"  ; An unconfirmed and unapproved task or notion
           "|"
           "DONE(d)")  ; Task successfully completed
                                        ;"KILL(k)") ; Task was cancelled, aborted or is no longer applicable
          (sequence
           "[ ](T)"   ; A task that needs doing
           "[-](S)"   ; Task is in progress
           "[?](W)"   ; Task is being held up or paused
           "|"
           "[X](D)")  ; Task was completed
          (sequence
           "|"
           "OKAY(o)"
           "YES(y)"
           "NO(n)"))
        org-todo-keyword-faces
        '(("[-]"  . +org-todo-act)
          ("NEXT" . +org-todo-act)
          ("SCHD" . +org-todo-scheduled)
          ("MAYB" . +org-todo-maybe)
          ;("[?]"  . +org-todo-cancel)
          ("WAIT" . +org-todo-wait)
          ("HOLD" . +org-todo-wait)
          ("PROJ" . +org-todo-proj)
          ))

  (defun bjm/org-headline-to-top ()
    "Move the current org headline to the top of its section"
    (interactive)
    ;; check if we are at the top level
    (let ((lvl (org-current-level)))
      (cond
       ;; above all headlines so nothing to do
       ((not lvl)
        (message "No headline to move"))
       ((= lvl 1)
        ;; if at top level move current tree to go above first headline
        (org-cut-subtree)
        (beginning-of-buffer)
        ;; test if point is now at the first headline and if not then
        ;; move to the first headline
        (unless (looking-at-p "*")
          (org-next-visible-heading 1))
        (org-paste-subtree))
       ((> lvl 1)
        ;; if not at top level then get position of headline level above
        ;; current section and refile to that position. Inspired by
        ;; https://gist.github.com/alphapapa/2cd1f1fc6accff01fec06946844ef5a5
        (let* ((org-reverse-note-order t)
               (pos (save-excursion
                      (outline-up-heading 1)
                      (point)))
               (filename (buffer-file-name))
               (rfloc (list nil filename nil pos)))
          (org-refile nil nil rfloc))))))
  (defun amh/org-headline-up ()
    "WIP Move the current org agenda headline above the headline that's currently above it"
    (interactive)
    ;; save buffers to preserve agenda
    (org-save-all-org-buffers)
    (let ((above-item (save-excursion (org-agenda-switch-to)
                             (buffer-substring-no-properties (beginning-of-line) (end-of-line)))))
      (message above-item)
      )
    ;(org-cut-subtree)
    )
  (defun bjm/org-agenda-item-to-top ()
    "Move the current agenda item to the top of the subtree in its file"
    (interactive)
    ;; save buffers to preserve agenda
    (org-save-all-org-buffers)
    ;; switch to buffer for current agenda item
    (org-agenda-switch-to)
    ;; move item to top
    (bjm/org-headline-to-top)
    ;; go back to agenda view
    (switch-to-buffer "*Org Agenda*")
    ;; refresh agenda
    (org-agenda-redo))
  ;; bind to key 1
  (map! :map org-agenda-mode-map
        "C-c t" 'bjm/org-agenda-item-to-top)
  )

;; replace isearch with swiper
(after! ivy
  (map! "\C-s" #'swiper)
  (setq +ivy-buffer-preview t)  ; idk what this does

  ; speeds up swiper startup in visual line mode
  (setq swiper-use-visual-line nil)
  (setq swiper-use-visual-line-p
        (lambda (a) nil)))

(after! company
  ;; instant company
  (setq company-idle-delay 0)
  ;; longer prescient history
  (setq-default history-length 1000)
  (setq-default prescient-history-length 1000)
  ;; disable company-box-doc in lisp
  (add-hook! 'prog-mode-hook (setq company-box-doc-enable t))
  (add-hook! 'emacs-lisp-mode-hook (setq company-box-doc-enable nil))
  (setq company-dabbrev-minimum-length 7)
  ;; disable company in web-mode cause it's useless (only has HTML backend)
  ;; but see company-web section "use with company-tern" for js completion
  (add-hook! 'web-mode-hook (company-mode -1))
  (add-hook! 'web-mode-hook (company-box-mode -1))

  ;; unbind C-n and C-p from company-select-next/previous
  (map! :map company-active-map
      "C-n" #'nil
      "C-p" #'nil))

(use-package! lsp-mode
  :defer t
  :config
  (setq lsp-enable-links nil)
  (setq lsp-flycheck-live-reporting t)
  (setq lsp-signature-auto-activate nil)
  (setq read-process-output-max (* 1024 1024))  ;; 1mb
  ; (setq lsp-signature-render-documentation nil)

  ;; use flake8 for flycheck. throws an error, but seems to work?
  (add-hook! 'python-mode-hook (flycheck-select-checker 'python-flake8)))

;; (use-package! lsp-ui-mode
;;   :defer t
;;   :config
;;   (lsp-ui-mode)
;;   (lsp-ui-doc-mode)
;;   (setq lsp-ui-sideline-mode t)
;;   (setq lsp-ui-doc-enable t)
;;   (setq lsp-ui-doc-delay 0))

(use-package! lsp-python-ms
  :defer t
  :init
  ;; someone on #protips said this "substantially improved the ux"
  ;; this is supposed to have lsp use flake8 automatically, but it breaks stuff
  ;:hook
  ;; ('python-mode . (lambda ()
  ;;                                   (require 'lsp-python-ms)
  ;;                                   (lsp-deferred)
  ;;                                   (flycheck-add-next-checker 'python-flake8)))
  )

;; use mspyls
(after! lsp-python-ms
  (set-lsp-priority! 'mspyls 1)
  (setq python-prettify-symbols-alist
           '(;; Syntax
             ("def" .      #x2131)
             ("not" .      #x2757)
             ("in" .       #x2208)
             ("not in" .   #x2209)
             ("return" .   #x27fc)
             ("yield" .    #x27fb)
             ("for" .      #x2200)
             ;; Base Types
             ("int" .      #x2124)
             ("float" .    #x211d)
             ("str" .      #x1d54a)
             ("True" .     #x1d54b)
             ("False" .    #x1d53d)
             ;; Mypy
             ("Dict" .     #x1d507)
             ("List" .     #x2112)
             ("Tuple" .    #x2a02)
             ("Set" .      #x2126)
             ("Iterable" . #x1d50a)
             ("Any" .      #x2754)
             ("Union" .    #x22c3)))
  (add-hook! 'python-mode-hook #'prettify-symbols-mode))

(after! flycheck
  (setq flycheck-global-modes '(not org-mode text-mode)))

(after! blacken
  (setq-hook! 'python-mode-hook 'blacken-mode)
  ; allow python 3.6-only syntax
  (setq blacken-allow-py36 t))


;; emacs-mac (jap port) setup
(setq mac-option-modifier 'nil)  ; for exposing diacritical marks
(setq mac-command-modifier 'meta)
;;(mac-auto-operator-composition-mode t)
;; title bar pretty
(setq ns-use-proxy-icon nil)
(setq frame-title-format nil)
;; menu bar remove things. not removing all
;; things cause henrik said that messes things up
(map!
      [menu-bar file] nil
      [menu-bar options] nil
      [menu-bar edit] nil
      [menu-bar buffer] nil
      ;[menu-bar tools] nil   ; this one fucks things up 
      ;[menu-bar emacs-lisp] nil
      ;[menu-bar projectile-mode-menu] nil
      ;[menu-bar persp-minor-mode-menu] nil
      ;[menu-bar outline-mode-menu-bar-map] nil
      [menu-bar help-menu] nil)

(after! smartparens-mode
  (map! :map smartparens-mode-map
        "C-<right>" #'sp-forward-slurp-sexp
        "M-<right>" #'sp-forward-barf-sexp
        "C-<left>"  #'sp-backward-slurp-sexp
        "M-<left>"  #'sp-backward-barf-sexp))

(use-package! info-colors
  :defer t
  :commands (info-colors-fontify-node)
  :config
  (add-hook 'Info-selection-hook 'info-colors-fontify-node)
  (add-hook 'Info-mode-hook #'mixed-pitch-mode))

;; use bigger dictionary for aspell.
;; diacritic: both
;; max_size: 70
;; max_variant: 0
;; special: roman-numerals
;; spelling: US
;; my personal dictionary is stored in ~/.aspell.en.pws
(setq ispell-dictionary "en-custom")
(setq ispell-local-dictionary-alist
        '(("en-custom" "[[:alpha:]]" "[^[:alpha:]]" "[']" nil ("-d" "en-custom") nil utf-8)))

(setq which-key-idle-delay 0.5)

(setq exec-path (append exec-path '("/Library/Frameworks/Python.framework/Versions/3.7/bin/")))
(setenv "PATH" (concat (getenv "PATH") ":/Library/Frameworks/Python.framework/Versions/3.7/bin/"))

(setq leetcode-prefer-language "python3")

(use-package! conda
  :defer t
  :init
  (setq conda-anaconda-home (expand-file-name "~/miniconda3"))
  (setq conda-env-home-directory (expand-file-name "~/miniconda3")))

(after! dired
  (setq dired-dwim-target t)
  ;; default dired-hide-details-mode
  (add-hook! 'dired-mode-hook #'dired-hide-details-mode)
  (setq counsel-dired-listing-switches "-a1hot --group-directories-first")
  (setq dired-listing-switches "-a1hot --group-directories-first"))

(after! emacs-jupyter
  (add-hook! 'jupyter-repl-mode-hook #'smartparens-mode))

(after! tex
  (setq TeX-engine 'xetex)
  (setq-default TeX-PDF-mode t)
  (add-hook! 'TeX-mode-hook #'(TeX-fold-mode 0)))

(after! emojify
  (setq emojify-display-style '(unicode)))

(after! pdf-tools
  (add-hook! 'pdf-view-mode-hook #'pdf-view-midnight-minor-mode))

(map! :map global-map
      "C-x k" #'amh-kill-buffer-frame-window)

(use-package! ivy-avy
  :after ivy)

(use-package! nov
  :defer t
  :init
  (add-to-list 'auto-mode-alist '("\\.epub\\'" . nov-mode))
  :config
  (defun my-nov-font-setup ()
    (face-remap-add-relative 'variable-pitch :family "Cardo" :height 1.5))
  (add-hook! 'nov-mode-hook #'my-nov-font-setup)
  ;; enable visual line wrapping
  (setq nov-text-width t)
  (setq visual-fill-column-center-text t)
  (add-hook! 'nov-mode-hook #'visual-line-mode)
  (add-hook! 'nov-mode-hook #'visual-fill-column-mode))

(use-package! magit
  :defer t
  :init
  ;; tell magit where emacsclient is
  (setq with-editor-emacsclient-executable "/usr/local/bin/emacsclient"))

(setq evil-respect-visual-line-mode t)
(use-package! evil
  :defer t
  :init
  :config
  ;(setq evil-move-beyond-eol t)
  ;; expose C-e as end-of-line
  (map! :map evil-motion-state-map
        "C-e" #'nil)
  (map! :n "C-p" #'nil
        :n "C-p" #'counsel-yank-pop))

(use-package! evil-snipe
  :defer t
  :init
  (setq evil-snipe-scope 'visible))

;; typography setup
(use-package! typo
  :init
  (typo-global-mode 1)
  (add-hook! 'text-mode-hook 'typo-mode)
  ;; disable these binds cause directed quotes don't play nice
  ;; with company or org
  (define-key typo-mode-map (kbd "\"") nil)
  (define-key typo-mode-map (kbd "'") nil)
  (define-key typo-mode-map (kbd "`") nil))

(map! "\C-x\C-m" #'execute-extended-command)

;; convenience bindings
(map! :map global-map
      "C-o" #'nil
      "C-o" #'ace-window  ;; overwrites `open-line'
      "M-o" #'other-frame ;; overwrites some kinda face-setting command
      :map dired-mode-map
      "C-o" #'ace-window)

(map! :map dired-mode-map
      "C-r" #'dired-display-file)

;; unclobber s for skhd
(map! :map global-map
      "s-f" #'nil)

;; Rebind M-n and M-p to move five lines down and up.
(map! :map global-map
      "M-n" #'nil
      "M-p" #'nil
      "M-n" (cmd! (evil-next-line 5))
      "M-p" (cmd! (evil-previous-line 5)))

(use-package! avy
  :defer t
  :config
  (map! :map global-map
        "C-," 'avy-goto-char-2
        "C-." 'avy-goto-line))

(use-package! flyspell-correct-avy-menu
  :after spell-fu
  :config
  ;; (add-hook! 'text-mode-hook #'flyspell-mode)
  ;; (map! "C-s-SPC" #'flyspell-correct-at-point)
  (ispell-set-spellchecker-params)  ;; initialize ispell params for spell-fu
  (map! :map org-mode-map
         "M-;" #'nil
         "M-;" #'flyspell-correct-wrapper
        ;"C-;" #'flyspell-auto-correct-previous-word  ;; this is broken with spell-fu
         "C-;" #'flyspell-auto-correct-word
         "C-c z" #'+spell/add-word)
  (map! :map flyspell-mode-map
        "C-," #'nil
        "C-." #'nil))

;;;;;;;;;;;;;;;;;;;;;;;;;
;;;; FUNCTIONS BELOW ;;;;
;;;;;;;;;;;;;;;;;;;;;;;;;

(defun amh-kill-buffer-frame-window (&optional arg)
  "Kill buffer. With one prefix `C-u', kill window; with two, kill frame."
  (interactive "P")
  (if (equal arg '(4))
      ;; equivalent to `C-x 0'
      (call-interactively '+workspace/close-window-or-workspace)
    (if (equal arg '(16))
        ;; equivalent to `C-x 5 0'
        (call-interactively 'doom/delete-frame-with-prompt)
      (call-interactively 'kill-buffer))))

;; source: http://steve.yegge.googlepages.com/my-dot-emacs-file
(defun rename-file-and-buffer (new-name)
  "Renames both current buffer and file it's visiting to NEW-NAME."
  (interactive "sNew name: ")
  (let ((name (buffer-name))
        (filename (buffer-file-name)))
    (if (not filename)
        (message "Buffer '%s' is not visiting a file!" name)
      (if (get-buffer new-name)
          (message "A buffer named '%s' already exists!" new-name)
        (progn
          (rename-file filename new-name 1)
          (rename-buffer new-name)
          (set-visited-file-name new-name)
          (set-buffer-modified-p nil))))))

(defun phg/kill-to-bol ()
  "Kill from point to beginning of line."
  (interactive)
  (kill-line 0))
(map! "M-<backspace>" #'phg/kill-to-bol)




;; required to center the black hole
(setq +doom-dashboard--width 130)
;; from here: https://tecosaur.github.io/emacs-config/config.html#splash-screen
(defvar fancy-splash-image-template
  (expand-file-name "misc/splash-images/blackhole-lines-template.svg" doom-private-dir)
  "Default template svg used for the splash image, with substitutions from ")
(defvar fancy-splash-image-nil
  (expand-file-name "misc/splash-images/transparent-pixel.png" doom-private-dir)
  "An image to use at minimum size, usually a transparent pixel")

(setq fancy-splash-sizes
  `((:height 500 :min-height 50 :padding (0 . 4) :template ,(expand-file-name "misc/splash-images/blackhole-lines-0.svg" doom-private-dir))
    (:height 440 :min-height 42 :padding (1 . 4) :template ,(expand-file-name "misc/splash-images/blackhole-lines-0.svg" doom-private-dir))
    (:height 400 :min-height 38 :padding (1 . 4) :template ,(expand-file-name "misc/splash-images/blackhole-lines-1.svg" doom-private-dir))
    (:height 350 :min-height 36 :padding (1 . 3) :template ,(expand-file-name "misc/splash-images/blackhole-lines-2.svg" doom-private-dir))
    (:height 300 :min-height 34 :padding (1 . 3) :template ,(expand-file-name "misc/splash-images/blackhole-lines-3.svg" doom-private-dir))
    (:height 250 :min-height 32 :padding (1 . 2) :template ,(expand-file-name "misc/splash-images/blackhole-lines-4.svg" doom-private-dir))
    (:height 200 :min-height 30 :padding (1 . 2) :template ,(expand-file-name "misc/splash-images/blackhole-lines-5.svg" doom-private-dir))
    (:height 100 :min-height 24 :padding (1 . 2) :template ,(expand-file-name "misc/splash-images/emacs-e-template.svg" doom-private-dir))
    (:height 0   :min-height 0  :padding (0 . 0) :file ,fancy-splash-image-nil)))

(defvar fancy-splash-sizes
  `((:height 500 :min-height 50 :padding (0 . 2))
    (:height 440 :min-height 42 :padding (1 . 4))
    (:height 330 :min-height 35 :padding (1 . 3))
    (:height 200 :min-height 30 :padding (1 . 2))
    (:height 0   :min-height 0  :padding (0 . 0) :file ,fancy-splash-image-nil))
  "list of plists with the following properties
  :height the height of the image
  :min-height minimum `frame-height' for image
  :padding `+doom-dashboard-banner-padding' to apply
  :template non-default template file
  :file file to use instead of template")

(defvar fancy-splash-template-colours
  '(("$colour1" . keywords) ("$colour2" . type) ("$colour3" . base5) ("$colour4" . base8))
  "list of colour-replacement alists of the form (\"$placeholder\" . 'theme-colour) which applied the template")

(unless (file-exists-p (expand-file-name "theme-splashes" doom-cache-dir))
  (make-directory (expand-file-name "theme-splashes" doom-cache-dir) t))

(defun fancy-splash-filename (theme-name height)
  (expand-file-name (concat (file-name-as-directory "theme-splashes")
                            (symbol-name doom-theme)
                            "-" (number-to-string height) ".svg")
                    doom-cache-dir))

(defun fancy-splash-clear-cache ()
  "Delete all cached fancy splash images"
  (interactive)
  (delete-directory (expand-file-name "theme-splashes" doom-cache-dir) t)
  (message "Cache cleared!"))

(defun fancy-splash-generate-image (template height)
  "Read TEMPLATE and create an image if HEIGHT with colour substitutions as  ;described by `fancy-splash-template-colours' for the current theme"
    (with-temp-buffer
      (insert-file-contents template)
      (re-search-forward "$height" nil t)
      (replace-match (number-to-string height) nil nil)
      (dolist (substitution fancy-splash-template-colours)
        (beginning-of-buffer)
        (while (re-search-forward (car substitution) nil t)
          (replace-match (doom-color (cdr substitution)) nil nil)))
      (write-region nil nil
                    (fancy-splash-filename (symbol-name doom-theme) height) nil nil)))

(defun fancy-splash-generate-images ()
  "Perform `fancy-splash-generate-image' in bulk"
  (dolist (size fancy-splash-sizes)
    (unless (plist-get size :file)
      (fancy-splash-generate-image (or (plist-get size :file)
                                       (plist-get size :template)
                                       fancy-splash-image-template)
                                   (plist-get size :height)))))

(defun ensure-theme-splash-images-exist (&optional height)
  (unless (file-exists-p (fancy-splash-filename
                          (symbol-name doom-theme)
                          (or height
                              (plist-get (car fancy-splash-sizes) :height))))
    (fancy-splash-generate-images)))

(defun get-appropriate-splash ()
  (let ((height (frame-height)))
    (cl-some (lambda (size) (when (>= height (plist-get size :min-height)) size))
             fancy-splash-sizes)))

(setq fancy-splash-last-size nil)
(setq fancy-splash-last-theme nil)
(defun set-appropriate-splash (&optional frame)
  (let ((appropriate-image (get-appropriate-splash)))
    (unless (and (equal appropriate-image fancy-splash-last-size)
                 (equal doom-theme fancy-splash-last-theme)))
    (unless (plist-get appropriate-image :file)
      (ensure-theme-splash-images-exist (plist-get appropriate-image :height)))
    (setq fancy-splash-image
          (or (plist-get appropriate-image :file)
              (fancy-splash-filename (symbol-name doom-theme) (plist-get appropriate-image :height))))
    (setq +doom-dashboard-banner-padding (plist-get appropriate-image :padding))
    (setq fancy-splash-last-size appropriate-image)
    (setq fancy-splash-last-theme doom-theme)
    (+doom-dashboard-reload)))

(add-hook 'window-size-change-functions #'set-appropriate-splash)
(add-hook 'doom-load-theme-hook #'set-appropriate-splash)

(defun remove-orgmode-latex-labels ()
  "Remove labels generated by org-mode"
  (interactive)
  (let ((case-fold-search nil))
   (goto-char 1)
   (replace-regexp "\\\\label{sec-[0-9][^}]*}" "")))



