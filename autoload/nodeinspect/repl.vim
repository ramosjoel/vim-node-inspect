let s:repl_win = -1
let s:repl_buf = -1


" runs node-inspect according to session parameters
function nodeinspect#repl#StartNodeInspect(session, plugin_path)
	if s:repl_win == -1 || win_gotoid(s:repl_win) != 1
		echom "nodeinspect - can't start repl"
		return
	endif
	" prepare call command line
	let cmd_line = []
	call add(cmd_line, 'node')
	call add(cmd_line, a:plugin_path . "/node-inspect/cli.js")
	" start according to settings
	if a:session["request"] == "launch"
		" add the relevant launch params
		call add(cmd_line, a:session["script"])
		let cmd_line += a:session["args"]
	else
		" add the relevant connect params
		call add(cmd_line, a:session["address"].":".a:session["port"])
	endif
	" open terminal
	if has("nvim")
		let s:term_id = termopen(cmd_line, {'on_exit': 'OnNodeInspectExit'})
	else
		let s:term_id = term_start(cmd_line, {'curwin': 1, 'exit_cb': 'OnNodeInspectExit', 'term_finish': 'close', 'term_kill': 'kill'})
	endif
	sleep 200m
endfunction

" hide the repl window
function! s:hideReplWindow()
	if s:repl_win != -1 && win_gotoid(s:repl_win) == 1
		execute "hide"
	endif
endfunction

" create the repl win
function nodeinspect#repl#ShowReplWindow(startWin)
	if s:repl_buf == -1
		execute "bo ".winheight(a:startWin)/3."new"
		let s:repl_buf = bufnr('%')
		set nonu
	else
		execute "bo ".winheight(a:startWin)/3."new | buffer " . s:repl_buf
	endif
	let s:repl_win = win_getid()
endfunction


" kill the repl window
function nodeinspect#repl#KillReplWindow()
	if s:repl_win != -1 && win_gotoid(s:repl_win) == 1
		execute "bd!"
	endif
endfunction

" show/hide the window. note node-inspect might not be started yet
function nodeinspect#repl#ToggleReplWindow(startWin)
	if s:repl_buf == -1
		call nodeinspect#repl#ShowReplWindow(a:startWin)
	else
		let winIds = win_findbuf(s:repl_buf)
		if len(winIds) == 0
			call nodeinspect#repl#ShowReplWindow(a:startWin)
		else
			call s:hideReplWindow()
		endif
	endif
endfunction

