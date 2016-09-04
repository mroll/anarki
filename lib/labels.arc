(mac labels (fns . forms)
 (with (fnames (map car fns)
        fbodies (map (fn (f) `(fn ,@(cdr f))) fns))
  `(with ,(mappend (fn (name) `(,name nil)) fnames)
      (= ,@(mappend (fn (f) `(,(car f) ,@(cdr f))) (zip fnames fbodies)))
      ,@forms)))

; (def collatz-seq (n)
;  (labels ((collatz (n)
;            (if (even n)
;             (/ n 2)
;             (+ (* n 3) 1)))
;           (worker (n seq)
;            (if (is n 1)
;             (cons n seq)
;             (worker (collatz n) (cons n seq)))))
;    (rev (worker n '()))))
; 
; (def parity (n)
;   (labels ((even (n)
;              (if (is n 0)
;                'even
;                (odd (- n 1))))
;            (odd (n)
;              (if (is n 0)
;                'odd
;                (even (- n 1)))))
;           (even n)))
; 
; (prn (macex1 '(labels ((even (n)
;              (if (is n 0)
;                'even
;                (odd (- n 1))))
;            (odd (n)
;              (if (is n 0)
;                'odd
;                (even (- n 1)))))
;           (even n))))
; 
; (prn "")
; 
; (prn (parity 17))
; (prn (parity 24))
; 
; (prn (collatz-seq 21))
; 
; ;; ---------------------------------------------
; 
; =>  (with (even nil odd nil)
; =>    (= even (fn (n)
; =>              (if (is n 0)
; =>                (quote even)
; =>                (odd (- n 1))))
; =>       odd (fn (n)
; =>             (if (is n 0)
; =>               (quote odd)
; =>               (even (- n 1)))))
; =>    (even n))
; =>  
; =>  odd
; =>  even
; =>  (21 64 32 16 8 4 2 1)
