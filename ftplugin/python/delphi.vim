if !exists("g:delphi_run")
    let g:delphi_run = "delphi"
endif

function! DelphiRun()
    "yank content between #@s and #@e
    execute "normal! /#@s\<cr>j0v/#@e\<cr>k$y"
    "create helper file
    :edit __delphi_snippet__
    "delete existing content
    normal! ggdG 
    "paste 
    execute "normal! P\<cr>" 
    "write file
    silent :w
    "return to original buffer
    silent :bd
    "execute helper file
    let python_output = system("rm __delphi_show__; python __delphi_snippet__ 2>&1 1>__delphi_show__")
    
    "from @learnvimscript the hardway
    "vertical split window
    rightbelow vsplit __delphi_show__

endfunction

"echos current selected range
nnoremap <buffer> <leader>r :call DelphiRun()<cr>
