; ABOUT:
;   Basic utils around file system handlers.
(local fs {})

;; -------------------- ;;
;;         Main         ;;
;; -------------------- ;;
(lambda fs.readable? [path]
  "checks is 'path' is readable."
  (= 1 (vim.fn.filereadable path)))

(lambda fs.read [path]
  "returns contents of 'path' as string."
  (with-open [file (assert (io.open path :r))]
             (file:read "*a")))

(lambda fs.write [path content]
  "writes string of 'content' to 'path'."
  (local dir (path:match "(.*/)"))
  (if (= 0 (vim.fn.isdirectory dir))
      (vim.fn.mkdir dir :p))
  (with-open [file (assert (io.open path :w))]
             (file:write content)))

(lambda fs.remove [path ...]
  "recursively removes paths in {...}."
  (each [_ path (ipairs [path ...])]
    (each [_ file (ipairs (vim.fn.glob (.. path "/*") 0 1))]
          (os.remove file))
    (os.remove path))
  :return true)


:return fs
