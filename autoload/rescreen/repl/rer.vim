" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    70


let s:sfile = rer#Filename(expand('<sfile>:p:h'))


let s:prototype = {} "{{{2


function! s:prototype.ExitRepl() dict "{{{3
    call self.rescreen.EvaluateInSession('rerQuit()', '')
    sleep 1
endf


function! s:prototype.WrapResultPrinter(input) dict "{{{3
    let input = a:input
    " <+BODY+>
    return input
endf


function! s:prototype.WrapResultWriter(input, xtempfile) dict "{{{3
    let input = a:input
    " <+BODY+>
    return input
endf


function! s:SourceBuffer(bufnr) "{{{3
    if !&modified && !empty(bufname(a:bufnr)) && getbufvar(a:bufnr, '&ft') == 'r' && getbufvar(a:bufnr, '&buftype') !~ 'nofile'
        let filename = rer#Filename(fnamemodify(bufname(a:bufnr), ':p'), b:rer)
        let r = printf('source(%s)', rer#ArgumentString(filename))
        call rescreen#Send(r, 'rer')
    endif
endf


function! rescreen#repl#rer#Extend(dict) "{{{3
    if g:rer#save == 2
        let save = 1
    elseif g:rer#save == 1
        let save = filereadable(expand('%:p:h') .'/.Rdata')
    else
        let save = 0
    endif
    let a:dict.repl = join([g:rer#repl, save ? ' --save' : ' --no-save', g:rer#repl_args])
    let a:dict.repl_handler = copy(s:prototype)
    let cd = rer#R_setwd(a:dict)
    " TLogVAR cd
    let r_lib = a:dict.Filename(simplify(s:sfile .'/../../rer/rer_vim.R'))
    " TLogVAR r_lib
    let a:dict.repl_handler.initial_lines = [
                \ cd,
                \ printf('rer.options <- %s', rer#RDict(g:rer#options)),
                \ printf('source(%s)', rer#ArgumentString(r_lib)),
                \ ]
    let b:rer = a:dict
endf

