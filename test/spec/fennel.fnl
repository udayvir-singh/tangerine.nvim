(require-macros :runner)

(test "FENNEL API"
  (module fennel :tangerine.fennel)

  (it "loads fennel"
    (eql (. (fennel.load)         :version) "1.5.1")
    (eql (. (fennel.load :latest) :version) "1.5.1")
    (eql (. (fennel.load :1-0-0)  :version) "1.0.0"))

  (it "setup fennel.path"
    (fnd (. (fennel.load) :path)       "home/.-/init.fnl")
    (fnd (. (fennel.load) :macro-path) "home/.-/init%-macros.fnl"))

  (it "patch package.path"
    (fnd (fennel.patch-path) "home/.-/.config/nvim/lua/%?.lua")
    (eql (fennel.patch-path) (fennel.patch-path))))
