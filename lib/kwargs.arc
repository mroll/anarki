(mac iter (var lst . body)
    (w/uniq (i elst)
      `(let ,elst ,lst
        (if (is ,elst nil)
          nil
          (withs (,i 0
                  ,var (,elst ,i)
                  next (fn ()
                         (++ ,i)
                         (= ,var (,elst ,i))))
            (while (< ,i (len ,elst))
              (= ,var (,elst ,i))
              ,@body
              (++ ,i)))))))

(def 1+ (n)
  (+ 1 n))

(def default-kwvals (argnames)
  (mappend (fn (name) (if (atom name)
                        `(,name nil)
                        `(,(car name) ,@(cdr name))))
           argnames))

;; Set up a context w/ positional arguments assigned to the correct values
(mac w/posargs (argnames argsvar . body)
  `(with ,(intersperse nil argnames)
     (= ,@(mappend (fn (name idx) `(,name (,argsvar ,idx)))
               argnames (range 0 (len argnames))))
     ,@body))

;; Set up a context w/ keyword arguments assigned to the correct values
(mac w/kwargs (kwargs argsvar . body)
  (with (arg (uniq)
         justnames (map (fn (name) (if (atom name)
                                     name
                                     (car name)))
                        kwargs))
    `(with ,(default-kwvals kwargs)
       (iter ,arg ,argsvar
         (case ,arg
           ,@(mappend (fn (a) `(,a (= ,a (next)))) justnames)))
       ,@body)))
    
;; 'named def' wraps the function body in a context that handles keyword arguments.
;; keyword args can have default values if they are given as a list. the car of
;; the list will serve as the name, the cdr as the default val.
(mac ndef (name _args . body)
  (withs (kwstart (pos '--keys _args)
          pargs   (firstn kwstart _args)
          kwargs  (nthcdr (1+ kwstart) _args))
    `(def ,name args
       (w/posargs ,pargs args
         (w/kwargs ,kwargs args
           ,@body)))))

(ndef fullname (msg --keys (first "Abe") (last "Lincoln"))
  (prn first " " last " says " msg))

(fullname "four score and...")
; => Abe Lincoln says four score and..."

(fullname "hey, you sass that hoopy frood...?" 'last "Prefect" 'first "Ford")
; => Ford Prefect says hey, you sass that hoopy frood...?

(mac argparse (args . case-body)
  (let arg (uniq)
    `(iter ,arg ,args
       (case ,arg
         ,@case-body))))

(def scrape (addr . args)
  (with (outfile ((tokens addr #\/) -1)
         use-ssl nil)
    (argparse args
      -o   (= outfile (next))
      -ssl (= use-ssl t))
    (prn outfile)
    (prn use-ssl)))

(ndef scrape (addr --keys (outfile ((tokens addr #\/) -1)) use-ssl)
  (prn outfile)
  (prn use-ssl))


(scrape "www.foo.com/index.html" '-o "foo.html")
; => foo.html
;    t
