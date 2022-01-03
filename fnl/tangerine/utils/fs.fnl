(local fs {})

;; -------------------- ;;
;;      Directory       ;;
;; -------------------- ;;
(lambda fs.dirname [path]
  (path:match "(.*[/\\])"))

(lambda fs.mkdir [path]
  (vim.fn.mkdir path :p))

(lambda fs.dir-exists? [dirpath]
  (= 1 (vim.fn.isdirectory dirpath)))

;; -------------------- ;;
;;        Files         ;;
;; -------------------- ;;
(lambda fs.read [path]
  (with-open [file (assert (io.open path "r"))]
    (file:read "*a")))

(lambda fs.readable? [path]
  (= 1 (vim.fn.filereadable path)))

(lambda fs.write [path content]
  (let [dir (fs.dirname path)]
    (when (not (fs.dir-exists? dir))
      (fs.mkdir dir))
    (with-open [file (assert (io.open path :w))]
      (file:write content))))

:return fs
