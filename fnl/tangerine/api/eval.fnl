; ABOUT:
;   Functions for interactive fennel evaluation.
;
; DEPENDS:
; (-file)         utils[fs]
; (-file)         utils[path]
; (-string -peak) fennel
; (-string -peak) output[display]
; (-string -peak) output[error]
(local fennel (require :tangerine.fennel))
(local {
  : p
  : fs
} (require :tangerine.utils))

(local {
  : dp
  : err
} (require :tangerine.output))

(local eval {})

;; -------------------- ;;
;;         Utils        ;;
;; -------------------- ;;
(lambda get-lines [start end]
  "returns lines 'start' to 'end' as string in current buffer."
  (-> (vim.api.nvim_buf_get_lines 0 start end true)
      (table.concat "\n")))

(lambda get-bufname []
  "returns name of current buffer, parses [No Name] correctly."
  (let [bufname (vim.fn.expand :%:t)]
    (if (not= bufname "") bufname
        :else "[No Name]")))

(lambda tbl-merge [tbl1 tbl2]
  "merges 'tbl1' onto 'tbl2'."
  (vim.tbl_extend "keep" tbl1 tbl2))


;; -------------------- ;;
;;         Eval         ;;
;; -------------------- ;;
(lambda eval.string [str ?opts]
  "evaluate string 'str' of fennel, pretty prints the output."
  ;; opts { :filename string :offset number :float boolean :virtual boolean }
  (local opts (or ?opts {}))
  (let [fennel   (fennel.load)
        filename (or opts.filename :string)]
    (err.clear) ;; clear previous errors
    (local (ok result) 
      (xpcall #(fennel.eval str {: filename}) 
              #(err.handle $1 opts)))
    (if ok
        (dp.show result {:float opts.float}))))

(lambda eval.file [path ?opts]
  "reads 'path' and passes it off for evaluation."
  ;; opts { :filename string :float boolean :virtual boolean }
  (local opts (or ?opts {}))
  (let [path  (p.resolve path)
        sname (p.shortname path)]
    :eval (eval.string (fs.read path) 
                       (tbl-merge opts {:filename sname}))))

(lambda eval.buffer [start end ?opts]
  "evaluate lines 'start' to 'end' in current vim buffer."
  ;; opts { :filename string :float boolean :virtual boolean }
  (local opts (or ?opts {}))
  (let [start   (- start 1)
        lines   (get-lines start end)
        bufname (get-bufname)]
    :eval (eval.string lines (tbl-merge opts {:filename bufname :offset start}))))

; EXAMPLES:
; (eval.string "(print :hell) :out" {:filename "file" :offset nil :float true})
; (eval.file "%" {:filename "file" :float true})
; (eval.buffer 1 -27 {:filename "file" :float true})


;; -------------------- ;;
;;       Peaking        ;;
;; -------------------- ;;
(lambda eval.peak [start end ?opts]
  "lookup lua output for lines 'start' to 'end' inside scratch buffer."
  ;; opts { :filename string :float boolean :virtual boolean }
  (local opts (or ?opts {}))
  (let [fennel  (fennel.load)
        start   (- start 1)
        lines   (get-lines start end)
        bufname (get-bufname)]
    (err.clear) ;; clear previous errors
    (local (ok result) 
      (xpcall #(fennel.compileString lines {:filename (or opts.filename bufname)}) 
              #(err.handle $1 (tbl-merge {:offset start} opts))))
    (if ok
        (dp.show-lua result opts))))

; EXAMPLES:
; (eval.peak 1 -8 {:float true :virtual true :filename "FILE"})


:return eval
