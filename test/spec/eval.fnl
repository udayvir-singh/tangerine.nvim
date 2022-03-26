(require-macros :runner)

(test "EVAL API"
  (module fs   :tangerine.utils.fs)
  (module eval :tangerine.api.eval)

  (it "eval string"
    (eql (eval.string "1" {:float false}) 1)

    (eval.string "1")
    (eql (float-lines) ":return 1")
    
    (eval.string "foo" {:filename "test.fnl"})
    (fnd (float-lines) "test.fnl.+strict mode: foo"))


  (it "eval file"
    (let [source "/tmp/eval.fnl"]
      (fs.write source ":eval [1]")
      
      (eql (eval.file source {:float false}) [1])

      (fs.remove source)))
  

  (it "eval buffer"
    (with-buf [:test.fnl gl sl]
      (sl [":return 1"])

      (eval.buffer 1 -1)
      (eql (float-lines) ":return 1")))


  (it "eval peak"
    (with-buf [:test.fnl gl sl]
      (sl ["(print 1)"])

      (eval.peak 1 -1)
      (eql (float-lines) "return print(1)"))))
