(local df {})

(lambda df.create-marker [source]
  "generate a meta tag from 'source' for target."
  (let [base "-- :fennel:"
        meta (vim.fn.getftime source)]
    (.. base meta)))

(lambda df.read-marker [path]
  "reads 'marker' located in first 21 bytes."
  (with-open [file (assert (io.open path "r"))]
      (local bytes (file:read 21))
      (local marker (string.match (or bytes "") "fennel:(.*)"))
      (if (not (and marker bytes))
          false
          (tonumber marker))))

(lambda df.stale? [source target]
  "diffs 'source' and 'target'. (true) if target is stale"
  (if (= 1 (vim.fn.filereadable target))
    (let [source-time (vim.fn.getftime source)
          target-marker (df.read-marker target)]
      (not= source-time target-marker))
    true))


:return df
