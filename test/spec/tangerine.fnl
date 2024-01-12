(require-macros :runner)

(test "SETUP"
  (module tangerine :tangerine)

  (it "run setup"
    (tangerine.setup {
      :compiler { :hooks ["onload" "onsave"] }
      :keymaps  { :eval_buffer "EE" }
    }))

  (it "define commands"
    (eql (vim.fn.exists ":FnlBuffer") 2)
    (eql (vim.fn.exists ":FnlC")      3)
    (eql (vim.fn.exists ":FnlW")      3))

  (it "define hooks"
    (eql (vim.fn.exists "#tangerine-onload") 1)
    (eql (vim.fn.exists "#tangerine-onsave") 1))

  (it "define mappings"
    (eql (vim.fn.mapcheck :EE :n) ":FnlBuffer<CR>")))
