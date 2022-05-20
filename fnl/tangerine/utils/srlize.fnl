; ABOUT:
;   Serializes lua data structures into fennel syntax.

;; -------------------- ;;
;;        UTILS         ;;
;; -------------------- ;;
(fn table? [x]
  "checks if 'x' is of table type."
  (= :table (type x)))

(fn list? [x]
  "checks if 'x' is proper list without gaps."
  (if (not= :table (type x))
      (lua "return false"))
  (var prev 0)
  (each [key (pairs x)]
    (if (not= key (+ prev 1))
        (lua "return false"))
    (set prev key))
  :return true)

(lambda tab [n]
  "generates string with 'n' number of tabs."
  (.. "\n" (string.rep "\t" n)))

(macro append [name ...]
  "append 'str' to variable 'name'."
  (local out [])
  (each [_ val (ipairs [...])]
    (table.insert out `(or ,val "")))
  `(set-forcibly! ,name (.. ,name ,(unpack out))))

(macro gaurd [expr val]
  "returns 'val' from current scope if 'expr' is truthy."
  `(let [,(sym :out) ,(or val expr)]
     (if ,expr (lua "return out"))))


;; -------------------- ;;
;;        DEBUG         ;;
;; -------------------- ;;
(lambda time* [name runs handler]
  "times function 'handler' for n 'runs'."
  (local start (os.clock))
  (for [i 1 runs]
    (handler))
  (local end (os.clock))
  (print (string.format "%-8s: %s" name (/ (- end start) runs))))

(macro time [name runs ...]
  `(time* ,name ,runs (fn [] ,...)))


;; -------------------- ;;
;;       SORTING        ;;
;; -------------------- ;;
(local priority {
  :number   1
  :boolean  2
  :string   3
  :function 4
  :table    5
  :thread   6
  :userdata 7
})

(lambda compare [x y]
  "compares 'x' against 'y' for their sort position."
  (let [tx (type x) ty (type y)]
    (if
      ; compare by priority
      (not= tx ty)
      (< (. priority tx) (. priority ty))
      ; compare numbers
      (= tx :number)
      (< x y)
      ; compare strings
      (= tx :string)
      (let [lhs (string.lower (x:gsub "[_-]" ""))
            rhs (string.lower (y:gsub "[_-]" ""))]
        (if (= lhs rhs)
            (< x y) ; tiebreak
            (< lhs rhs)))
      ; compare hex values
      (< (tostring x) (tostring y)))))

(lambda order-keys [tbl]
  "returns sorted list of keys in 'tbl'."
  (local keys (vim.tbl_keys tbl))
  (table.sort keys compare)
  :return keys)

(lambda onext [tbl ?state]
  "returns next ordered value in 'tbl' by 'state'."
  ; order keys
  (var key nil)
  (local mtbl (or (getmetatable tbl) {}))
  (if (= ?state nil)
      (do (set mtbl.__okeys (order-keys tbl))
          (set key (. mtbl.__okeys 1)))
      :else
      (for [i 1 (# (or mtbl.__okeys []))]
        (if (= ?state (. mtbl.__okeys i))
            (set key (. mtbl.__okeys (+ 1 i))))))
  ; cleanup
  (when (= nil key)
    (set mtbl.__okeys nil)
    (and (= 0 (# (vim.tbl_keys mtbl)))
         (setmetatable tbl nil))
    (lua :return))
  ; return next
  (setmetatable tbl mtbl)
  (values key (. tbl key)))

(lambda opairs [tbl]
  "tis de' holy pairs!"
  (values onext tbl nil))


;; -------------------- ;;
;;        STORE         ;;
;; -------------------- ;;
(local default-store #{
  :refs {
    :function {:n 0}
    :table    {:n 0}
    :thread   {:n 0}
    :userdata {:n 0}
  }
  :cycles {}
})

(var store (default-store))

(fn add-cycle [x]
  "recursively adds count of cycles in 'x' to store."
  (gaurd (not (table? x)))
  (let [count (. store.cycles x)]
    ; increment count
    (tset store.cycles x (+ 1 (or count 0)))
    ; count children and metatable
    (when (not count)
      (add-cycle (getmetatable x))
      (each [k v (pairs x)]
        (add-cycle k)
        (add-cycle v)))))

(lambda recursive? [tbl]
  "checks if 'tbl' is seen more than one times."
  (not= 1 (or (. store.cycles tbl) 1)))

(lambda add-ref [val]
  "adds reference of 'val' in store."
  (let [tv  (type val)
        ref (+ 1 (. store.refs tv :n))]
    (tset store.refs tv val ref)
    (tset store.refs tv "n" ref)
    :return ref))

(lambda get-ref [val]
  "gets and parses reference of 'val' in store."
  (let [tv  (type val)
        ref (. store.refs tv val)]
    :return
    (and ref (string.format "(%s %s)" tv ref))))


;; -------------------- ;;
;;       PARSING        ;;
;; -------------------- ;;
(local parse (setmetatable
  {
    ; "reference schema for table parse."
    :primitive nil
    :list      nil
    :key       nil
    :table     nil
    :metatable nil

    :this
    (lambda [parse val level]
      (if (list? val)
          (parse.list val level)
          (table? val)
          (parse.table val level)
          :else
          (parse.primitive val)))
  }
  {
    :__call
    (fn [parse val level]
      "converts 'val' into human readable form."
      (gaurd (= nil val) :nil)
      ; parse value
      (add-cycle val)
      (local out (parse:this val level))
      ; reset store
      (set store (default-store))
      :return out)
  }))


; ---------------------- ;
;       PRIMITIVES       ;
; ---------------------- ;
(local escapes {
  "\a" "\\a"
  "\b" "\\b"
  "\f" "\\f"
  "\n" "\\n"
  "\r" "\\r"
  "\t" "\\t"
  "\v" "\\v"
})

(lambda double-quote [str]
  "double quotes 'str' after properly escaping it."
  (.. "\34"
      (-> str
          (string.gsub "\\" "\\\\")
          (string.gsub "\34" "\\\34")
          (string.gsub "%c" #(or (. escapes $) (.. "\\" (string.byte $)))))
      "\34"))

(lambda parse.primitive [val ?dry]
  "parses 'val' like a caveman."
  (local tv (type val))
  (if (= :string tv)
      (double-quote val)
      (or (= :number  tv) (= :boolean tv))
      (tostring val)
      :else
      (string.format "(%s %s)" tv (if ?dry :nil (add-ref val)))))


; ---------------------- ;
;         LISTS          ;
; ---------------------- ;
(lambda multi-line? [list level ?key]
  "determines if 'list' should be displayed on multiple lines."
  (gaurd (recursive? list))
  (gaurd (getmetatable list))
  ; estimate width of output
  (var width (+ 3 (# (or ?key "")) (* level vim.o.shiftwidth)))
  (each [_ val (ipairs list)]
    (if (table? val)
        (lua "return true"))
    (set width (+ width 1 (# (parse.primitive val true)))))
  :return
  (> width (vim.api.nvim_win_get_width 0)))

(lambda parse.list [list level ?key]
  "parses 'list' of definite dimensions."
  (gaurd (get-ref list))
  (gaurd (= 0 (# list)) "{}")
  ; check for recursion
  (var ref "")
  (if (recursive? list)
      (set ref (string.format " ; (%s)" (add-ref list))))
  ; parse list
  (var ml  (multi-line? list level ?key))
  (var out "")
  (each [idx val (ipairs list)]
    (local sep (if ml (tab level) (not= idx 1) " "))
    (append out sep
            (parse:this val (+ 1 level))))
  ; parse metatable
  (local mtbl (parse.metatable list (+ level 1)))
  :return
  (.. "[" ref out mtbl (if ml (tab (- level 1)) "") "]"))


; ---------------------- ;
;         TABLES         ;
; ---------------------- ;
(lambda keyword? [x]
  "checks if 'x' can be used as fennel keyword."
  (and (= :string (type x))
       (not (string.find x "[%s%c%(%)%[%]%{%}\34\39\96,;@~]"))))

(lambda parse.key [x level]
  "parses 'key' of a table."
  (if (keyword? x)
      (.. ":" x)
      (parse:this x (+ level 1))))

(lambda key-padding [tbl]
  "calculates padding after keys in 'tbl'."
  (var out {})
  (var buf [])
  (var len 1)
  (fn checkout []
    "puts keys in 'buf' with 'len' to 'out'."
    (each [_ key (ipairs buf)]
      (tset out key (- len (length key))))
    (set buf [])
    (set len 1))
  (each [key val (opairs tbl)]
    (if (and (= :string (type key))
             (not= :table (type val)))
        ; push key in buffer and update len
        (let [klen (+ 1 (# key))]
          (table.insert buf key)
          (if (> klen len)
              (set len klen)))
        ; checkout buffer to out
        (do (checkout)
            (tset out key 1))))
  (checkout)
  :return out)

(lambda parse.table [tbl level]
  "parses key:val 'tbl' into human readable form."
  (gaurd (get-ref tbl))
  ; check for recursion
  (var ref "")
  (if (recursive? tbl)
      (set ref (string.format " ; (%s)" (add-ref tbl))))
  ; parse table
  (var out "")
  (var pad (key-padding tbl))
  (each [k v (opairs tbl)]
    (append out
      (tab level)
      (parse.key  k (+ level 1))
      (string.rep " " (. pad k))
      (parse:this v (+ level 1))))
  ; parse metatable
  (local mtbl (parse.metatable tbl (+ level 1)))
  :return
  (.. "{" ref out mtbl (tab (- level 1)) "}"))

(lambda parse.metatable [tbl level]
  "parses value of metatable in 'tbl'."
  (local mtbl (getmetatable tbl))
  (gaurd (= nil mtbl) "")
  :return
  (.. (tab (- level 1)) "(metatable) " (parse:this mtbl level)))


;; -------------------- ;;
;;      SERIALIZE       ;;
;; -------------------- ;;
(lambda serialize [...]
  "returns human-readable representation of {...}."
  (local args [...])
  ; parse single value
  (gaurd (>= 1 (# args))
         (.. ":return " (parse (. args 1) 1)))
  ; parse multiple values
  (var out "")
  (each [_ val (ipairs args)]
    (append out (tab 1) (parse val 2)))
  (.. "(values" out "\n)"))

; EXAMPLES:
; (local {: win} (require :tangerine.utils))
; (win.set-float (serialize vim) :fennel :normal)
;
; (time :serialize 5 (serialize _G))


:return serialize
