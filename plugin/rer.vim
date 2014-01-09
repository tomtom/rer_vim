" @Author:      Tom Link (micathom AT gmail com?subject=[vim])
" @Website:     http://www.vim.org/account/profile.php?user_id=4037
" @GIT:         http://github.com/tomtom/rer_vim
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    7
" GetLatestVimScripts: 0 0 :AutoInstall: rer.vim

if &cp || exists("loaded_rer")
    finish
endif
if !exists('g:loaded_rescreen') || g:loaded_rescreen < 1
    runtime plugin/rescreen.vim
    if !exists('g:loaded_rescreen') || g:loaded_rescreen < 1
        echoerr 'rescreen >= 0.1 is required'
        finish
    endif
endif
let loaded_rer = 1

let s:save_cpo = &cpo
set cpo&vim


" Initiate an R |rescreen| session for the current buffer and setup some 
" custom maps.
command! -bang -nargs=* Rer Rescreen rer


let &cpo = s:save_cpo
unlet s:save_cpo
