; ABOUT:
;   Contains diffing algorithm used by compiler.
; 
;   Works by creating marker that looks like `-- :fennel:<UTC>`,
;   compares UTC in marker to ftime(source).
(local df {})

(lambda df.create-marker [source]
  "generates a comment tag from ftime of 'source'."
  (let [base "-- :fennel:"
        meta (vim.fn.getftime source)]
    (.. base meta)))

(lambda df.read-marker [path]
  "reads marker located in first 21 bytes of 'path'."
  (with-open [file (assert (io.open path "r"))]
    (local bytes  (or (file:read 21) ""))
    (local marker (bytes:match ":fennel:([0-9]+)"))
    (if marker 
        (tonumber marker)
        :else false)))

(lambda df.stale? [source target]
  "compares marker of 'target' with ftime(source), true if source is stale."
  (if (not= 1 (vim.fn.filereadable target))
      (lua "return true"))
  (let [source-time (vim.fn.getftime source)
        marker-time (df.read-marker target)]
    (not= source-time marker-time)))


:return df
