" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    112

if exists('b:did_rer')
    finish
endif


Rescreen -default rer


if empty(&omnifunc)
    let b:rescreen_completions='rer#Completions'
    setlocal omnifunc=rescreen#Complete
endif


" See |rer#Keyword()| and |K|.
nnoremap <buffer> K :call rer#Keyword()<cr>

" Inspect an R object -- see |rer#Inspect()|.
nnoremap <buffer> <LocalLeader>K :call rer#Inspect()<cr>


if exists(':popup')
    amenu PopUp.-RSep-              :
    amenu PopUp.Source\ R\ file     :call rer#SourceBuffer(bufnr("%"))<cr>
    amenu PopUp.Cd\ to\ bufferdir   :Rcd<cr>
    amenu PopUp.Help\ on\ word      :call rer#Keyword()<cr>
    amenu PopUp.Function\ Defintion :call rer#FunctionArgs(expand("<cword>"))<cr>
    amenu PopUp.Function\ Examples  :call rescreen#Send("example(<c-r><c-w>)", "rer")<cr>
    amenu PopUp.Variable\ Summary   :call rescreen#Send("summary(<c-r><c-w>)", "rer")<cr>
    amenu PopUp.Call\ R\ with\ word :call rer#SendR(expand("<cword>"))<cr>
    amenu PopUp.Debug\ function     :call rer#Debug(expand("<cword>"))<cr>
    amenu PopUp.Set\ Breakpoint     :call rer#SetBreakpoint(expand("%: p"), [line(".")])<cr>
    amenu PopUp.Call\ Favourite     :call rer#Quicklist(expand("<cword>"))<cr>
    amenu PopUp.Rer\ Maps           :Rerhelp<cr>
endif


if !empty(g:rer#mapleader)

    exec 'nnoremap <buffer> '. g:rer#mapleader .'rs :call rer#SourceBuffer(bufnr("%"))<cr>'

    exec 'nnoremap <buffer> '. g:rer#mapleader .'rK :call rer#Keyword("", "text")<cr>'

    exec 'nnoremap <buffer> '. g:rer#mapleader .'rd :call rer#Debug(expand("<cword>"))<cr>'
    exec 'vnoremap <buffer> '. g:rer#mapleader .'rd ""p:call rer#Debug(@")<cr>'

    if exists('g:loaded_tinykeymap')
        exec 'nnoremap <buffer> '. g:rer#mapleader .'rD :Tinykeymap rdebug<cr>'
    endif

    exec 'nnoremap <buffer> '. g:rer#mapleader .'rf :call rer#FunctionArgs(expand("<cword>"))<cr>'
    exec 'vnoremap <buffer> '. g:rer#mapleader .'rf :call rer#FunctionArgs(join(rescreen#GetSelection("v"), " "))<cr>'

    exec 'nnoremap <buffer> '. g:rer#mapleader .'rb :call rer#SetBreakpoint(expand("%:p"), [line(".")])<cr>'
    exec 'nnoremap <buffer> '. g:rer#mapleader .'rcd :Rcd<cr>'

    exec 'nnoremap <buffer> '. g:rer#mapleader .'rr :call rer#Quicklist(expand("<cword>"))<cr>'
    exec 'vnoremap <buffer> '. g:rer#mapleader .'rr :call rer#Quicklist(join(rescreen#GetSelection("v"), " "))<cr>'

endif


if !empty(g:rer#map_eval_and_print)

    exec 'nnoremap <buffer>' g:rer#map_eval_and_print ':call rescreen#Send(getline("."), "rer", "p")<cr>+'
    exec 'inoremap <buffer>' g:rer#map_eval_and_print '<c-\><c-o>:call rescreen#Send(getline("."), "rer", "p")<cr>'
    exec 'vnoremap <buffer>' g:rer#map_eval_and_print ':call rescreen#Send(rescreen#GetSelection("v"), "rer", "p")<cr>'

endif

command! -buffer Rerhelp exec 'map <buffer>' g:rer#mapleader

" Set R's working directory to the current buffer's directory.
command! -bang -buffer Rcd call rer#Cd()

" Source the current buffer in R.
command! -bang -buffer Rsource call rer#SourceBuffer(bufnr("%"))

" :display: :Rdebug [FUNCTION]
" Debug or undebug FUNCTION.
command! -bang -buffer -nargs=? Rdebug call rer#Debug(<q-args>)

if exists('g:loaded_tinykeymap')
    command! -bang -buffer -nargs=? Rdebugger Tinykeymap rdebug
endif

" :display: RBreakpoint [FILENAME]
" List and remove breakpoints.
" If FILENAME is "%", the current buffer is used.
command! -bang -buffer -nargs=? RBreakpoint call rer#SetBreakpoint(<q-args>, [])

command! -bang -buffer RResetBreakpoints call rer#ResetBreakpoints()

command! -buffer Rtags call rer#Tags()


for s:name in g:rer#support_maps
    if s:name ==# 'statet'
        nnoremap <buffer> <c-r><c-r> :call rescreen#Send(getline("."), "rer")<cr>
        imap <buffer> <c-r><c-r> <c-\><c-o><c-r><c-r>
        xnoremap <buffer> <c-r><c-r> :call rescreen#Send(join(rescreen#GetSelection("v"), "\n"), "rer")<cr>
        smap <buffer> <c-r><c-r> <c-o><c-r><c-r>
        nnoremap <buffer> <c-r><c-s> :Rsource<cr>
        nmap <buffer> <c-r><c-e> vip<c-r><c-r>
        map <buffer> <c-r>1 K
    endif
endfor
unlet! s:name


let b:did_rer = 1
