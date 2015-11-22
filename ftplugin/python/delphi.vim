if !exists("g:delphi_run")
    let g:delphi_run = "delphi"
endif

function! DelphiRun()
    "yank content between #@s and #@e
    execute "normal! /#@s\<cr>j0v/#@e\<cr>k$y"
    "create or open helper file
    silent :edit __delphi_snippet__
    "delete existing content
    normal! ggdG 
    "paste 
    execute "normal! P\<cr>" 
    "write file
    :w
    "return to original buffer
    silent :bd
    ":call CloseBufIfOpen("__delphi_snippet__")
    "execute helper file
    let python_output = system("rm __delphi_show__; python __delphi_snippet__ 2>&1 1>__delphi_show__")
    "if __delphi_show__ is opened currently, close it
    :call CloseBufIfOpen("__delphi_show__")
    "vertical split window
    silent rightbelow vsplit __delphi_show__
    "move cursor back to original buffer
    execute "normal! \<C-w>\<C-h>"

endfunction


"if __delpho_show__ is currently in the buffer
"assume it is in the right window
"close it then
function CloseBufIfOpen(name)
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

"echos current selected range
nnoremap <buffer> <leader>r :call DelphiRun()<cr>
