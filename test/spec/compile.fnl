(require-macros :runner)

(test "COMPILER API"
  (module fs      :tangerine.utils.fs)
  (module compile :tangerine.api.compile)

  ;; -------------------- ;;
  ;;        UTILS         ;;
  ;; -------------------- ;;
  (local config (vim.fn.stdpath :config))

  (lambda setup [dir ?file]
    "writes mock fennel files in 'dir' or 'file'."
    (local content ":return 1")
    (if ?file
        (fs.write (.. dir "/" ?file) content)
        (for [hex 10 11]
             (fs.write (string.format "%s/%x.fnl" dir hex) content))))

  (lambda check [target]
    "checks if lua::'target' is correctly compiled."
    (fnd (fs.read target) "-- :fennel:.+return 1"))


  ;; -------------------- ;;
  ;;        TESTS         ;;
  ;; -------------------- ;;
  (it "compile string"
    (eql (compile.string ":return 1") "return 1")
    (err (compile.string ":return vim" {:filename "test.fnl" :globals []})
         "test.fnl.-unknown identifier.-vim"))

  (it "compile file"
    (let [parent :/tmp/compile
          source (.. parent "/a.fnl")
          target (.. parent "/a.lua")]
      (setup parent)
      (compile.file source target)
      (check target)
      (fs.remove parent)))

  (it "compile dir"
    (let [source "/tmp/compile"
          target "/tmp/output"]
      (setup source)
      (compile.dir source target {:verbose false})
      (check (.. target "/b.lua"))
      (fs.remove source target)))

  (it "compile custom"
    (let [source "/tmp/compile"
          target "/tmp/output"]
      (setup source)
      (eql (compile.custom {:custom [[source target]] :verbose false})
           ["compile/a.fnl" "compile/b.fnl"])
      (check (.. target "/b.lua"))
      (fs.remove source target)))

  (it "compile vimrc"
    (let [vimrc  (.. config "/init.fnl")
          target (.. config "/lua/tangerine_vimrc.lua")]
      (setup "/" vimrc)
      (compile.vimrc {:verbose false})
      (check target)
      (fs.remove vimrc target)))

  (it "compile rtp"
    (let [dir (.. config "/rtp")]
      (setup dir)
      (compile.rtp {:rtpdirs ["rtp"] :verbose false})
      (check (.. dir "/b.lua"))
      (fs.remove dir)))

  (it "compile all"
    (let [vimrc  (.. config "/init.fnl")
          rtpdir (.. config "/rtp")
          source (.. config "/fnl")
          target (.. config "/lua") ]
      (setup rtpdir)
      (setup source)
      (setup "/" vimrc)
      (eql (compile.all {:rtpdirs ["rtp"] :verbose false})
           ["nvim/init.fnl" "a.fnl" "b.fnl" "rtp/a.fnl" "rtp/b.fnl"])
      (eql (compile.all {:rtpdirs ["rtp"] :verbose false})
           [])
      (fs.remove rtpdir source target vimrc))))
