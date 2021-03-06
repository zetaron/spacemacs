;;; packages.el --- Syntax Checking Layer packages File for Spacemacs
;;
;; Copyright (c) 2012-2020 Sylvain Benner & Contributors
;;
;; Author: Sylvain Benner <sylvain.benner@gmail.com>
;; URL: https://github.com/syl20bnr/spacemacs
;;
;; This file is not part of GNU Emacs.
;;
;;; License: GPLv3

(setq syntax-checking-packages
      '(
        flycheck
        flycheck-pos-tip
        popwin
        ))

(defun syntax-checking/init-flycheck ()
  (use-package flycheck
    :defer t
    :init
    (progn
      (spacemacs|add-transient-hook prog-mode-hook
        (lambda () (when syntax-checking-enable-by-default
                     (global-flycheck-mode 1)))
        lazy-load-flycheck)
      (setq flycheck-standard-error-navigation syntax-checking-use-standard-error-navigation
            flycheck-global-modes nil)
      ;; key bindings
      (spacemacs/set-leader-keys
        "eb" 'flycheck-buffer
        "ec" 'flycheck-clear
        "eh" 'flycheck-describe-checker
        "el" 'spacemacs/toggle-flycheck-error-list
        "eL" 'spacemacs/goto-flycheck-error-list
        "es" 'flycheck-select-checker
        "eS" 'flycheck-set-checker-executable
        "ev" 'flycheck-verify-setup
        "ey" 'flycheck-copy-errors-as-kill
        "ex" 'flycheck-explain-error-at-point)
      (spacemacs|add-toggle syntax-checking
        :mode flycheck-mode
        :documentation "Enable error and syntax checking."
        :evil-leader "ts"))
    :config
    (progn
      (spacemacs|diminish flycheck-mode " ⓢ" " s")
      ;; Custom fringe indicator
      (when (and (fboundp 'define-fringe-bitmap)
                 (not syntax-checking-use-original-bitmaps))
        (define-fringe-bitmap 'my-flycheck-fringe-indicator
          (vector #b00000000
                  #b00000000
                  #b00000000
                  #b00000000
                  #b00000000
                  #b00000000
                  #b00000000
                  #b00011100
                  #b00111110
                  #b00111110
                  #b00111110
                  #b00011100
                  #b00000000
                  #b00000000
                  #b00000000
                  #b00000000
                  #b00000000)))
      (let ((bitmap (if syntax-checking-use-original-bitmaps
                        'flycheck-fringe-bitmap-double-arrow
                      'my-flycheck-fringe-indicator)))
        (flycheck-define-error-level 'error
          :severity 2
          :overlay-category 'flycheck-error-overlay
          :fringe-bitmap bitmap
          :error-list-face 'flycheck-error-list-error
          :fringe-face 'flycheck-fringe-error)
        (flycheck-define-error-level 'warning
          :severity 1
          :overlay-category 'flycheck-warning-overlay
          :fringe-bitmap bitmap
          :error-list-face 'flycheck-error-list-warning
          :fringe-face 'flycheck-fringe-warning)
        (flycheck-define-error-level 'info
          :severity 0
          :overlay-category 'flycheck-info-overlay
          :fringe-bitmap bitmap
          :error-list-face 'flycheck-error-list-info
          :fringe-face 'flycheck-fringe-info))

      (evilified-state-evilify-map flycheck-error-list-mode-map
        :mode flycheck-error-list-mode
        :bindings
        "RET" 'flycheck-error-list-goto-error
        "j" 'flycheck-error-list-next-error
        "k" 'flycheck-error-list-previous-error))))

(defun syntax-checking/init-flycheck-pos-tip ()
  (use-package flycheck-pos-tip
    :if syntax-checking-enable-tooltips
    :defer t
    :init
    (with-eval-after-load 'flycheck
      (flycheck-pos-tip-mode)
      (setq flycheck-pos-tip-timeout (or syntax-checking-auto-hide-tooltips 0)))))

(defun syntax-checking/pre-init-popwin ()
  (spacemacs|use-package-add-hook popwin
    :post-config
    (push '("^\\*Flycheck.+\\*$"
            :regexp t
            :dedicated t
            :position bottom
            :stick t
            :noselect t)
          popwin:special-display-config)))
