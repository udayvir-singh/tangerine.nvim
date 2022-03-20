; ABOUT:
;   Contains functions to create and control floating windows.
;
; DEPENDS:
; (nmap!) utils[env]
(local env (require :tangerine.utils.env))
(local win {})

;; -------------------- ;;
;;        Stack         ;;
;; -------------------- ;;
(local win-stack { 
  ; "contains list of active floats in [win conf] chunks" 
  :total 0
})

(lambda insert-stack [win*]
  "insert 'win*' into win-stack."
  (table.insert win-stack [win* (vim.api.nvim_win_get_config win*)]))

(lambda remove-stack [idx* conf*]
  "removes window at 'idx*' and re-positions leading windows."
  (each [idx [win conf] (ipairs win-stack)]
        (when (and (< idx* idx) (vim.api.nvim_win_is_valid win))
          (tset conf :row false (+ (. conf :row false) conf*.height 2))
          (vim.api.nvim_win_set_config win conf)))
  (table.remove win-stack idx*))

(lambda normalize-parent [win*]
  "switch to parent buffer of 'win*' if exists."
  (each [idx [win conf] (ipairs win-stack)]
        (if (= win win*)
            (vim.api.nvim_set_current_win conf.win))))

(lambda update-stack []
  "scans win-stack for any changes, updates total and deletes stale windows."
  (var total 0)
  (each [idx [win conf] (ipairs win-stack)]
      (if (vim.api.nvim_win_is_valid win)
          (set total (+ total conf.height 2))
          :else
          (remove-stack idx conf)))
  (tset win-stack :total total)
  :return true)

(let [{: timer} {:timer (vim.loop.new_timer)}] ;; cache timer
  "auto update win-stack every 200ms."
  (timer:start 200 200 
               (vim.schedule_wrap update-stack)))


;; -------------------- ;;
;;      Navigation      ;;
;; -------------------- ;;
(lambda move-stack [start steps]
  "navigate between win-stack from 'start', N 'steps' from current window."
  (var index start)
  (each [idx [win conf] (ipairs win-stack)]
        (local idx* (+ idx steps))
        (if (and (= win (vim.api.nvim_get_current_win)) (. win-stack idx*))
            (set index idx*)))
  (if (. win-stack index)
      (vim.api.nvim_set_current_win (. win-stack index 1))))

(lambda win.next [?steps]
  "switch to next floating window by [N] steps."
  (move-stack 1 (or ?steps +1)))

(lambda win.prev [?steps]
  "switch to previous floating window by [N] steps."
  (move-stack (# win-stack) (* -1 (or ?steps 1))))

(lambda win.resize [n]
  "changes the heigth of current floating window by factor of 'n'."
  (var n n)
  (var idx* (+ (# win-stack) 1)) ; make starting index out of bounds
  (each [idx [win conf] (ipairs win-stack)]
    (when (= win (vim.api.nvim_get_current_win))
      (if (>= 0 (+ conf.height n))
          (set n (- 1 conf.height)))
      (set idx* idx)
      (tset conf :height (+ conf.height n)))
    (when (<= idx* idx)
      (tset conf :row false (- (. conf :row false) n))
      (vim.api.nvim_win_set_config win conf)))
  :return true)

(lambda win.close []
  "closes current floating window, switch to nearest neighbor afterwards."
  (let [current (vim.api.nvim_get_current_win)]
    (each [idx [win conf] (ipairs win-stack)]
          (when (= win current)
            (vim.api.nvim_win_close win true)
            (update-stack)
            (move-stack 
              (if (. win-stack idx) idx
                  (. win-stack (+ idx 1)) (+ idx 1) 
                  (- idx 1)) 
              (do :steps 0))))
    :return true))

(lambda win.killall []
  "reset win-stack, close all windows inside."
  (for [idx 1 (# win-stack)]
    (vim.api.nvim_win_close (. win-stack idx 1) true)
    (tset win-stack idx nil))
  (tset win-stack :total 0)
  :return true)


;; -------------------- ;;
;;        Utils         ;;
;; -------------------- ;;
(lambda lineheight [lines]
  "calculates height occupied by 'lines' relative to window's width."
  (var height 0)
  (let [width (vim.api.nvim_win_get_width 0)]
    (each [_ line (ipairs lines)]
      (set height
           (-> (# line) (+ 2) (/ width)
               (math.ceil)
               (math.max 1)
               (+ height))))
    :return height))

(lambda nmap! [buffer ...]
  "defines a local mapping to 'buffer' for [lhs rhs] chunks in multi args."
  (each [_ [lhs rhs] (ipairs [...])]
    (vim.api.nvim_buf_set_keymap buffer :n lhs (.. "<cmd>" rhs "<CR>") {:silent true :noremap true})))

(lambda setup-mappings [buffer]
  "setup floating window mappings defined in ENV for 'buffer'."
  (local w (env.get :keymaps :float))
  (nmap! buffer
    [w.next    :FnlWinNext]
    [w.prev    :FnlWinPrev]
    [w.kill    :FnlWinKill]
    [w.close   :FnlWinClose]
    [w.resizef "FnlWinResize 1"]
    [w.resizeb "FnlWinResize -1"]))


;; -------------------- ;;
;;        Window        ;;
;; -------------------- ;;
(lambda win.create-float [lineheight filetype highlight]
  "defines a floating window with height 'lineheight'."
  (normalize-parent (vim.api.nvim_get_current_win))
  (let [buffer     (vim.api.nvim_create_buf false true)
        win-width  (vim.api.nvim_win_get_width 0)
        win-height (vim.api.nvim_win_get_height 0)
        bordersize 2
        width      (- win-width bordersize)
        height     (math.max 1 (math.floor (math.min (/ win-height 1.5) lineheight)))]
  (vim.api.nvim_open_win buffer true {
    : width 
    : height
    :col 0
    :row (- win-height bordersize height win-stack.total)
    :style "minimal"
    :anchor "NW"
    :border "single"
    :relative "win"
  })
  ;; insert into win-stack
  (insert-stack (vim.api.nvim_get_current_win))
  (update-stack)
  ;; set options
  (vim.api.nvim_buf_set_option buffer :ft filetype)
  (vim.api.nvim_win_set_option 0      :winhl (.. "Normal:" highlight))
  ;; set keymaps
  (setup-mappings buffer)
  :return buffer))

(lambda win.set-float [lines filetype highlight]
  "defines a floating windows for string of 'lines'."
  (let [lines  (vim.split lines "\n")
        nlines (lineheight lines)
        buffer (win.create-float nlines filetype highlight)]
    (vim.api.nvim_buf_set_lines buffer 0 -1 true lines)
    :return true))

; EXAMPLES
; (win.create-float 2    :fennel :Normal)
; (win.create-float 3    :fennel :Normal)
; (win.set-float    :lol :fennel :Normal)


:return win
