; DEPENDS:
; :return display[*]

(local modules {
  :dp  "tangerine.output.display"
  :log "tangerine.output.logger"
  :err "tangerine.output.error"
})

:return (setmetatable {} { 
  :__index #(require (. modules $2))
})
