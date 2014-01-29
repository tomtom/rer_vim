" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    63

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


if !empty(g:rer#mapleader)

    exec 'nnoremap <buffer> '. g:rer#mapleader .'rs :call rer#SourceBuffer(bufnr("%"))<cr>'

    exec 'nnoremap <buffer> '. g:rer#mapleader .'rK :call rer#Keyword("", "text")<cr>'

    exec 'nnoremap <buffer> '. g:rer#mapleader .'rd :call rer#Debug(expand("<cword>"))<cr>'
    exec 'vnoremap <buffer> '. g:rer#mapleader .'rd ""p:call rer#Debug(@")<cr>'

    exec 'nnoremap <buffer> '. g:rer#mapleader .'rf :call rer#FunctionArgs(expand("<cword>"))<cr>'
    exec 'vnoremap <buffer> '. g:rer#mapleader .'rf :call rer#FunctionArgs(join(rescreen#GetSelection("v"), " "))<cr>'

    exec 'nnoremap <buffer> '. g:rer#mapleader .'rm :call rescreen#Send("summary(<c-r><c-w>)", "rer")<cr>'
    exec 'nnoremap <buffer> '. g:rer#mapleader .'re :call rescreen#Send("example(<c-r><c-w>)", "rer")<cr>'
    exec 'nnoremap <buffer> '. g:rer#mapleader .'rb :call rer#SetBreakpoint(expand("%:p"), [line(".")])<cr>'
    exec 'nnoremap <buffer> '. g:rer#mapleader .'rd :call rer#SendR(expand("<cword>"))<cr>'
    exec 'nnoremap <buffer> '. g:rer#mapleader .'rcd :Rcd<cr>'

endif


if !empty(g:rer#map_eval_and_print)

    exec 'nnoremap <buffer>' g:rer#map_eval_and_print ':call rescreen#Send(getline("."), "rer", "p")<cr>+'
    exec 'inoremap <buffer>' g:rer#map_eval_and_print '<c-\><c-o>:call rescreen#Send(getline("."), "rer", "p")<cr>'
    exec 'xnoremap <buffer>' g:rer#map_eval_and_print ':call rescreen#Send(rescreen#GetSelection("v"), "rer", "p")<cr>'

endif


" Set R's working directory to the current buffer's directory.
command! -bang -buffer Rcd call rer#Cd()

" Source the current buffer in R.
command! -bang -buffer Rsource call rer#SourceBuffer(bufnr("%"))

" :display: :Rdebug [FUNCTION]
" Debug or undebug FUNCTION.
command! -bang -buffer -nargs=? Rdebug call rer#Debug(<q-args>)

" :display: RBreakpoint [FILENAME]
" List and remove breakpoints.
" If FILENAME is "%", the current buffer is used.
command! -bang -buffer -nargs=? RBreakpoint call rer#SetBreakpoint(<q-args>, [])

command! -bang -buffer RResetBreakpoints call rer#ResetBreakpoints()


let b:did_rer = 1
