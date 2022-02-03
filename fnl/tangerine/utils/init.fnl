; DEPENDS:
; :return tangerine.utils.**

(local modules {
  :p   "tangerine.utils.path"
  :fs  "tangerine.utils.fs"
  :df  "tangerine.utils.diff"
  :env "tangerine.utils.env"
  :log "tangerine.utils.logger"
  :err "tangerine.utils.error"
})

:return (setmetatable {} { 
  :__index #(require (. modules $2))
})
