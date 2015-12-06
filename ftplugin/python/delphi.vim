if !exists("g:delphi_run")
    let g:delphi_run = "delphi"
else
    finish
endif

function! DelphiRun()
    "abandons if file is not dirty and not first time running
    if (!g:delphi_file_dirty)
        return
    endif
    "save cursor and window info
    let l:winview = winsaveview()
    "yank all content to register a
    :call YankAll()
    "create helper file
    vsp __delphi_snippet__
    "delete existing content
    normal! ggdG 
    "paste to helper file
    silent execute "normal! \"aP\<cr>" 
    "write file
    silent :w
    "close this new split
    :bd
    "execute helper file
    :call DelphiTimedExecution() 
    "restore window, cursor, etc.
    :call winrestview(l:winview)
    "file is no longer dirty
    let g:delphi_file_dirty=0
endfunction

function! YankAll()
    let lastLine = line('$')
    execute ":1,".lastLine."y a"
endfunction


"yanks the content between #@s and #@e, on success return 0, on failure return
"-1
"function! YankSelectedRange()
"    let start = search("#@s")
"    let end = search("#@e")
"    if (start==0 || end==0)
"        return -1
"    endif
"    if (start+1 > end-1)
"        return -1
"    endif
"    "yank the file starting from start+1 to end-1
"    execute ":".(start+1).",".(end-1)."y a"
"    return 0
"endfunction

function! DisplayShowWindow()
    "if __delphi_show__ is opened currently, close it
    :call CloseBufIfOpen("__delphi_show__")
    "vertical split window
    rightbelow vsplit __delphi_show__
    "move cursor back to original buffer
    silent execute "normal! \<C-w>\<C-h>"
    "somehow the above code will not make 
    "the change to show automatically
    "so redraw it to show
    :redraw
endfunction

"close the buffer with given name if it is opened
"otherwise do nothing
function! CloseBufIfOpen(name)
    "@http://vim.wikia.com/wiki/Easier_buffer_switching
    let bufcount = bufnr("$")
    let currbufnr = 1
    while currbufnr <= bufcount
        if(bufexists(currbufnr))
            let currbufname = bufname(currbufnr)
            if(match(currbufname, a:name) > -1)
                silent execute ":" . currbufnr . "bw"
            endif
        endif
        let currbufnr = currbufnr + 1
    endwhile
endfunction

function! DelphiEnable()
    let availability = DelphiCheckAvaiability()
    if availability != 1
        echom 'Delphi not available. Reason: ' . availability
        return
    endif
    
    nnoremap <buffer> <leader>r :call DelphiRun()<cr>
    autocmd BufEnter *.py set updatetime=300
    autocmd CursorHold *.py :call DelphiRun()
    autocmd CursorHoldI *.py :call DelphiRun()
    autocmd TextChanged *py :call DelphiMarkDirty()
    autocmd TextChangedI *py :call DelphiMarkDirty()
    let g:delphi_exec_limit=1000
    let g:delphi_file_dirty=1
    
    py << EOF
from multiprocessing import Process
import time, os, signal, sys, vim

delphi_servername = vim.eval("v:servername")
delphi_exec_limit = int(vim.eval("g:delphi_exec_limit"))
delphi_outfile = None

def terminate(signum, frame):
    #vim.eval(":call displayshowwindow()")
    global delphi_outfile
    global delphi_servername
    if delphi_outfile:
        delphi_outfile.close()
        delphi_outfile = None
    os.system("vim --servername \"" + delphi_servername + "\" --remote-expr \"DisplayShowWindow()\" > /dev/null ")
    os._exit(0)

def delphi_exec():
    global delphi_outfile
    global delphi_exec_limit
    #redirect output
    signal.signal(signal.SIGALRM, terminate)
    signal.alarm(delphi_exec_limit / 1000)
    delphi_outfile = open("__delphi_show__","w+")
    sys.stdout = delphi_outfile
    sys.stderr = delphi_outfile
    #evalutate the command in current thread
    cmd = open("__delphi_snippet__","r").read()
    try:
        exec(cmd)
    except Exception as e:
        print e
    terminate(signal.SIGALRM, None)
EOF
endfunction


function! DelphiDisable()
    nunmap <buffer> <leader>r
    set eventignore=BufEnter,CursorHold,CursorHoldI,TextChanged,TextChangedI
    unlet g:delphi_file_dirty
    unlet g:delphi_exec_limit
endfunction

function! DelphiMarkDirty()
    let g:delphi_file_dirty=1
endfunction

function! DelphiSetExecLimit(limit)
    let g:delphi_exec_limit = a:limit
endfunction

"execute the command asynchrounously
"when execution finishes or timeout
"it will invoke corresponding command to update
"the result
function! DelphiTimedExecution()
    py << EOF
Process(target=delphi_exec,args=()).start()
EOF
endfunction

function! DelphiCheckAvaiability()
    let reason = ""
    if !has('clientserver')
        let reason = reason . "Clientserver is not supported|"
    endif
    if has('clientserver') && v:servername == ''
        let reason = reason . "Servername is empty|"
    endif
    if !has('python')
        let reason = reason . "Python not supported|"
    endif
    if reason == ""
        return 1
    else
        return reason
    endif
endfunction

"plugins are load after vimrc
if exists("g:use_delphi")
    call DelphiEnable()
endif
