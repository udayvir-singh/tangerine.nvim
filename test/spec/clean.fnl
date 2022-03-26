(require-macros :runner)

(test "CLEANING API"
  (module fs    :tangerine.utils.fs)
  (module clean :tangerine.api.clean)

  ;; -------------------- ;;
  ;;        Utils         ;;
  ;; -------------------- ;;
  (lambda setup-src [dir n]
    "writes 'n' of mock fennel files in 'dir'."
    (for [hex 10 (+ 9 n)]
         (fs.write (string.format :%s/%x.fnl dir hex) ":return 1")))

  (lambda setup-out [dir n]
    "writes 'n' of mock lua files in 'dir'."
    (fs.write (string.format :%s/normal.lua dir) "return 1")
    (for [hex 10 (+ 9 n)]
         (fs.write (string.format :%s/%x.lua dir hex)  "-- :fennel:0000000000\nreturn 1")))


  ;; -------------------- ;;
  ;;        Tests         ;;
  ;; -------------------- ;;
  (local config (vim.fn.stdpath :config))
  (local source (.. config :/fnl))
  (local target (.. config :/lua))
  (local rtpdir (.. config :/rtp))

  (it "clean target"
    (setup-src source 1)
    (setup-out target 2)

    (eql (clean.target :/dev/null (.. target :/normal.lua)) false)
    (eql (clean.target :/dev/null (.. target :/a.lua))      false)

    (eql (clean.target (.. source :/b.fnl) (.. target :/b.lua)) true)

    (fs.remove source target))


  (it "clean rtp"
    (setup-out rtpdir 1)

    (eql (clean.rtp {:rtpdirs ["rtp"] :verbose false})
         ["rtp/a.lua"])

    (fs.remove rtpdir))


  (it "clean orphaned"
    (setup-src source 1)
    (setup-out target 2)
    (setup-out rtpdir 1)

    (eql (clean.orphaned {:rtpdirs ["rtp"] :verbose false :force true})
         ["rtp/a.lua" "a.lua" "b.lua"])

    (fs.remove source target rtpdir)))
