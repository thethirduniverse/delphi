if !exists("g:delphi_range_selection")
    let g:delphi_range_selection = "delphi"
endif

function! DelphiShowSelectedRange()
    echo "Function called!"
endfunction


"echos current selected range
nnoremap <buffer> <leader>r :call DelphiShowSelectedRange()<cr>
