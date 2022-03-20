; ABOUT:
;   Functions to diff compile fennel files.
;
; DEPENDS:
; (-string)        fennel
; (-file)          utils[fs]
; (-file compile?) utils[diff]
; (-file)          output[err]
; (compile.*)      utils[path]
; (compile.*)      output[log]
; ALL()            utils[env]
(local fennel (require :tangerine.fennel))
(local {
  : p
  : fs
  : df
  : env
  : win
} (require :tangerine.utils))

(local {
  : log
  : err
} (require :tangerine.output))

(local compile {})

;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(lambda quoted [str]
  "surrounds 'str' with double quotes."
  (let [qt "\""]
    (.. qt str qt)))

(lambda compiled [source]
  "prints compiled message for 'source'."
  (print (quoted source) "compiled"))

(lambda compile? [source target opts]
  "if opts.force != true, then diffs 'source' against 'target'"
  (or (env.conf opts [:compiler :force])
      (df.stale? source target)))

(lambda merge [list1 list2]
  "merges values of 'list2' onto 'list1'."
  (each [_ val (ipairs list2)]
        (table.insert list1 val))
  list1)

(lambda tbl-merge [tbl1 tbl2]
  "merges 'tbl1' onto 'tbl2'."
  (vim.tbl_extend "keep" (or tbl1 {}) tbl2))

(macro halt [x]
  "halts current scope if list 'x' returns 0 or false."
  `(let [out# ,x]
     (if (or (= 0 out#) (= false out#))
         (lua "return 0"))
     out#))

(macro hpcall [func handler]
  "safely calls 'func', runs 'handler' on error and halts current scope."
  `(halt (xpcall ,func ,handler)))

(macro hmerge [lst x]
  "merge output of 'x' onto 'lst', halts current scope on error."
  `(let [out# (or ,x [])]
     (halt out#)
     (merge ,lst out#)))


;; -------------------- ;;
;;      Low Level       ;;
;; -------------------- ;;
(lambda compile.string [str ?opts]
  "compiles given fennel::'str' to lua."
  ;; opts { :filename string :globals list }
  (local opts (or ?opts {}))
  (let [fennel   (fennel.load)
        filename (or opts.filename "tangerine-out")
        globals  (env.conf opts [:compiler :globals])]
       (fennel.compileString str 
                             {:filename filename :allowedGlobals globals :compilerEnv _G})))

(lambda compile.file [source target ?opts]
  "slurps fnl:'source' and compiles it to lua:'target'."
  ;; opts { :filename string :globals list }
  (local opts (or ?opts {}))
  (let [source (p.resolve source)
        target (p.resolve target)
        sname  (p.shortname source)
        opts   (tbl-merge opts {:filename sname})] 
       (if (not (fs.readable? source))
           (err.soft 
             (.. "[tangerine]: source " (or sname source) " is not readable.")))
       :compile
       (let [marker (df.create-marker source)
             output (compile.string (fs.read source) opts)]
         (fs.write target
                   (.. marker "\n" output))
         :return true)))

(lambda compile.dir [sourcedir targetdir ?opts]
  "diff compiles fennel files in 'sourcedir' and outputs it to 'targetdir'."
  ;; opts { :force boolean :verbose boolean :float boolean :globals list }
  (local opts (or ?opts {}))
  (local logs [])
  (each [_ source (ipairs (p.wildcard sourcedir "**/*.fnl"))]
        (local sname  (p.shortname source))
        (local opts   (tbl-merge {:filename sname} opts))
        (local target 
          (-> source 
              (string.gsub :fnl$ :lua)
              (string.gsub (p.resolve sourcedir) (p.resolve targetdir))))
        :compile
        (when (compile? source target opts)
          (table.insert logs sname)
          (hpcall #(compile.file source target opts)
                  #(log.failure "COMPILE ERROR" sname $1 opts))))
  :logger (log.success "COMPILED" logs opts)
  :return logs)

; EXAMPLES:
; (compile.string ":string nope" {:globals [:nope] :filename "test"})
; (compile.file "~/a.fnl" "~/a.lua" {:globals [:nope] :filename "test"})
; (compile.dir
;   "~/cool/testci/fnl"
;   "~/cool/testci/fua"
;   {:force true :verbose true :float true})


;; -------------------- ;;
;;      High Level      ;;
;; -------------------- ;;
(lambda compile.buffer [?opts]
  "compiles the current active vim buffer."
  ;; opts { :float boolean :verbose boolean :filename string :globals list }
  (local opts (or ?opts {}))
  (let [bufname (vim.fn.expand :%:p)
        sname   (vim.fn.expand :%:t)
        target  (p.target bufname)]
    :compile 
    (hpcall #(compile.file bufname target (tbl-merge opts {:filename sname}))
            #(log.failure "COMPILE ERROR" sname $1 opts))
    :logger 
    (if (env.conf opts [:compiler :verbose])
        (compiled sname))
    :return true))

(lambda compile.vimrc [?opts]
  "diff compiles ENV.vimrc to ENV.target dir."
  ;; opts { :force boolean :float boolean :verbose boolean :filename string :globals list }
  (local opts (or ?opts {}))
  (let [source (env.get :vimrc)
        target (p.target source)
        sname  (p.shortname source)]
    (when (compile? source target opts)
      :compile
      (hpcall #(compile.file source target opts)
              #(log.failure "COMPILE ERROR" sname $1 opts))
      :logger 
      (if (env.conf opts [:compiler :verbose])
          (compiled sname))
      :return [sname])))

(lambda compile.rtp [?opts]
  "diff compiles files in ENV.rtpdirs or 'opts.rtpdirs'"
  ;; opt { :rtpdirs list :force boolean :float boolean :verbose boolean :globals list }
  (local opts (or ?opts {}))
  (local logs [])
  (local dirs (env.conf opts [:rtpdirs]))
  :compile
  (each [_ dir (ipairs dirs)]
        (hmerge logs (compile.dir dir dir (tbl-merge {:verbose false} opts))))
  :logger 
  (log.success "COMPILED RTP" logs opts)
  :return logs)

(lambda compile.all [?opts]
  "diff compiles all indexed fennel files in ENV."
  ;; opt { :rtpdirs list :force boolean :float boolean :verbose boolean :globals list }
  (local opts  (or ?opts {}))
  (local copts (tbl-merge {:verbose false} opts))
  (local logs  [])
  :compile
  (hmerge logs (compile.vimrc copts))
  (each [_ source (ipairs (p.list-fnl-files))]
        (local target (p.target source))
        (local sname  (p.shortname source))
        (when (compile? source target opts)
          (table.insert logs sname)
          (hpcall #(compile.file source target opts)
                  #(log.failure "COMPILE ERROR" sname $1 opts))))
  (hmerge logs (compile.rtp copts))
  :logger
  (log.success "COMPILED" logs opts)
  :return logs)

; EXAMPLES:
; (compile.buffer {:verbose true})
; (compile.vimrc {:force true :verbose true})
; (compile.rtp {:force true :verbose true :rtpdirs [:plugin]})
; (compile.all {:force true :verbose true :rtpdirs [:plugin]})


:return compile
