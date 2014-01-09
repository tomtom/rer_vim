" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    10

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


command! -bang -buffer Rcd call rer#Cd()


let b:did_rer = 1

