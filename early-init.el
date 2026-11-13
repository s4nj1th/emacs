;;; early-init.el --- Runs before the first frame and package.el -*- lexical-binding: t; -*-

;; Defer GC during startup, then restore a practical limit.
(setq gc-cons-threshold most-positive-fixnum)
(add-hook 'emacs-startup-hook
          (lambda () (setq gc-cons-threshold (* 50 1024 1024))))

(setq package-enable-at-startup nil)

(push '(menu-bar-lines . 0)   default-frame-alist)
(push '(tool-bar-lines . 0)   default-frame-alist)
(push '(vertical-scroll-bars) default-frame-alist)
(push '(left-fringe . 8)      default-frame-alist)
(push '(right-fringe . 8)     default-frame-alist)
(push '(width . 94)           default-frame-alist)
(push '(height . 50)          default-frame-alist)

(setq frame-inhibit-implied-resize t
      inhibit-startup-screen t)

;;; early-init.el ends here
