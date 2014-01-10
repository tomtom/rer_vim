" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    22

if exists('b:did_rer')
    finish
endif


Rescreen rer


if empty(&omnifunc)
    setlocal omnifunc=rer#Complete
endif


" See |rer#Keyword()| and |K|.
nnoremap <buffer> K :call rer#Keyword()<cr>

" Inspect an R object -- see |rer#Inspect()|.
nnoremap <buffer> <LocalLeader>K :call rer#Inspect()<cr>


exec 'nnoremap <buffer> '. g:rer#mapleader .'d :call rer#Debug(expand("<cword>"))<cr>'
exec 'vnoremap <buffer> '. g:rer#mapleader .'d ""p:call rer#Debug(@")<cr>'

exec 'nnoremap <buffer> '. g:rer#mapleader .'s :call rer#SourceBuffer(bufnr("%"))<cr>'


" Set R's working directory to the current buffer's directory.
command! -bang -buffer Rcd call rer#Cd()

" Source the current buffer in R.
command! -bang -buffer Rsource call rer#SourceBuffer(bufnr("%"))

" :display: :Rdebug [FUNCTION]
" Debug or undebug FUNCTION.
command! -bang -buffer -nargs=? Rdebug call rer#Debug(<q-args>)


let b:did_rer = 1
