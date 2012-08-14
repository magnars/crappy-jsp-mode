(define-derived-mode crappy-jsp-mode
  html-mode "JSP"
  "Major mode for jsp.
          \\{jsp-mode-map}"
  (setq indent-line-function 'jsp-indent-line))

(defun jsp-calculate-indent (&optional lcon)
  (unless lcon (setq lcon (sgml-lexical-context)))

  ;; Indent jsp-comment-start markers <%-- like whitespace
  (if (and (eq (car lcon) 'tag)
           (looking-at "--%")
           (save-excursion (goto-char (cdr lcon)) (looking-at "<%--")))
      (progn
        (forward-char 4)
        (max 0 (- (sgml-calculate-indent) 4)))
    (sgml-calculate-indent lcon)))

(defun jsp-indent-line ()
  "Indent the current line as jsp."
  (interactive)
  (let* ((savep (point))
         (indent-col
          (save-excursion
            (back-to-indentation)
            (if (>= (point) savep) (setq savep nil))
            (jsp-calculate-indent))))
    (if (null indent-col)
        'noindent
      (if savep
          (save-excursion (indent-line-to indent-col))
        (indent-line-to indent-col)))))

(provide 'crappy-jsp-mode)
