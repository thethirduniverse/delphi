if !exists("g:delphi_range_selection")
    let g:delphi_range_selection = "delphi"
endif

function! DelphiShowSelectedRange()
    execute "normal! /#@s\<cr>j0v/#@e\<cr>k$y"
    echom @@ 
endfunction


"echos current selected range
nnoremap <buffer> <leader>r :call DelphiShowSelectedRange()<cr>
