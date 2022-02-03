; DEPENDS:
; (-string)  tangerine.fennel
; (-string)  tangerine.utils.logger
; (-file)    tangerine.utils.path
; (-file)    tangerine.utils.fs
(local fennel (require :tangerine.fennel))
(local {
  : p
  : fs
  : log
  : err
} (require :tangerine.utils))

;; -------------------- ;;
;;         Utils        ;;
;; -------------------- ;;
(lambda get-lines [start end]
  (-> (vim.api.nvim_buf_get_lines 0 (- start 1) end true)
      (table.concat "\n")))

(lambda softerr [msg]
  (vim.api.nvim_echo [[msg :Error]] false {}))

;; -------------------- ;;
;;         Main         ;;
;; -------------------- ;;
(lambda eval-string [str ?filename]
  (let [fennel (fennel.load)
        filename (or ?filename :string)]
       :eval   (local result (fennel.eval str {: filename}))
       :logger (log.value result)))

(lambda eval-file [path]
  "slurp 'path' and pass it off for evaluation."
  (let [path (p.resolve path)
        filename (p.shortname path)]
       :eval (eval-string (fs.read path) filename)))

(lambda eval-range [start end ?count]
  "evalute lines 'start' to 'end' in current vim buffer."
  (when (= ?count 0)
    (softerr "[tangerine]: error in \"eval-range\", Missing argument {range}.")
    (lua :return))
  (let [lines   (get-lines start end)
        bufname (vim.fn.expand :%)]
       (err.clear) ; clear previous errors
       :eval (local (ok? res) (pcall #(eval-string lines bufname)))
       (if ok? :skip
           (err.compile? res)
           (err.send (err.parse res))
           :else
           (softerr res))))

(lambda eval-buffer []
  "evaluate all lines in current vim buffer."
  :eval ";)" (eval-range 1 -1))

:return {
  :string eval-string         
  :file   eval-file
  :range  eval-range
  :buffer eval-buffer
}
