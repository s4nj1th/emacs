;; Disable UI elements
(tool-bar-mode -1)
(menu-bar-mode -1)
(scroll-bar-mode -1)
(fringe-mode '(1 . 1))

;; Enable line numbers and visual lines
(global-display-line-numbers-mode 1)
(global-visual-line-mode 1)

;; Set indentation defaults
(setq-default c-basic-offset 4
              tab-width 4
              indent-tabs-mode nil)

;; Frame size
(push '(width . 94) default-frame-alist)
(push '(height . 50) default-frame-alist)

;; Transparency
;; (set-frame-parameter (selected-frame) 'alpha '(95 95))
;; (add-to-list 'default-frame-alist '(alpha 90 90))

;; Keybindings
(global-set-key (kbd "C-x a") #'dashboard-open)
(global-set-key (kbd "C-z") #'shell)
(global-set-key (kbd "C-#") #'comment-or-uncomment-region)

;; Package management
(require 'package)
(setq package-archives
      '(("melpa" . "https://melpa.org/packages/")
        ("gnu"   . "https://elpa.gnu.org/packages/")))

(unless (package-installed-p 'use-package)
  (package-refresh-contents)
  (package-install 'use-package))

(eval-when-compile
  (require 'use-package))

(setq use-package-always-ensure t)

;; Font
(set-face-attribute 'default nil :font "SF Mono-12")

;; Theme
(use-package ewal-doom-themes
  :init (load-theme 'ewal-doom-one t))

;; Ligatures
(use-package ligature 
  :config 
  (ligature-set-ligatures 't '("www")) 
  (ligature-set-ligatures 'eww-mode '("ff" "fi" "ffi")) 
  (ligature-set-ligatures 'prog-mode '("|||>" "<|||" "<==>" "<!--" "####" "~~>" "***" "||=" "||>" ":::" "::=" "=:=" "===" "==>" "=!=" "=>>" "=<<" "=/=" "!==" "!!." ">=>" ">>=" ">>>" ">>-" ">->" "->>" "-->" "---" "-<<" "<~~" "<~>" "<*>" "<||" "<|>" "<$>" "<==" "<=>" "<=<" "<->" "<--" "<-<" "<<=" "<<-" "<<<" "<+>" "</>" "###" "#_(" "..<" "..." "+++" "/==" "///" "_|_" "www" "&&" "^=" "~~" "~@" "~=" "~>" "~-" "**" "*>" "*/" "||" "|}" "|]" "|=" "|>" "|-" "{|" "[|" "]#" "::" ":=" ":>" ":<" "$>" "==" "=>" "!=" "!!" ">:" ">=" ">>" ">-" "-~" "-|" "->" "--" "-<" "<~" "<*" "<|" "<:" "<$" "<=" "<>" "<-" "<<" "<+" "</" "#{" "#[" "#:" "#=" "#!" "##" "#(" "#?" "#_" "%%" ".=" ".-" ".." ".?" "+>" "++" "?:" "?=" "?." "??" ";;" "/*" "/=" "/>" "//" "__" "~~" "(*" "*)" "\\\\" "://")) 
  (global-ligature-mode t))

;; Dashboard
(use-package dashboard
  :config
  (dashboard-setup-startup-hook)
  (setq dashboard-center-content t
        dashboard-banner-logo-title "hello world"
        dashboard-startup-banner '("~/.emacs.d/avatar.png" . "~/.emacs.d/avatar.txt")
        inhibit-startup-screen t))

;; Ivy, Counsel, Swiper - Fixed keybinding syntax
(use-package ivy
  :diminish
  :bind (("C-s" . swiper)
         ("C-r" . swiper)
         :map ivy-minibuffer-map
         ("TAB" . ivy-alt-done)
         ("C-j" . ivy-next-line)
         ("C-k" . ivy-previous-line)
         ("C-l" . ivy-alt-done))
  :config
  (setq ivy-initial-inputs-alist nil
        ivy-use-virtual-buffers t
        ivy-count-format "(%d/%d) "
        case-fold-search t)
  (ivy-mode 1))

(use-package go-mode)

(use-package cargo)

(use-package counsel
  :after ivy
  :bind (("M-x" . counsel-M-x)
         ("C-x C-f" . counsel-find-file)
         ("C-x b" . counsel-switch-buffer)))

(use-package swiper 
  :after ivy)

;; Customizations
(custom-set-variables
 ;; custom-set-variables was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(auto-save-default nil)
 '(custom-enabled-themes '(doom-ayu-dark))
 '(custom-safe-themes
   '("5244ba0273a952a536e07abaad1fdf7c90d7ebb3647f36269c23bfd1cf20b0b8"
     "9b9d7a851a8e26f294e778e02c8df25c8a3b15170e6f9fd6965ac5f2544ef2a9"
     default))
 '(package-selected-packages
   '(cargo counsel dashboard ewal-doom-themes go-mode ivy ligature swiper
           use-package)))

(custom-set-faces
 ;; custom-set-faces was added by Custom.
 ;; If you edit it by hand, you could mess it up, so be careful.
 ;; Your init file should contain only one such instance.
 ;; If there is more than one, they won't work right.
 '(line-number ((t (:foreground "#5c6370" :background nil))))
 '(line-number-current-line ((t (:foreground "#abb2bf" :background nil :weight bold)))))

;; Startup settings
(setq inhibit-startup-screen t
      ring-bell-function 'ignore
      visible-bell nil)
