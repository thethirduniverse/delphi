if !exists("g:delphi_run")
    let g:delphi_run = "delphi"
    let s:delphi_snippet = "/tmp/__delphi_snippet__"
    let s:delphi_show = "/tmp/__delphi_show__"
    "toggle function
    nnoremap <buffer> <leader>d :call DelphiToggle()<cr>
else
    finish
endif

function! DelphiToggle()
    if (s:delphi_enabled)
        :call s:DelphiDisable()
    else
        :call s:DelphiEnable()
    endif
endfunction

function! s:DelphiRun()
    "abandons if file is not dirty and not first time running
    if (!s:delphi_file_dirty)
        return
    endif
    "save cursor and window info
    let l:winview = winsaveview()
    "yank all content to register a
    :call s:YankAll()
    "create helper file
    exec 'vsp'. s:delphi_snippet
    "delete existing content
    "restore unnamed register
    let temp = @"
    normal! ggdG 
    let @" = temp
    
    "paste to helper file
    silent execute "normal! \"aP\<cr>" 
    "write file
    silent :w
    "close this new split
    :bd
    "execute helper file
    :call s:DelphiTimedExecution() 
    "restore window, cursor, etc.
    :call winrestview(l:winview)
    "file is no longer dirty
    let s:delphi_file_dirty=0
endfunction

function! s:YankAll()
    "for some reason :1,2y a will save the content to both a and "
    "so we need to manually restore the content of "
    let temp = @"
    let lastLine = line('$')
    execute ":1,".lastLine."y a"
    let @" = temp
endfunction

"this function is not local because
"it will be called from python as a
"callback
function! DisplayShowWindow()
    :redraw!
    "if __delphi_show__ is opened currently, close it
    :call s:CloseBufIfOpen(s:delphi_show)
    "vertical split window
    exec 'silent rightbelow vsplit '. s:delphi_show
    "move cursor back to original buffer
    silent execute "normal! \<C-w>\<C-h>"
    "somehow the above code will not make 
    "the change to show automatically
    "so redraw it to show
    :redraw!
endfunction

"close the buffer with given name if it is opened
"otherwise do nothing
function! s:CloseBufIfOpen(name)
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

function! s:DelphiEnable()
    let availability = s:DelphiCheckAvaiability()
    if availability != 1
        echom 'Delphi not available. Reason: ' . availability
        return
    endif
    
    nnoremap <buffer> <leader>r :call <SID>DelphiRun()<cr>
    set eventignore=""
    autocmd BufEnter *.py set updatetime=300
    autocmd CursorHold *.py :call <SID>DelphiRun()
    autocmd CursorHoldI *.py :call <SID>DelphiRun()
    autocmd TextChanged *py :call <SID>DelphiMarkDirty()
    autocmd TextChangedI *py :call <SID>DelphiMarkDirty()
    let g:delphi_exec_limit=1000
    let s:delphi_file_dirty=1
    let s:delphi_enabled=1
    :call s:DelphiLoadPython()
    echom "Delphi is enabled."
endfunction


function! s:DelphiDisable()
    :call s:CloseBufIfOpen(s:delphi_show)
    nunmap <buffer> <leader>r
    set eventignore=BufEnter,CursorHold,CursorHoldI,TextChanged,TextChangedI
    unlet s:delphi_file_dirty
    unlet g:delphi_exec_limit
    let s:delphi_enabled=0
    echom "Delphi is disabled."
endfunction

function! s:DelphiMarkDirty()
    let s:delphi_file_dirty=1
endfunction

function! s:DelphiSetExecLimit(limit)
    let g:delphi_exec_limit = a:limit
endfunction

"execute the command asynchrounously
"when execution finishes or timeout
"it will invoke corresponding command to update
"the result
function! s:DelphiTimedExecution()
    py << EOF
Process(target=delphi_exec,args=()).start()
EOF
endfunction

function! s:DelphiCheckAvaiability()
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

function! s:DelphiLoadPython()
    if(exists("g:delphi_python_loaded"))
        return
    endif
    py << EOF
from multiprocessing import Process
import time, os, signal, sys, vim

delphi_servername = vim.eval("v:servername")
delphi_snippet = vim.eval("s:delphi_snippet")
delphi_show = vim.eval("s:delphi_show")
delphi_exec_limit = int(vim.eval("g:delphi_exec_limit"))
delphi_outfile = None

def terminate(signum, frame):
    global delphi_outfile
    global delphi_servername
    if delphi_outfile:
        delphi_outfile.close()
        delphi_outfile = None
    #This will not work because it is not thread safe    
    #vim.command(":call DisplayShowWindow()")
    os.system("vim --servername \"" + delphi_servername + "\" --remote-expr \"DisplayShowWindow()\" > /dev/null ")
    os._exit(0)

def delphi_exec():
    global delphi_outfile
    global delphi_exec_limit
    global delphi_snippet
    global delphi_show
    #redirect output
    signal.signal(signal.SIGALRM, terminate)
    signal.alarm(delphi_exec_limit / 1000)
    delphi_outfile = open(delphi_show,"w+")
    sys.stdout = delphi_outfile
    sys.stderr = delphi_outfile
    #evalutate the command in current thread
    cmd = open(delphi_snippet,"r").read()
    try:
        exec(cmd)
    except Exception as e:
        print e
    terminate(signal.SIGALRM, None)
EOF
    let g:delphi_python_loaded=1
endfunction

"plugins are load after vimrc
if exists("g:use_delphi")
    call s:DelphiEnable()
endif
