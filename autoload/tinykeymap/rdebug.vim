" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    11


function! tinykeymap#rdebug#Send(string) "{{{3
    call rer#Send(a:string)
endf


function! tinykeymap#rdebug#Input(string) "{{{3
    call inputsave()
    let string = input("R: ", a:string)
    call inputrestore()
    call rer#Send(string)
endf


function! tinykeymap#rdebug#UnkownKey(chars, count) "{{{3
    call tinykeymap#rdebug#Input(join(a:chars, ''))
    return 1
endf

