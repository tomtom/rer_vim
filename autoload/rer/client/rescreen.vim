" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @Website:     https://github.com/tomtom
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Last Change: 2016-01-03
" @Revision:    23


let s:prototype = {}


function! s:prototype.Init() abort dict "{{{3
    let self.rescreen = rescreen#Init(1, {'repltype': 'rer'})
    return 1
endf


function! s:prototype.Send(code, ...) abort dict "{{{3
    return call(function('rescreen#Send'), [a:code, 'rer'] + a:000)
endf


function! s:prototype.Filename(filename) abort dict "{{{3
    return self.rescreen.Filename(a:filename)
endf


function! s:prototype.EvaluateInSession(input, mode) abort dict "{{{3
    return call(self.rescreen.EvaluateInSession, [a:input, a:mode], self.rescreen)
endf


function! rer#client#rescreen#GetPrototype() abort "{{{3
    return s:prototype
endf


function! rer#client#rescreen#Ftplugin() abort "{{{3
    Rescreen -default rer
    if empty(&omnifunc)
        let b:rescreen_completions='rer#Completions'
        setlocal omnifunc=rescreen#Complete
    endif
endf

