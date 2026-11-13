;;; init.el --- Basic IDE setup: ivy/counsel, projectile, magit, eglot -*- lexical-binding: t; -*-

;; macOS only; requires Emacs 29+.

(setq read-process-output-max (* 1024 1024))

(require 'comp)
(setq native-comp-driver-options
      (cons "-mmacosx-version-min=14.0" native-comp-driver-options))

(setq custom-file (expand-file-name "custom.el" user-emacs-directory))
(when (file-exists-p custom-file) (load custom-file))

(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu"   . "https://elpa.gnu.org/packages/")))
(package-initialize)

;; Refresh stale package metadata once when installation fails.
(defvar my/package-refreshed nil)

(unless package-archive-contents
  (package-refresh-contents)
  (setq my/package-refreshed t))

(define-advice package-install (:around (orig pkg &rest args) refresh-on-failure)
  (condition-case err
      (apply orig pkg args)
    (error
     (if my/package-refreshed
         (signal (car err) (cdr err))
       (setq my/package-refreshed t)
       (package-refresh-contents)
       (apply orig pkg args)))))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile (require 'use-package))
(setq use-package-always-ensure t)

(use-package diminish)

;; GUI Emacs on macOS does not inherit the shell PATH needed by tools.
(use-package exec-path-from-shell
  :if (memq window-system '(mac ns))
  :config (exec-path-from-shell-initialize))

(add-hook 'prog-mode-hook #'display-line-numbers-mode)
(add-hook 'text-mode-hook #'visual-line-mode)
(column-number-mode 1)
(show-paren-mode 1)
(global-hl-line-mode 1)

(set-face-attribute 'default nil :font "SF Mono-12")

(setq inhibit-startup-screen t
      ring-bell-function 'ignore
      visible-bell nil
      make-backup-files nil
      auto-save-default nil
      create-lockfiles nil
      use-short-answers t)

(use-package doom-themes
  :config
  (setq doom-themes-enable-bold t
        doom-themes-enable-italic t)
  (load-theme 'doom-ayu-dark t))

(custom-set-faces
 '(line-number ((t (:foreground "#5c6370" :background unspecified))))
 '(line-number-current-line
   ((t (:foreground "#abb2bf" :background unspecified :weight bold)))))

(use-package doom-modeline
  :init (doom-modeline-mode 1))

;; Run M-x nerd-icons-install-fonts once after installing the package.
(use-package nerd-icons
  :if (display-graphic-p))

(use-package which-key
  :diminish
  :config
  (setq which-key-idle-delay 0.5)
  (which-key-mode 1))

(use-package ligature
  :config
  (ligature-set-ligatures 't '("www"))
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi"))
  (ligature-set-ligatures
   'prog-mode
   '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***"
     "||=" "||>" ":::" "::=" "=:=" "===" "==>" "=!="
     "=>>" "=<<" "=/=" "!==" "!!." ">=>" ">>=" ">>>"
     ">>-" ">->" "->>" "-->" "---" "-<<" "<~~" "<~>"
     "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->"
     "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###"
     "#_(" "..<" "..." "+++" "/==" "///" "_|_" "www"
     "&&" "^=" "~~" "~@" "~=" "~>" "~-" "**" "*>" "*/"
     "||" "|}" "|]" "|=" "|>" "|-" "{|" "[|" "]#"
     "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:"
     ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*"
     "<|" "<:" "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{"
     "#[" "#:" "#=" "#!" "##" "#(" "#?" "#_" "%%" ".="
     ".-" ".." ".?" "+>" "++" "?:" "?=" "?." "??" ";;"
     "/*" "/=" "/>" "//" "__" "~~" "(*" "*)" "\\\\" "://"))
  (global-ligature-mode t))

(setq-default c-basic-offset 4
              tab-width 4
              indent-tabs-mode nil)

(delete-selection-mode 1)
(electric-pair-mode 1)
(global-auto-revert-mode 1)
(recentf-mode 1)
(savehist-mode 1)
(save-place-mode 1)
(setq recentf-max-saved-items 200)

(global-set-key (kbd "C-#") #'comment-or-uncomment-region)
(global-set-key (kbd "C-x k") #'kill-current-buffer)
(global-set-key (kbd "M-o") #'other-window)

(use-package ivy
  :diminish
  :bind
  (("C-s" . swiper)
   ("C-r" . swiper-backward)
   ("C-c C-r" . ivy-resume)
   :map ivy-minibuffer-map
   ("TAB" . ivy-alt-done)
   ("C-j" . ivy-next-line)
   ("C-k" . ivy-previous-line)
   ("C-l" . ivy-alt-done))
  :config
    (setq ivy-initial-inputs-alist nil
      ivy-use-virtual-buffers t
        ivy-count-format "(%d/%d) "
        ivy-wrap t
        case-fold-search t)
  (ivy-mode 1))

(use-package counsel
  :after ivy
  :diminish
  :bind
  (("M-x"     . counsel-M-x)
   ("C-x C-f" . counsel-find-file)
   ("C-x b"   . counsel-switch-buffer)
  ("C-x C-r" . counsel-recentf)
  ("C-c s"   . counsel-rg)
  ("C-c i"   . counsel-imenu)
   ("C-h f"   . counsel-describe-function)
   ("C-h v"   . counsel-describe-variable)
   ("M-y"     . counsel-yank-pop))
  :config (counsel-mode 1))

(use-package swiper :after ivy)

(use-package ivy-rich
  :after counsel
  :config (ivy-rich-mode 1))

(use-package ivy-prescient
  :after counsel
  :config
  (prescient-persist-mode 1)
  (ivy-prescient-mode 1))

(use-package projectile
  :diminish
  :init
  (setq projectile-project-search-path '("~/code" "~/projects" "~/src")
        projectile-completion-system 'ivy
        projectile-switch-project-action #'projectile-find-file)
  :bind-keymap ("C-c p" . projectile-command-map)
  :config (projectile-mode 1))

(use-package counsel-projectile
  :after (counsel projectile)
  :config (counsel-projectile-mode 1))
(use-package magit
  :bind (("C-x g"   . magit-status)
         ("C-c g b" . magit-blame-addition)
         ("C-c g l" . magit-log-buffer-file)
         ("C-c g d" . magit-diff-buffer-file))
  :config
  (setq magit-display-buffer-function
        #'magit-display-buffer-same-window-except-diff-v1))
(use-package diff-hl
  :hook ((prog-mode . diff-hl-mode)
         (text-mode . diff-hl-mode)
         (magit-pre-refresh  . diff-hl-magit-pre-refresh)
         (magit-post-refresh . diff-hl-magit-post-refresh))
  :config (diff-hl-flydiff-mode 1))

(use-package treemacs
  :bind (("<f8>"   . treemacs)
         ("C-c t"  . treemacs-select-window))
  :config
  (setq treemacs-width 32)
  (treemacs-follow-mode 1)
  (treemacs-filewatch-mode 1))

(use-package treemacs-projectile :after (treemacs projectile))
(use-package treemacs-magit :after (treemacs magit))

(use-package company
  :diminish
  :hook (after-init . global-company-mode)
  :bind (:map company-active-map
              ("TAB"   . company-complete-selection)
              ("<tab>" . company-complete-selection)
              ("C-n"   . company-select-next)
              ("C-p"   . company-select-previous))
  :config
  (setq company-idle-delay 0.2
        company-minimum-prefix-length 2
        company-tooltip-align-annotations t))

(use-package eglot
  :ensure nil
  :hook ((go-mode         . eglot-ensure)
         (rust-mode       . eglot-ensure)
         (python-mode     . eglot-ensure)
         (c-mode          . eglot-ensure)
         (c++-mode        . eglot-ensure)
         (js-mode         . eglot-ensure)
         (typescript-mode . eglot-ensure))
  :bind (:map eglot-mode-map
              ("C-c l r" . eglot-rename)
              ("C-c l a" . eglot-code-actions)
              ("C-c l f" . eglot-format)
              ("C-c l h" . eldoc)
              ("C-c l d" . xref-find-definitions)
              ("C-c l u" . xref-find-references))
  :config
  (setq eglot-autoshutdown t))
(use-package flymake
  :ensure nil
  :hook (prog-mode . flymake-mode)
  :bind (:map flymake-mode-map
              ("M-n" . flymake-goto-next-error)
              ("M-p" . flymake-goto-prev-error)
              ("C-c ! l" . flymake-show-buffer-diagnostics)))

(use-package apheleia
  :diminish
  :config (apheleia-global-mode 1))

;; Requires cmake, libtool, and libvterm; first launch compiles the module.
(use-package vterm
  :commands vterm
  :bind (("C-c v" . vterm)
         ("C-z"   . vterm)
         :map vterm-mode-map
         ("C-z" . vterm-send-C-z))
  :config
  (setq vterm-max-scrollback 10000
        vterm-kill-buffer-on-exit t))

(setq compilation-scroll-output t)
(global-set-key (kbd "<f5>") #'projectile-compile-project)
(global-set-key (kbd "<f6>") #'recompile)

(use-package go-mode)

;; Defer optional language packages so broken installs do not block startup.
(use-package rust-mode
  :mode "\\.rs\\'"
  :defer t)
(use-package cargo
  :hook (rust-mode . cargo-minor-mode)
  :defer t)

(use-package python
  :ensure nil
  :config (setq python-indent-offset 4))

(use-package typescript-mode
  :mode "\\.ts\\'"
  :defer t)
(use-package yaml-mode
  :mode "\\.ya?ml\\'"
  :defer t)
(use-package markdown-mode
  :mode "\\.md\\'"
  :defer t)

(use-package dashboard
  :demand t
  :bind ("C-x a" . dashboard-open)
  :config
  (setq dashboard-center-content t
        dashboard-banner-logo-title "hello world"
        dashboard-startup-banner '("~/.emacs.d/avatar.png" . "~/.emacs.d/avatar.txt")
        dashboard-projects-backend 'projectile
        dashboard-items '((recents  . 8)
                          (projects . 8)
                          (bookmarks . 5))
        initial-buffer-choice #'dashboard-open)
  (dashboard-setup-startup-hook))
