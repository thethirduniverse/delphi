if !exists("g:delphi_run")
    let g:delphi_run = "delphi"
else
    finish
endif

function! DelphiRun()
    "abandons if file is not dirty and not first time running
    if (&modified == 0 && !g:delphi_first_run)
        return
    endif
    "from now on the only way to re-execute is by modifying file
    let g:delphi_first_run=0
    "save cursor
    normal ma
    "yank content between #@s and #@e
    if( YankSelectedRange() < 0 )
        echom "delphi failed to extract correct range for execution"
    else
        "create helper file
        "silent :edit __delphi_snippet__
        vsp __delphi_snippet__
        "delete existing content
        normal! ggdG 
        "paste 
        silent execute "normal! \"aP\<cr>" 
        "write file
        silent :w
        "close this new split
        :bd
        "execute helper file
        "not working, will always show current working directory
        "let s:directory = expand('<sfile>:h')
        :call bg#Run("~/.vim/bundle/delphi/ftplugin/python/delphi_timed_execution.o __delphi_snippet__ __delphi_show__ ".g:delphi_exec_limit, 1, funcref#Function("DisplayShowWindow"))
    endif
    
    "restore window, cursor, etc.
    normal `a
endfunction

"yanks the content between #@s and #@e, on success return 0, on failure return
"-1
function! YankSelectedRange()
    let start = search("#@s")
    let end = search("#@e")
    if (start==0 || end==0)
        return -1
    endif
    if (start+1 > end-1)
        return -1
    endif
    "yank the file starting from start+1 to end-1
    execute ":".(start+1).",".(end-1)."y a"
    return 0
endfunction

function! DisplayShowWindow(status, file)
    "if __delphi_show__ is opened currently, close it
    :call CloseBufIfOpen("__delphi_show__")
    "vertical split window
    rightbelow vsplit __delphi_show__
    "move cursor back to original buffer
    silent execute "normal! \<C-w>\<C-h>"
endfunction

"if __delpho_show__ is currently in the buffer
"assume it is in the right window
"close it then
function! CloseBufIfOpen(name)
    "@http://vim.wikia.com/wiki/Easier_buffer_switching
    let bufcount = bufnr("$")
    let currbufnr = 1
    while currbufnr <= bufcount
        if(bufexists(currbufnr))
            let currbufname = bufname(currbufnr)
            if(match(currbufname, a:name) > -1)
                "echom "closing a delphi show window"
                silent execute ":" . currbufnr . "bw"
            endif
        endif
        let currbufnr = currbufnr + 1
    endwhile
endfunction

nnoremap <buffer> <leader>r :call DelphiRun()<cr>
autocmd BufEnter *.py set updatetime=300
autocmd CursorHold *.py :call DelphiRun()
autocmd CursorHoldI *.py :call DelphiRun()
let g:bg_use_python=1
let g:delphi_first_run=1
let g:delphi_exec_limit=1000
