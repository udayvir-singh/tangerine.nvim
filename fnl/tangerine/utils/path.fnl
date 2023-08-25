; ABOUT:
;   Provides path manipulation and indexing functions
;
; DEPENDS:
; ALL() utils[env]
(local env (require :tangerine.utils.env))
(local p {})

;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(local windows? (= _G.jit.os "Windows"))

(lambda p.match [path pattern]
  "matches 'path' against 'pattern' with support for windows."
  (if windows?
    (path:match (pattern:gsub "/" "[\\/]"))
    (path:match pattern)))

(lambda p.gsub [path pattern repl]
  "substitutes 'pattern' in 'path' for 'repl' with support for windows."
  (if windows?
    (path:gsub (pattern:gsub "/" "[\\/]") repl)
    (path:gsub pattern repl)))

(lambda p.shortname [path]
  "shortens absolute 'path' for better readability."
  (or (p.match path ".+/fnl/(.+)")
      (p.match path ".+/lua/(.+)")
      (p.match path ".+/(.+/.+)")))

(lambda p.resolve [path]
  "resolves 'path' to POSIX complaint path."
  (vim.fn.resolve (vim.fn.expand path)))


;; ------------------------- ;;
;;     Path Transformers     ;;
;; ------------------------- ;;
(local vimrc-out (-> (env.get :target) (.. "tangerine_vimrc.lua")))

(lambda esc-regex [str]
  "escapes magic characters from 'str'."
  (str:gsub "[%%%^%$%(%)%[%]%{%}%.%*%+%-%?]" "%%%1"))

(lambda p.transform-path [path [key1 ext1] [key2 ext2]]
  "changes path's parent dir and extension."
  (let [from (.. "^" (esc-regex (env.get key1)))
        to   (esc-regex (env.get key2))
        path (path:gsub (.. "%." ext1 "$") (.. "." ext2))]
       (if (path:find from)
           (path:gsub from to)
           (p.gsub path (.. "/" ext1 "/") (.. "/" ext2 "/")))))

(lambda p.target [path]
  "converts fnl:'path' to valid target path."
  (let [vimrc (env.get :vimrc)]
    (if (= path vimrc)
        vimrc-out
        (p.transform-path path [:source "fnl"] [:target "lua"]))))

(lambda p.source [path]
  "converts lua:'path' to valid source path."
  (let [vimrc (env.get :vimrc)]
    (if (= path vimrc-out)
        vimrc
        (p.transform-path path [:target "lua"] [:source "fnl"]))))


;; -------------------- ;;
;;         Vim          ;;
;; -------------------- ;;
(lambda p.goto-output []
  "open lua:target of current fennel buffer."
  (let [source (vim.fn.expand :%:p)
        target (p.target source)]
    (if (and (= 1 (vim.fn.filereadable target))
             (not= source target))
        (vim.cmd (.. "edit" target))
        :else
        (print "[tangerine]: error in goto-output, target not readable."))))


;; -------------------- ;;
;;       Indexers       ;;
;; -------------------- ;;
(lambda p.wildcard [dir pat]
  "expands wildcard 'pat' inside of 'dir' and return array of paths."
  (vim.fn.glob (.. dir pat) 0 1))


:return p
