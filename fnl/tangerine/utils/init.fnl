; DEPENDS:
; :return utils[*]

(local modules {
  :p   "tangerine.utils.path"
  :fs  "tangerine.utils.fs"
  :df  "tangerine.utils.diff"
  :env "tangerine.utils.env"
  :srl "tangerine.utils.srlize"
  :win "tangerine.utils.window"
})

:return (setmetatable {} {
  :__index #(require (. modules $2))
})
