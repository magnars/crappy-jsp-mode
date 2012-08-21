(define-derived-mode crappy-jsp-mode
  html-mode "Crappy JSP"
  "Major mode for jsp.
          \\{jsp-mode-map}"
  (setq indent-line-function 'jsp-indent-line))

(defun cjsp--in-script-tag (lcon)
  (and (eq (car lcon) 'text)
       (cdr lcon)
       (save-excursion
         (goto-char (cdr lcon))
         (looking-back "<script>"))))

(defun cjsp--script-indentation ()
  (if (or (looking-back "<script>[\n\t ]+")
          (looking-at "</script>"))
      (sgml-calculate-indent)
    (js--proper-indentation (save-excursion
                              (syntax-ppss (point-at-bol))))))

(defun cjsp--in-jsp-comment (lcon)
  (and (eq (car lcon) 'tag)
       (looking-at "--%")
       (save-excursion (goto-char (cdr lcon)) (looking-at "<%--"))))

(defun cjsp--jsp-comment-indentation ()
  (forward-char 4)
  (max 0 (- (sgml-calculate-indent) 4)))

(defun jsp-calculate-indent (&optional lcon)
  (unless lcon (setq lcon (sgml-lexical-context)))
  (cond
   ((cjsp--in-script-tag lcon)  (cjsp--script-indentation))
   ((cjsp--in-jsp-comment lcon) (cjsp--jsp-comment-indentation))
   (t                           (sgml-calculate-indent lcon))))

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
