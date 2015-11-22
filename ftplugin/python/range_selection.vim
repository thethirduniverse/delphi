if !exists("g:delphi_range_selection")
    let g:delphi_range_selection = "delphi"
endif

function! DelphiShowSelectedRange()
    execute "normal! /#@s\<cr>v/#@e\<cr>Wy"
    echom @@ 
endfunction


"echos current selected range
nnoremap <buffer> <leader>r :call DelphiShowSelectedRange()<cr>
