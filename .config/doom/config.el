;;; $DOOMDIR/config.el -*- lexical-binding: t; -*-

;; Place your private configuration here! Remember, you do not need to run 'doom
;; sync' after modifying this file!

;; --- Shared-cluster citizenship -----------------------------------------
;; This runs on a shared 224-core node. `native-comp-async-jobs-number' defaults
;; to ~half the cores (~112), so first-launch JIT native-compilation would spawn
;; ~112 emacs subprocesses at once and stall the box. Cap it hard.
(setq native-comp-async-jobs-number 8)

;; --- SSH indicator ------------------------------------------------------
;; Running over SSH (e.g. a cluster node)? Make it obvious you're not local: an
;; "ssh:<host>" badge in the modeline (right side, via global-mode-string), and
;; the host in the terminal title (shows in the iTerm2 tab). Local Emacs has no
;; SSH_CONNECTION, so this is a no-op there.
(when (getenv "SSH_CONNECTION")
  (let ((host (car (split-string (system-name) "\\."))))
    (add-to-list 'global-mode-string
                 (propertize (format " ssh:%s " host) 'face 'doom-modeline-urgent)
                 'append)
    (setq frame-title-format (format "%s — %%b" host))))


;; Some functionality uses this to identify you, e.g. GPG configuration, email
;; clients, file templates and snippets. It is optional.
;; (setq user-full-name "John Doe"
;;       user-mail-address "john@doe.com")

;; Doom exposes five (optional) variables for controlling fonts in Doom:
;;
;; - `doom-font' -- the primary font to use
;; - `doom-variable-pitch-font' -- a non-monospace font (where applicable)
;; - `doom-big-font' -- used for `doom-big-font-mode'; use this for
;;   presentations or streaming.
;; - `doom-symbol-font' -- for symbols
;; - `doom-serif-font' -- for the `fixed-pitch-serif' face
;;
;; See 'C-h v doom-font' for documentation and more examples of what they
;; accept. For example:
;;
;;(setq doom-font (font-spec :family "Fira Code" :size 12 :weight 'semi-light)
;;      doom-variable-pitch-font (font-spec :family "Fira Sans" :size 13))
;;
;; If you or Emacs can't find your font, use 'M-x describe-font' to look them
;; up, `M-x eval-region' to execute elisp code, and 'M-x doom/reload-font' to
;; refresh your font settings. If Emacs still can't find your font, it likely
;; wasn't installed correctly. Font issues are rarely Doom issues!

;; There are two ways to load a theme. Both assume the theme is installed and
;; available. You can either set `doom-theme' or manually load a theme with the
;; `load-theme' function. This is the default:
(setq doom-theme 'doom-one)

;; This determines the style of line numbers in effect. If set to `nil', line
;; numbers are disabled. For relative line numbers, set this to `relative'.
;(setq display-line-numbers-type t)

;; If you use `org' and don't want your org files in the default location below,
;; change `org-directory'. It must be set before org loads!
(setq org-directory "~/Dropbox/org/")


;; Whenever you reconfigure a package, make sure to wrap your config in an
;; `after!' block, otherwise Doom's defaults may override your settings. E.g.
;;
;;   (after! PACKAGE
;;     (setq x y))
;;
;; The exceptions to this rule:
;;
;;   - Setting file/directory variables (like `org-directory')
;;   - Setting variables which explicitly tell you to set them before their
;;     package is loaded (see 'C-h v VARIABLE' to look up their documentation).
;;   - Setting doom variables (which start with 'doom-' or '+').
;;
;; Here are some additional functions/macros that will help you configure Doom.
;;
;; - `load!' for loading external *.el files relative to this one
;; - `use-package!' for configuring packages
;; - `after!' for running code after a package has loaded
;; - `add-load-path!' for adding directories to the `load-path', relative to
;;   this file. Emacs searches the `load-path' when you load packages with
;;   `require' or `use-package'.
;; - `map!' for binding new keys
;;
;; To get information about any of these functions/macros, move the cursor over
;; the highlighted symbol at press 'K' (non-evil users must press 'C-c c k').
;; This will open documentation for it, including demos of how they are used.
;; Alternatively, use `C-h o' to look up a symbol (functions, variables, faces,
;; etc).
;;
;; You can also try 'gd' (or 'C-c c d') to jump to their definition and see how
;; they are implemented.

(setq doom-font (font-spec :name "Hack" :size 15))
(setq doom-variable-pitch-font (font-spec :size 18))

(setq mac-option-modifier 'nil)       ;; for exposing diacritical marks
(setq mac-command-modifier 'meta)     ;; this only makes sense

;;; linum stuff
;; 1) Ensure no line numbers or extra spacing by default
(setq display-line-numbers-type nil)

;; 2) Prog-mode: relative line numbers, reset line-spacing to default
(add-hook! 'prog-mode-hook
  (setq-local display-line-numbers-type 'relative)
  (setq-local line-spacing           nil)
  (display-line-numbers-mode))

;; 3) Org-mode: disable line numbers, bump up line spacing for Operator Pro
(add-hook! 'org-mode-hook
  (setq-local display-line-numbers-type nil)
  (setq-local line-spacing           10)
  (variable-pitch-mode))

;; 4) Markdown-mode: disable line numbers, use mixed-pitch if you like
(add-hook! 'markdown-mode-hook
  (setq-local display-line-numbers-type nil)
  (mixed-pitch-mode))

(setq! org-journal-dir "~/Dropbox/org/journal/org-journal")
(setq! org-extend-today-until 9)  ;; extend today until 9 am

(defun amh-org-journal-template (time)
"Replacement for org-journal-date-format that inserts some text on every new entry."
(concat org-journal-date-prefix  ;; eg "* Wednesday, 16 November 2022
        (format-time-string "%A, %-d %B %Y" time))
)

(setq! org-journal-date-format 'amh-org-journal-template)

(defun org-journal-next-date-entry (prefix)
    "Create an org-journal entry for the day after the day of the currently open buffer's entry."
  (interactive "P")
  (unless (not (eq major-mode 'org-journal-mode))
    ;; Get the current entry's time
      (setq current-entry-timestring (file-name-nondirectory (buffer-file-name))) ; like "20221231"
      (setq current-entry-timelist `(0 0 9  ; list for encode-time
                                       ,(+ 1 (string-to-number (substring current-entry-timestring 6 8)))  ; day
                                       ,(string-to-number (substring current-entry-timestring 4 6))  ; month
                                       ,(string-to-number (substring current-entry-timestring 0 4))  ; year
                                       0 0 0))
      (setq current-entry-time (encode-time current-entry-timelist))
      (org-journal-new-entry prefix current-entry-time)
      )
  )

(map! "C-s" #'+default/search-buffer)

(use-package! avy
  ;:defer t
  :config
  (map! "C-," nil
        "C-." nil  ;; used to be evil-repeat-pop and idk what that does
        :n "C-," 'avy-goto-char-2
        :i "C-," 'avy-goto-char-2
        :n "C-." 'avy-goto-line
        :i "C-." 'avy-goto-line))

(after! tex
  (setq-default TeX-engine 'xetex)
  (setq-default TeX-PDF-mode t))

(setq treesit-language-source-alist
      '((astro "https://github.com/virchau13/tree-sitter-astro")
        (css "https://github.com/tree-sitter/tree-sitter-css")
        (tsx "https://github.com/tree-sitter/tree-sitter-typescript" "master" "tsx/src")))

(after! org
  (setq org-latex-compiler "xelatex")
  ;; (add-to-list 'org-latex-classes
  ;;            '("beamer"
  ;;              "\\documentclass[presentation]{beamer}"
  ;;              ("\\section{%s}" . "\\section*{%s}")
  ;;              ("\\subsection{%s}" . "\\subsection*{%s}")
  ;;              ("\\subsubsection{%s}" . "\\subsubsection*{%s}")))

  (setq! amh/lab "~/Dropbox/org/lab-notebook.org")
  (setq! amh/rolo "~/Dropbox/org/rolodex.org")

  (defvar amh/rolodex-snippet-alist
    '(("faculty" . "faculty")
      ("phd-student" . "phd")
      ;; add more roles if you later create snippets for them:
      ;; ("postdoc" . "postdoc")
      )
    "Map a person role to a yasnippet key for org-mode.")

  (defun amh/org-capture-insert-person-snippet ()
    "Prompt for role and expand matching yasnippet in the capture buffer.
Return an empty string so this can be used inside a %(...) template."
    (let* ((role (completing-read "Role: " (mapcar #'car amh/rolodex-snippet-alist) nil t))
           (key  (alist-get role amh/rolodex-snippet-alist nil nil #'string-equal))
           (tmpl (and key (yas-lookup-snippet key 'org-mode))))
      (unless tmpl
        (user-error "No yasnippet found for role %s (key %s)" role key))
      (yas-minor-mode 1)              ; be explicit
      (yas-expand-snippet tmpl)       ; interactive fields now active
      ""))                            ; nothing else to insert

  (setq! org-capture-templates
      `(("l" "Lab note (date tree)" entry
         (file+olp+datetree ,amh/lab)
         "* %<%H:%M> %^{Title}\n%?\n"
         :empty-lines 1)

        ("m" "Meeting (link a person)" entry
         (file+olp+datetree ,amh/lab)
         "* %<%H:%M> Meeting with %^{Who (paste/insert link)}\n%?"
         :empty-lines 1)

        ("p" "New person stub in rolodex" plain
         (file ,amh/rolo)
         "%(amh/org-capture-insert-person-snippet)"
         :empty-lines 1)))

  (defun amh/rolo-insert-link ()
    "Prompt for a person name from rolodex.org and insert a stable link."
    (interactive)
    (let ((buf (find-file-noselect amh/rolo))
          alist)
      (with-current-buffer buf
        (org-map-entries
         (lambda ()
           (let* ((name (org-get-heading t t t t))
                  (cid  (org-entry-get (point) "CUSTOM_ID")))
             (when (and name cid)
               (push (cons name cid) alist))))))
      (let* ((name (completing-read "Person: " (mapcar #'car alist) nil t))
             (cid  (cdr (assoc name alist))))
        (insert (format "[[file:%s::#%s][%s]]"
                        (file-name-nondirectory amh/rolo) cid name)))))
  )

(electric-quote-mode -1)

;; Smartparens configuration (your existing setup looks good)
(add-hook 'text-mode-hook
          (lambda ()
            (smartparens-mode -1)))
(add-hook 'markdown-mode-hook
          (lambda ()
            (smartparens-mode -1)))
(add-hook 'org-mode-hook
          (lambda ()
            (smartparens-mode -1)))
(add-hook 'prog-mode-hook #'smartparens-mode)

;; Fix yasnippet/org-mode TAB conflict
(after! (yasnippet org)
  (defun +org/can-yas-expand-p ()
    "Check if there's a yasnippet that can expand at point."
    (and (bound-and-true-p yas-minor-mode)
         (yas--templates-for-key-at-point)))

  (defun +org/tab-dwim ()
    "Insert mode TAB: expand snippet, or demote heading/item."
    (interactive)
    (cond
     ((+org/can-yas-expand-p) (yas-expand))
     ((org-at-heading-p) (org-do-demote))
     ((org-at-item-p) (org-indent-item))
     (t (indent-for-tab-command))))

  (defun +org/backtab-dwim ()
    "Insert mode Shift-TAB: promote heading/item."
    (interactive)
    (cond
     ((org-at-heading-p) (org-do-promote))
     ((org-at-item-p) (org-outdent-item))
     (t (org-shifttab))))

  (evil-define-key 'insert org-mode-map (kbd "TAB") #'+org/tab-dwim)
  (evil-define-key 'insert org-mode-map [tab] #'+org/tab-dwim)
  (evil-define-key 'insert org-mode-map (kbd "<backtab>") #'+org/backtab-dwim)
  (evil-define-key 'insert org-mode-map [backtab] #'+org/backtab-dwim))

;; Tramp config to log into torch
(setq! tramp-ssh-controlmaster-options
      "-o ControlMaster=auto -o ControlPath=~/.ssh/control-%%r@%%h:%%p -o ControlPersist=10m")

;; Use the remote login-shell PATH over TRAMP so user-installed binaries are
;; found (e.g. node 22, claude-agent-acp, claude — all in ~/.local/bin on the
;; runpod nodes). The explicit entry is prepended last so it sits at the front
;; of the remote PATH, ensuring the user-local node 22 beats the system node 18.
(after! tramp
  (add-to-list 'tramp-remote-path 'tramp-own-remote-path)
  (add-to-list 'tramp-remote-path "/home/andyqhan/.local/bin"))

;;; Remote LaTeX: use local lualatex when compiling from TRAMP buffers
(after! ox-pandoc
  (setq org-pandoc-options-for-latex-pdf '((pdf-engine . "lualatex"))))

(after! org
  (defun amh/copy-latex-deps (local-tex remote-dir local-dir)
    "Parse LOCAL-TEX for \\includegraphics, \\input, etc. and copy
the referenced files from REMOTE-DIR into LOCAL-DIR, preserving
relative subdirectory structure."
    (let (deps)
      (with-temp-buffer
        (insert-file-contents local-tex)
        (goto-char (point-min))
        (while (re-search-forward
                "\\\\\\(?:includegraphics\\(?:\\[[^]]*\\]\\)?\\|input\\|include\\|bibliography\\|addbibresource\\){\\([^}]+\\)}"
                nil t)
          (cl-pushnew (match-string 1) deps :test #'string=)))
      (dolist (dep deps)
        (let* ((candidates
                (if (file-name-extension dep) (list dep)
                  (cons dep (mapcar (lambda (e) (concat dep "." e))
                                    '("png" "jpg" "jpeg" "pdf" "eps" "svg")))))
               (found nil))
          (dolist (cand candidates)
            (unless found
              (let ((src (expand-file-name cand remote-dir))
                    (dst (expand-file-name cand local-dir)))
                (when (file-exists-p src)
                  (make-directory (file-name-directory dst) t)
                  (copy-file src dst t)
                  (setq found t)))))))))

  (defun amh/org-latex-compile-locally-a (orig-fn texfile &optional snippet)
    "When TEXFILE is on a remote host, compile with local lualatex
instead of the remote's LaTeX toolchain."
    (if (not (file-remote-p texfile))
        (funcall orig-fn texfile snippet)
      (let* ((remote-dir (file-name-directory texfile))
             (basename (file-name-nondirectory texfile))
             (stem (file-name-sans-extension basename))
             (local-dir (make-temp-file "tramp-latex-" t))
             (local-tex (expand-file-name basename local-dir))
             (local-pdf (expand-file-name (concat stem ".pdf") local-dir))
             (remote-pdf (expand-file-name (concat stem ".pdf") remote-dir)))
        (unwind-protect
            (progn
              (copy-file texfile local-tex t)
              (amh/copy-latex-deps local-tex remote-dir local-dir)
              (message "Compiling %s with local lualatex…" basename)
              (let ((default-directory local-dir)
                    (cmd (format "lualatex -interaction=nonstopmode %s"
                                 (shell-quote-argument basename))))
                (shell-command cmd)
                (shell-command cmd))  ; second pass for cross-references
              (unless (file-exists-p local-pdf)
                (user-error "lualatex failed — check *Shell Command Output*"))
              (copy-file local-pdf remote-pdf t)
              (message "PDF → %s" remote-pdf)
              remote-pdf)
          (delete-directory local-dir t)))))

  (advice-add #'org-latex-compile :around
              #'amh/org-latex-compile-locally-a))

;; Swap Doom's default iTerm bindings so the lowercase/common shortcut opens
;; a new window (what I usually want), and the uppercase variant opens a tab
;; in the existing window. Doom defaults are the other way around:
;;   SPC o s i  →  +macos/open-in-iterm            (respects iTerm pref; usually a tab)
;;   SPC o s I  →  +macos/open-in-iterm-new-window (always new window)
;; iTerm's "OpenFileInNewWindows" pref is 0 here, so the stock functions give
;; us exactly the two behaviors we want — we just swap which key calls which.
(map! :leader
      :desc "Open in new iTerm window" "o s i" #'+macos/open-in-iterm-new-window
      :desc "Open in iTerm tab"        "o s I" #'+macos/open-in-iterm)

;; Skim cmd-shift-click reverse search lands at column 0 of the source line.
;; Skim only sends file+line (no click column), so the best we can do is move
;; to the first non-blank char and pulse-highlight the line. Wired through
;; ~/.config/doom/bin/skim-reverse-search.sh, which is set as Skim's TeX-editor
;; command (see `defaults read -app Skim`).
(defun amh/skim-reverse-search--goto (file line)
  "Open FILE at LINE, move to first non-blank, flash the line."
  (find-file file)
  (goto-char (point-min))
  (forward-line (1- line))
  (back-to-indentation)
  (if (fboundp '+nav-flash-blink-cursor)
      (+nav-flash-blink-cursor)
    (require 'pulse)
    (pulse-momentary-highlight-one-line (point))))

(defun amh/skim-reverse-search (file line)
  "Skim reverse search into the existing Emacs frame."
  (amh/skim-reverse-search--goto file line)
  ;; Skim is the active app; raise Emacs to the front.
  (select-frame-set-input-focus (selected-frame)))

(defun amh/skim-reverse-search-new-frame (file line)
  "Skim reverse search into a NEW Emacs frame.
Triggered when ⌘-Ctrl-Shift-Click is used in Skim (the wrapper script
detects the modifier and dispatches here)."
  (let ((frame (make-frame)))
    (select-frame-set-input-focus frame)
    (amh/skim-reverse-search--goto file line)))

(defun amh/view-pdf-in-skim ()
  "Open the current file's PDF in Skim. Copies from remote if needed."
  (interactive)
  (let ((pdf (concat (file-name-sans-extension (buffer-file-name)) ".pdf")))
    (unless (file-exists-p pdf)
      (user-error "No PDF found: %s" (file-name-nondirectory pdf)))
    (if (file-remote-p pdf)
        (let ((local (expand-file-name (file-name-nondirectory pdf)
                                       temporary-file-directory)))
          (copy-file pdf local t)
          (call-process "open" nil 0 nil "-a" "Skim" local))
      (call-process "open" nil 0 nil "-a" "Skim" pdf))))

(use-package! org-side-tree
  :after org
  :config
  (setq org-side-tree-persistent t
        org-side-tree-display-side 'left)
  (map! :leader :desc "Org side tree" "t o" #'org-side-tree))

;; agent-shell: run coding agents (Claude Code, etc.) inside Emacs over the
;; Agent Client Protocol. Requires the bridge binary on PATH:
;;   npm install -g @agentclientprotocol/claude-agent-acp   ->  claude-agent-acp
;; Auth uses the Claude Code subscription via the logged-in `claude' CLI.
;; To use an API key instead, replace the :login line below with, e.g.:
;;   (agent-shell-anthropic-make-authentication
;;    :api-key (lambda () (getenv "ANTHROPIC_API_KEY")))
;; Launch with `SPC o a' (Claude Code) or `SPC o A' (pick an agent).
(use-package! agent-shell
  :commands (agent-shell agent-shell-anthropic-start-claude-code)
  :init
  ;; Bind at startup so the keys work before the package is first loaded; the
  ;; :commands autoloads pull agent-shell in on first use.
  (map! :leader
        :desc "Agent shell: Claude Code" "o a" #'agent-shell-anthropic-start-claude-code
        :desc "Agent shell: pick agent"  "o A" #'agent-shell)
  :config
  ;; `agent-shell-anthropic-make-authentication' isn't autoloaded, so set the
  ;; auth var in :config (after the package loads), not :init.
  ;; :login reuses the Claude Code login on whichever host the bridge runs on
  ;; (locally, or the remote node when started from a TRAMP buffer).
  (setq agent-shell-anthropic-authentication
        (agent-shell-anthropic-make-authentication :login t))

  ;; Auto mode: start every Claude shell in "auto", where a model classifier
  ;; approves/denies each permission prompt (safe ops through, dangerous ones
  ;; still stop) instead of a blanket bypass. Mode IDs from claude-agent-acp:
  ;; "default" (asks), "auto" (classifier decides), "acceptEdits" (auto-accept
  ;; file edits only), "plan" (no execution), "dontAsk" (no prompt, deny if not
  ;; pre-approved), "bypassPermissions" (skip everything). Note: "auto" is only
  ;; advertised when the active model reports supportsAutoMode; if a shell's
  ;; model lacks it, it won't appear under "Available modes". Switch live with
  ;; `M-x agent-shell-cycle-session-mode' (or `agent-shell-set-session-mode').
  ;; Applies on the host where the bridge runs, so remote TRAMP/RunPod too.
  (setq agent-shell-anthropic-default-session-mode-id "auto")

  ;; Remote (TRAMP) support: when the shell's directory is remote, acp.el spawns
  ;; claude-agent-acp on that host. Map paths between TRAMP and remote-local so
  ;; the agent receives bare paths (e.g. /home/andyqhan/proj) and file links it
  ;; returns reopen back through TRAMP. No-op for local sessions.
  (setq agent-shell-path-resolver-function
        (lambda (path)
          (cond ((file-remote-p path) (file-local-name path))
                ((file-remote-p default-directory)
                 (concat (file-remote-p default-directory) path))
                (t path)))))

;; Fix: agent-shell spins forever when started against a remote (TRAMP) host.
;; acp.el spawns the ACP bridge with `:connection-type 'pipe', but TRAMP's
;; pipe-based `make-process' block-buffers small reads, so the bridge's tiny
;; `initialize' reply never reaches Emacs (it only flushes once ~8KB piles up)
;; and the shell hangs. A PTY is delivered promptly, and over TRAMP it comes
;; back raw — no input echo, no CRLF translation, and stderr stays in its own
;; buffer (all verified) — so the JSON-RPC stream is clean. Force a PTY for the
;; bridge process only when the shell's directory is remote; local stays a pipe.
(after! acp
  (define-advice acp--start-client (:around (orig &rest args) +agent-shell-remote-pty)
    (if (file-remote-p default-directory)
        (cl-letf* ((real-make-process (symbol-function #'make-process))
                   ((symbol-function #'make-process)
                    (lambda (&rest mp)
                      (apply real-make-process (plist-put mp :connection-type 'pty)))))
          (apply orig args))
      (apply orig args))))

;; vterm: a real terminal inside Emacs, to replace iTerm2 for cluster work.
;; Architecture (least fiddly): a LOCAL vterm runs `ssh', and `zellij' runs
;; inside that ssh session on the host. No TRAMP in this path — TRAMP is only for
;; editing remote files in Emacs buffers, and routing a heavy TUI like zellij
;; through it is laggy. zellij on the host does the multiplexing and keeps work
;; alive across laptop sleep/disconnect; reattach by re-running the command.
;;   SPC o t / SPC o T   toggle / open a vterm here              (Doom built-ins)
;;   SPC o z             vterm attached to runpod-25's zellij    (helper below)
;;   C-c C-t             enter vterm-copy-mode: evil motions, C-s, avy, kill-ring
;;                       over the scrollback (this is the Emacs-navigation win)
;;   C-q <key>           send a key straight to the terminal (e.g. C-q C-c -> ^C)
(after! vterm
  (setq vterm-max-scrollback 100000))   ; deep scrollback for copy-mode navigation

;; --- Name vterm buffers running Claude Code after their session -------------
;; Claude Code sets the terminal title (OSC 0) to "<prefix> <session name>",
;; exactly like it does in a bare iTerm2 window. <prefix> is ✳ (U+2733) when
;; idle, or a braille spinner frame (U+2800-U+28FF) while Claude is working; the
;; resume picker uses "claude · …". Our chain (emacs -nw -> vterm -> zsh ->
;; claude, no zellij/tmux) delivers that OSC straight to vterm.
;;
;; This vterm version made `vterm-set-title-functions' obsolete — incoming titles
;; now go through `vterm--set-title', which only renames when the global
;; `vterm-buffer-name-string' is set AND would use the raw title (so the buffer
;; name would flicker with the spinner, on *every* vterm). So we :override it:
;; strip Claude's animated prefix and name the buffer after the session; for any
;; other program, fall back to vterm's default behaviour.
(after! vterm
  (defvar-local +amh/vterm-claude-name nil
    "Last Claude session name applied to this vterm buffer (churn guard).")

  (defun +amh/vterm-claude-title->name (title)
    "Return the Claude session name in TITLE, or nil if TITLE isn't Claude's."
    (when (stringp title)
      (let ((name (replace-regexp-in-string
                   "\\`[ \t]*\\(?:✳\\|[⠀-⣿]\\)[ \t]*" "" title)))
        (cond
         ;; A ✳/spinner prefix was stripped -> definitely Claude; NAME is the title.
         ((not (string= name title)) (string-trim name))
         ;; No prefix, but the title names claude (e.g. "claude · resume").
         ((string-match-p "\\bclaude\\b" title) (string-trim title))
         (t nil)))))

  (defun +amh/vterm--set-title (title)
    "Claude-aware replacement for `vterm--set-title'.
Names a vterm running Claude Code after its session (stable across the spinner);
for any other program, defers to vterm's default `vterm-buffer-name-string'."
    (let ((name (+amh/vterm-claude-title->name title)))
      (cond
       ((and name (not (string-empty-p name)))
        (unless (equal name +amh/vterm-claude-name)
          (setq +amh/vterm-claude-name name)
          (rename-buffer (generate-new-buffer-name (format "✳ %s" name)))))
       (vterm-buffer-name-string
        (rename-buffer (format vterm-buffer-name-string title) t)))))

  (advice-add 'vterm--set-title :override #'+amh/vterm--set-title))

(defun +amh/vterm-runpod ()
  "Open a LOCAL vterm attached to a persistent zellij session on runpod-25.
Behaves like iTerm2 (ssh runs inside the terminal) but with vterm copy-mode for
navigation. zellij keeps work alive across sleep/disconnect — run this again to
reattach. Detach from inside zellij with `C-o d'. PATH is set explicitly because
a non-interactive ssh shell doesn't have ~/.local/bin (where zellij lives); EDITOR
is set so zellij's edit-scrollback (`C-s' then `e') opens the pane history in vim."
  (interactive)
  (require 'vterm)
  (let ((default-directory "~/")          ; force a LOCAL terminal, not a TRAMP one
        (name (generate-new-buffer-name "*runpod-zellij*")))
    (vterm name)
    (vterm-send-string
     "exec ssh -t runpod-25 'export PATH=\"$HOME/.local/bin:$PATH\" EDITOR=vim; exec zellij attach -c main'")
    (vterm-send-return)))

(map! :leader :desc "Vterm: runpod zellij" "o z" #'+amh/vterm-runpod)


;; --- vterm key passthrough (terminal Claude Code workflow) ------------------
(after! vterm
  ;; Stop swallowing C-c so a double C-c exits Claude Code (the C-c prefix is
  ;; unused here; vterm is driven via evil + SPC). Rebind explicitly because the
  ;; keymap was already built with C-c excluded.
  ;; Show the mode line in vterm. In a TTY the mode line IS the horizontal window
  ;; divider (real window dividers are GUI-only), and Doom hides it in vterm, so
  ;; horizontally-stacked vterm windows have no visible boundary or drag handle.
  (remove-hook 'vterm-mode-hook #'mode-line-invisible-mode)
  (setq vterm-keymap-exceptions (delete "C-c" vterm-keymap-exceptions))
  (define-key vterm-mode-map (kbd "C-c") #'vterm--self-insert)
  ;; evil-collection (C-c C-z) plus flycheck/persp/yasnippet bind C-c prefixes in
  ;; maps that outrank the major map, making C-c a dead prefix. Bind C-c as a command
  ;; in the evil insert+normal aux maps (highest precedence) so it reaches Claude.
  (dolist (st '(insert normal))
    (define-key (evil-get-auxiliary-keymap vterm-mode-map st t) (kbd "C-c") #'vterm--self-insert))
  ;; ESC reaches the inner app (Claude Code) only from evil *normal* state; a
  ;; first ESC still drops insert->normal (muscle memory), so double-ESC sends
  ;; an escape through to Claude.
  (map! :map vterm-mode-map :n "<escape>" #'vterm-send-escape)
  ;; Line-by-line mouse-wheel scrolling for FULLSCREEN Claude Code (tui:fullscreen).
  ;; vterm does not forward mouse to the child, so inject the raw SGR mouse-wheel
  ;; sequences straight to the PTY; Claude's fullscreen renderer (mouse tracking on)
  ;; turns them into scroll:lineUp/lineDown (tunable via Claude's /scroll-speed).
  ;; Bound in evil insert+normal state so it outranks ultra-scroll / pixel-scroll.
  ;; NOTE: at a bare shell prompt (no mouse app) plain wheel injects mouse codes;
  ;; use Shift+wheel there to scroll vterm's own buffer.
  (defun +amh/vterm-wheel (seq)
    "Send raw SGR mouse SEQ to the vterm child PTY."
    (when (bound-and-true-p vterm--process)
      (process-send-string vterm--process seq)
      (accept-process-output vterm--process 0.02)))
  (defun +amh/vterm-wheel-up ()   (interactive) (+amh/vterm-wheel "\e[<64;1;1M"))
  (defun +amh/vterm-wheel-down () (interactive) (+amh/vterm-wheel "\e[<65;1;1M"))
  (map! :map vterm-mode-map
        :ni "<wheel-up>"          #'+amh/vterm-wheel-up
        :ni "<double-wheel-up>"   #'+amh/vterm-wheel-up
        :ni "<triple-wheel-up>"   #'+amh/vterm-wheel-up
        :ni "<wheel-down>"        #'+amh/vterm-wheel-down
        :ni "<double-wheel-down>" #'+amh/vterm-wheel-down
        :ni "<triple-wheel-down>" #'+amh/vterm-wheel-down
        :ni "<S-wheel-up>"        #'scroll-down-command
        :ni "<S-wheel-down>"      #'scroll-up-command)
  ;; Send a literal SPACE to the inner app (Claude): SPC is the evil/Doom leader
  ;; in normal state, so it never reaches Claude there (in insert it passes through
  ;; fine). C-SPC (previously a NUL self-insert) now sends a real space in both
  ;; states. Built-in alternative: C-q SPC (send-next-key).
  (defun +amh/vterm-send-space ()
    "Send a literal space to the vterm child (Claude)."
    (interactive) (vterm-send "SPC"))
  (map! :map vterm-mode-map :ni "C-SPC" #'+amh/vterm-send-space))


;; --- Evil insert-state cursor COLOR in the terminal (OSC 12) ----------------
;; etcc changes cursor SHAPE per state, but full-screen apps (Claude Code) set
;; their own cursor shape, so the insert bar doesn't show inside Claude's input.
;; Cursor COLOR set via OSC 12 survives that (Claude sets only shape), so it works
;; as an insert/normal indicator everywhere, vterm/Claude included. Insert -> color;
;; leaving insert -> reset (OSC 112). No-op in GUI Emacs.
(defun +amh/tty-cursor-color (color)
  "Set terminal cursor COLOR via OSC 12, or reset (OSC 112) when COLOR is nil."
  (unless (display-graphic-p)
    (send-string-to-terminal (if color (format "\e]12;%s\a" color) "\e]112\a"))))
(defvar +amh/insert-cursor-color "#ff5f00"
  "Terminal cursor color while in evil insert state.")
(add-hook 'evil-insert-state-entry-hook
          (defun +amh/cursor-color-insert () (+amh/tty-cursor-color +amh/insert-cursor-color)))
(add-hook 'evil-insert-state-exit-hook
          (defun +amh/cursor-color-reset () (+amh/tty-cursor-color nil)))
(add-hook 'kill-emacs-hook #'+amh/cursor-color-reset)

;; ---------------------------------------------------------------------------
;; emacsclient -t: restore workspace, buffers & window layout on reconnect
;; ---------------------------------------------------------------------------
;; Goal: close a terminal, run `emacsclient -t` later, and get everything back
;; exactly as it was. Two situations are handled:
;;
;;   (a) Daemon still alive (you only closed the terminal): all buffers and
;;       persp workspaces are already in memory; we just re-apply the *window
;;       layout* of the frame you last closed onto the new client frame (a fresh
;;       client frame otherwise opens on the dashboard).
;;   (b) Daemon was restarted (node reboot, daemon killed/reaped): we reload the
;;       persp-mode session that was saved to disk on the way out.
;;
;; The dotfiles `emacsclient` wrapper auto-starts the Doom daemon when a frame
;; is requested and none is running, so a bare `emacsclient -t` reaches case (b)
;; transparently. Named (not lambda) hook fns => `doom/reload' won't duplicate.

;; (a) Carry the window layout across client frames --------------------------
(defvar +amh/last-window-state nil
  "`window-state' of the most recently deleted frame, replayed onto the next.")

(defun +amh/save-frame-state (frame)
  "Stash FRAME's window layout for the next client frame to restore.
When a real (client) terminal closes, also persist the Doom session to disk so
a later cold start can restore it even if the daemon is later killed hard."
  (when (frame-live-p frame)
    (with-selected-frame frame
      (ignore-errors
        (setq +amh/last-window-state
              (window-state-get (frame-root-window frame) t))))
    (when (frame-parameter frame 'client)
      (let ((inhibit-message t))
        (ignore-errors (doom-save-session))))))
(add-hook 'delete-frame-functions #'+amh/save-frame-state)

;; --- Swallow stray CSI `?' replies on tty frames -----------------------------
;; A client that dies without a clean teardown (dropped SSH, wedged/killed
;; daemon) leaves iTerm2 with mouse/focus reporting still enabled, and terminal
;; probes (e.g. Claude Code's kitty-keyboard query) can leave un-consumed
;; replies like `CSI ? 0 u' on the line. On the next attach those bytes arrive
;; as keystrokes: `[' lands on the evil unimpaired prefix, a help prompt opens
;; ("Command under [: "), and the leftover "0u" types itself in. Mouse/focus
;; reports already have decoders (xterm-mouse-mode / xterm focus tracking), but
;; nothing ever decodes `CSI ? ... <final>' replies (kkp flags, DA, DECRPM) --
;; they are never real keys, so decode-and-drop them. Terminal-local map, hence
;; `tty-setup-hook'.
(defun +amh/tty-swallow-csi-replies ()
  (define-key input-decode-map "\e[?"
    (lambda (&optional _prompt)
      (let (c)
        ;; Consume parameter bytes up to and including the final byte.
        (while (and (setq c (read-event nil nil 0.1))
                    (memq c (append "0123456789;:" nil))))
        []))))
(add-hook 'tty-setup-hook #'+amh/tty-swallow-csi-replies)

(defun +amh/reap-client-frames (&optional keep)
  "Delete every terminal client frame except KEEP.
I only ever want one attached terminal frame at a time, but a previous
`emacsclient -t' frame can outlive a non-clean SSH disconnect (dropped
connection / closed laptop / closed terminal app): sshd doesn't reap the old
pty + shell + emacsclient until its keepalive notices the client is gone, which
can lag for minutes. Until then the stale frame lingers, so the next reconnect
sees >1 client frame and persp-mode spawns a throwaway `#N' workspace for the
new one. Reaping the leftovers keeps the next frame landing straight in `main'.

`+amh/save-frame-state' is removed from `delete-frame-functions' for the loop
and its work done here instead — layout stashed per frame (last one wins, same
as before), `doom-save-session' run ONCE after the loop. Running the full persp
serialization per stale frame is a big blocking surface; with a dozen
accumulated zombie frames it once wedged the whole daemon mid-reap."
  (let ((reaped nil))
    (dolist (f (frame-list))
      (when (and (frame-parameter f 'client)
                 (not (eq f keep))
                 (frame-live-p f))
        (ignore-errors
          (setq +amh/last-window-state
                (window-state-get (frame-root-window f) t)))
        (let ((delete-frame-functions
               (remq #'+amh/save-frame-state delete-frame-functions)))
          (ignore-errors (delete-frame f t)))
        (setq reaped t)))
    (when reaped
      (let ((inhibit-message t))
        (ignore-errors (doom-save-session))))))

(defun +amh/restore-window-state-1 (frame)
  "Fix up a freshly-reconnected client FRAME.
The daemon stays alive and persp-mode keeps the real layout in `main'. If persp
parked us in a throwaway `#N' workspace (it does that whenever it sees more than
one client frame), switch to `main' so its stored layout replays, and reap the
empty throwaway. Then drop any leftover (zombie) client frames so only this one
remains. Finally, if a layout was stashed on a genuine frame-delete, replay it.

This is a safety net for the bare `emacsclient -t' path; the `e' wrapper already
reaps zombies *before* attaching, so the `#N' workspace is usually never created."
  (when (frame-live-p frame)
    (with-selected-frame frame
      (when (and (bound-and-true-p persp-mode) (fboundp '+workspace-switch))
        (let ((cur (safe-persp-name (get-current-persp))))
          (when (string-prefix-p "#" cur)
            (ignore-errors (+workspace-switch +workspaces-main))
            ;; reap the empty throwaway we just left; bind autokill off so this
            ;; can never kill a buffer that briefly landed in it (e.g. a Claude
            ;; vterm) — buffers it shares with `main' are untouched regardless.
            (ignore-errors
              (let ((p (gethash cur *persp-hash*)))
                (when (and p (not (seq-some #'doom-real-buffer-p (persp-buffers p))))
                  (let ((persp-autokill-buffer-on-remove nil))
                    (persp-kill cur))))))))
      (when +amh/last-window-state
        (ignore-errors
          (window-state-put +amh/last-window-state (frame-root-window) 'safe))))
    (+amh/reap-client-frames frame)))

(defun +amh/restore-window-state (&rest _)
  "Replay the last client frame's layout onto the freshly-created one.
Deferred on a short timer so persp-mode's emacsclient frame-init
(`+workspaces-associate-frame-fn': switches workspace, shows the dashboard, and
flashes the `[N] main' tabline ~0.1s later) has finished first; running last
makes our `window-state-put' authoritative. Note: this deliberately no longer
bails out when a second client frame is present — that guard is exactly what
left us stranded on the dashboard whenever a stale/dead frame from a dropped
SSH session overlapped the reconnect."
  (let ((frame (selected-frame)))
    (run-at-time 0.15 nil #'+amh/restore-window-state-1 frame)))

;; (b) Reload the saved session the first time a fresh daemon gets a frame -----
(defvar +amh/session-restored nil
  "Non-nil once the session has been auto-loaded for this daemon's lifetime.")

(defun +amh/maybe-restore-session (&rest _)
  "On the first client frame of a fresh daemon, reload the last saved session.
Guarded to a cold daemon (nothing file-backed open yet) so it never clobbers a
daemon you have already been working in."
  (when (and (daemonp)
             (not +amh/session-restored)
             (not (seq-some #'buffer-file-name (buffer-list)))
             (file-exists-p (doom-session-file)))
    (setq +amh/session-restored t)
    (let ((inhibit-message t))
      (ignore-errors (doom-load-session)))))

;; Order matters: restore the session (buffers) first, then re-apply the layout.
(add-hook 'server-after-make-frame-hook #'+amh/maybe-restore-session 10)
(add-hook 'server-after-make-frame-hook #'+amh/restore-window-state 90)
