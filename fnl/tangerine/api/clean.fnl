; DEPENDS:
; (-target)           tangerine.utils.fs
; (-target)           tangerine.utils.diff
; (-target -orphaned) tangerine.utils.path
; (-target -orphaned) tangerine.utils.logger
(local {
  : p
  : fs
  : df
  : log
} (require :tangerine.utils))

(lambda clean-target [target ?force]
  "checks if lua:'target' is Marked and has a readable fnl:source, if not
   then it deletes 'target'."
  (let [target  (p.resolve target)
        marker? (df.read-marker target)
        source? (fs.readable? (p.source target))]
    (if (and marker? (or (not source?) (= ?force true)))
        (fs.remove target)
        :else false)))

(lambda clean-orphaned [?opts]
  "delete orphaned lua:files present in ENV.target dir."
  ;; opts {:verbose boolean :force boolean}
  (let [opts (or ?opts {})
        logs []]
    (each [_ target (ipairs (p.list-lua-files))]
          (if (clean-target target opts.force) 
              (table.insert logs (p.shortname target))))
    :logger (log.cleaned logs)))

; (clean-orphaned {:verbose true :force false})

:return {
  :target   clean-target
  :orphaned clean-orphaned  
}
