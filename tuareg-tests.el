;;; tests for tuareg.el                       -*- lexical-binding: t -*-

(require 'tuareg)
(require 'ert)

(ert-deftest tuareg-beginning-of-defun ()
  ;; Check that `beginning-of-defun' works as expected: move backwards
  ;; to the beginning of the current top-level definition (defun), or
  ;; the previous one if already at the beginning; return t if one was
  ;; found, nil if none.
  (with-temp-buffer
    (tuareg-mode)
    (let (p1 p2 p3 p4)
      (insert "(* first line *)\n\n")
      (setq p1 (point))
      (insert "type ty =\n"
              "  | Goo\n"
              "  | Baa of int\n\n")
      (setq p2 (point))
      (insert "let a = ho hum\n"
              ";;\n\n")
      (setq p3 (point))
      (insert "let g u =\n"
              "  while mo ma do\n"
              "    we wo;\n")
      (setq p4 (point))
      (insert "    ze zo\n"
              "  done\n")

      ;; Check without argument.
      (goto-char p4)
      (should (equal (beginning-of-defun) t))
      (should (equal (point) p3))
      (should (equal (beginning-of-defun) t))
      (should (equal (point) p2))
      (should (equal (beginning-of-defun) t))
      (should (equal (point) p1))
      (should (equal (beginning-of-defun) nil))
      (should (equal (point) (point-min)))

      ;; Check with positive argument.
      (goto-char p4)
      (should (equal (beginning-of-defun 1) t))
      (should (equal (point) p3))
      (goto-char p4)
      (should (equal (beginning-of-defun 2) t))
      (should (equal (point) p2))
      (goto-char p4)
      (should (equal (beginning-of-defun 3) t))
      (should (equal (point) p1))
      (goto-char p4)
      (should (equal (beginning-of-defun 4) nil))
      (should (equal (point) (point-min)))

      ;; Check with negative argument.
      (goto-char (point-min))
      (should (equal (beginning-of-defun -1) t))
      (should (equal (point) p1))
      (should (equal (beginning-of-defun -1) t))
      (should (equal (point) p2))
      (should (equal (beginning-of-defun -1) t))
      (should (equal (point) p3))
      (should (equal (beginning-of-defun -1) nil))
      (should (equal (point) (point-max)))

      (goto-char (point-min))
      (should (equal (beginning-of-defun -2) t))
      (should (equal (point) p2))
      (goto-char (point-min))
      (should (equal (beginning-of-defun -3) t))
      (should (equal (point) p3))
      (goto-char (point-min))
      (should (equal (beginning-of-defun -4) nil))
      (should (equal (point) (point-max)))

      ;; We don't test with a zero argument as the behaviour for that
      ;; case does not seem to be very well-defined.
      )))

(ert-deftest tuareg-chained-defun ()
  ;; Check motion by defuns that are chained by "and".
  (with-temp-buffer
    (tuareg-mode)
    (let (p0 p1 p2a p2b p3 p4 p5a p5b p6 p7 p8a p8b)
      (insert "(* *)\n\n")
      (setq p0 (point))
      (insert "type t1 =\n"
              "  A\n")
      (setq p1 (point))
      (insert "and t2 =\n"
              "  B\n")
      (setq p2a (point))
      (insert "\n")
      (setq p2b (point))
      (insert "and t3 =\n"
              "  C\n")
      (setq p3a (point))
      (insert "\n")
      (setq p3b (point))
      (insert "let f1 x =\n"
              "  aa\n")
      (setq p4 (point))
      (insert "and f2 x =\n"
              "  bb\n")
      (setq p5a (point))
      (insert "\n")
      (setq p5b (point))
      (insert "and f3 x =\n"
              "  let ff1 y =\n"
              "    cc\n"
              "  and ff2 y = (\n")
      (setq p6 (point))
      (insert "    qq ww) + dd\n"
              "  and ff3 y =\n"
              "    for i = 1 to 10 do\n"
              "      ee;\n")
      (setq p7 (point))
      (insert "      ff;\n"
              "    done\n")
      (setq p8a (point))
      (insert "\n")
      (setq p8b (point))
      (insert "exception E\n")

      ;; Walk backwards from the end.
      (goto-char (point-max))
      (beginning-of-defun)
      (should (equal (point) p8b))
      (beginning-of-defun)
      (should (equal (point) p5b))
      (beginning-of-defun)
      (should (equal (point) p4))
      (beginning-of-defun)
      (should (equal (point) p3b))
      (beginning-of-defun)
      (should (equal (point) p2b))
      (beginning-of-defun)
      (should (equal (point) p1))
      (beginning-of-defun)
      (should (equal (point) p0))
      (beginning-of-defun)
      (should (equal (point) (point-min)))

      ;; Walk forwards from the beginning.
      (end-of-defun)
      (should (equal (point) p1))
      (end-of-defun)
      (should (equal (point) p2a))
      (end-of-defun)
      (should (equal (point) p3a))
      (end-of-defun)
      (should (equal (point) p4))
      (end-of-defun)
      (should (equal (point) p5a))
      (end-of-defun)
      (should (equal (point) p8a))
      (end-of-defun)
      (should (equal (point) (point-max)))

      ;; Jumps from inside a defun.
      (goto-char p7)
      (beginning-of-defun)
      (should (equal (point) p5b))

      (goto-char p6)
      (end-of-defun)
      (should (equal (point) p8a)))))

(provide 'tuareg-tests)