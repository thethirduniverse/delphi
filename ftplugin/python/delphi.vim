if !exists("g:delphi_run")
    let g:delphi_run = "delphi"
endif

function! DelphiRun()
    "save file first, other wise it cannot open another buffer
    silent :w
    "yank content between #@s and #@e
    execute "normal! /#@s\<cr>j0v/#@e\<cr>k$h\"ay"
    "create helper file
    :edit __delphi_snippet__
    "delete existing content
    normal! ggdG 
    "paste 
    execute "normal! \"aP\<cr>" 
    "write file, return to original buffer
    silent :w
    "write file, return to original buffer
    silent :bd
endfunction

"echos current selected range
nnoremap <buffer> <leader>r :call DelphiRun()<cr>
