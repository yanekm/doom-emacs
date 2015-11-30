;;; module-python.el

(use-package python
  :mode ("\\.py\\'" . python-mode)
  :interpreter ("python"   . python-mode)
  :commands python-mode
  :init
  (add-hook! python-mode '(narf|enable-tab-width-4 emr-initialize narf|flycheck-enable-maybe))
  (setq-default
   python-indent-offset 4
   python-environment-directory narf-temp-dir
   python-shell-interpreter "ipython")
  :config
  (define-env-command! python-mode "python --version | cut -d' ' -f2")

  ;; interferes with smartparens
  (define-key python-mode-map (kbd "DEL") nil)

  (use-package nose
    :commands nose-mode
    :preface (defvar nose-mode-map (make-sparse-keymap))
    :init
    (associate! nose-mode :pattern "/test_.+\\.py\\'")
    :config
    (map! :map nose-mode-map
          (:localleader
           :n "tr" 'nosetests-again
           :n "ta" 'nosetests-all
           :n "ts" 'nosetests-one
           :n "tv" 'nosetests-module
           :n "tA" 'nosetests-pdb-all
           :n "tO" 'nosetests-pdb-one
           :n "tV" 'nosetests-pdb-module)))

  (use-package anaconda-mode
    :diminish anaconda-mode
    :defines (anaconda-mode-map anaconda-nav-mode-map)
    :functions (anaconda-mode-running-p)
    :init
    (add-hook! python-mode '(anaconda-mode eldoc-mode))
    (setq anaconda-mode-installation-directory (concat narf-temp-dir "anaconda/"))
    :config
    (map! :map anaconda-mode-map     :m "gd"     'anaconda-mode-goto-definitions)
    (map! :map anaconda-nav-mode-map :n [escape] 'anaconda-nav-quit)

    (advice-add 'anaconda-mode-doc-buffer :after 'narf*anaconda-mode-doc-buffer)

    (after! company
      (require 'company-anaconda)
      (define-company-backend! python-mode (anaconda)))
    (after! emr
      (mapc (lambda (x)
              (let ((command-name (car x))
                    (title (cadr x))
                    (region-p (caddr x))
                    predicate)
                (setq predicate (lambda () (and (anaconda-mode-running-p)
                                           (not (use-region-p))
                                           (not (sp-point-in-string-or-comment)))))
                (emr-declare-command (intern (format "anaconda-mode-%s" (symbol-name command-name)))
                  :title title :modes 'python-mode :predicate predicate)))
            '((show-doc          "view documentation" t)
              (find-assignments  "find assignments"  t)
              (find-definitions  "find definitions"  t)
              (find-file         "find assignments"  t)
              (find-references   "show usages"  nil))))))

(provide 'module-python)
;;; module-python.el ends here
