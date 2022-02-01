; DEPENDS:
; (-string)             tangerine.fennel
; (-file -vimrc)        tangerine.utils.fs
; (-vimrc -all)         tangerine.utils.env
; EXCEPT(-string)       tangerine.utils.p
; EXCEPT(-string)       tangerine.utils.diff
; EXCEPT(-string -file) tangerine.utils.log
(local fennel (require :tangerine.fennel))
(local {
  : p
  : fs
  : df
  : env
  : log
} (require :tangerine.utils))

;; -------------------- ;;
;;      Low Level       ;;
;; -------------------- ;;
(lambda compile-string [str ?filename]
  "compiles given fennel::'str' to lua."
  (let [fennel (fennel.load)]
       (fennel.compileString str {:filename ?filename})))

(lambda compile-file [source target]
  "slurps fnl:'source' and compiles it to lua:'target'."
  (let [source (p.resolve source)
        target (p.resolve target)
        sname  (p.shortname source)] 
       (if (not (fs.readable? source))
           (error (.. "[tangerine]: source " sname " is not readable.")))
       (let [output (compile-string (fs.read source) sname)
             marker (df.create-marker source)]
            (->> (.. marker "\n" output)
                 (fs.write target)))))

(lambda compile-dir [sourcedir targetdir ?opts]
  "diff compiles fnl files in 'sourcedir' and barfs it to targetdir."
  ;; ?opts {:verbose boolean :force boolean}
  (local opts (or ?opts {}))
  (local sources  (p.wildcard sourcedir "**/*.fnl"))
  (local logs [])
  (each [_ source (ipairs sources)]
    (let [luafile (source:gsub ".fnl$" ".lua")
          target  (luafile:gsub sourcedir targetdir)
          compile? (or opts.force (df.stale? source target))]
         (when compile?
             (table.insert logs (p.shortname source))
             :compile (compile-file source target))))
  :logger (log.compiled logs opts.verbose))


;; -------------------- ;;
;;      High Level      ;;
;; -------------------- ;;
(fn compile-buffer [opts]
  "compiles the current active vim buffer."
  ;; opts {:verbose boolean}
  (let [opts (or opts {})
        bufname (vim.fn.expand :%:p)
        target  (p.target bufname)]
      :compile (compile-file bufname target)
      :logger (log.compiled-buffer opts.verbose)))

(fn compile-vimrc [opts]
  "diff compiles ENV.vimrc to ENV.target dir."
  ;; opts {:verbose boolean :force boolean}
  (let [opts (or opts {})
        vimrc  (env.get :vimrc)
        target (p.target vimrc)
        compile? (or opts.force (df.stale? vimrc target))]
       (when (and compile? (fs.readable? vimrc)
                  :compile (compile-file vimrc target))
         :logger (log.compiled [(p.shortname vimrc)] opts.verbose)
         :return true)))

(fn compile-all [opts]
  "diff compiles all indexed fnl files, present in ENV.source dir."
  ;; opts {:verbose boolean :force boolean}
  (local opts (or opts {}))
  (local logs [])
  (if (compile-vimrc opts)
      (table.insert logs (p.shortname (env.get :vimrc))))
  (each [_ source (ipairs (p.list-fnl-files))]
    (let [target (p.target source)
          compile? (or opts.force (df.stale? source target))]
         (when compile?
             (table.insert logs (p.shortname source))
             :compile (compile-file source target))))
  :logger (log.compiled logs opts.verbose))


; Examples
; (compile-file "~/a.fnl" "~/a.lua")
; (compile-dir 
;    "~/tangerine/fnl" "~/tangerine/lua"
;    {:force true :verbose true})
; (compile-buffer {:verbose true})
; (compile-vimrc {:force true :verbose true})
; (compile-all {:force true :verbose true})

:return {
  :string compile-string         
  :file   compile-file
  :dir    compile-dir
  :buffer compile-buffer
  :vimrc  compile-vimrc
  :all    compile-all
}
