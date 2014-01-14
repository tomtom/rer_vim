" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    31

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

    exec 'nnoremap <buffer> '. g:rer#mapleader .'d :call rer#Debug(expand("<cword>"))<cr>'
    exec 'vnoremap <buffer> '. g:rer#mapleader .'d ""p:call rer#Debug(@")<cr>'

    exec 'nnoremap <buffer> '. g:rer#mapleader .'s :call rer#SourceBuffer(bufnr("%"))<cr>'

endif


if !empty(g:rer#map_eval_and_print)

    exec 'nnoremap <buffer>' g:rer#map_eval_and_print ':call rescreen#Send(getline("."), "rer", "p")<cr>'
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


let b:did_rer = 1
