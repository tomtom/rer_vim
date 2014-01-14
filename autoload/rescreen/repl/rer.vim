" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    82


let s:sfile = rer#Filename(expand('<sfile>:p:h'))


let s:prototype = {} "{{{2


function! s:prototype.ExitRepl() dict "{{{3
    call self.rescreen.EvaluateInSession('rerQuit()', '')
    sleep 1
endf


function! s:prototype.WrapResultPrinter(input) dict "{{{3
    let input = a:input
    call add(input, 'print(.Last.value)')
    return input
endf


function! s:prototype.WrapResultWriter(input, xtempfile) dict "{{{3
    let input = a:input
    call add(input,
                \ printf('writeLines(as.character(.Last.value), con = "%s")',
                \     escape(a:xtempfile, '"\'))
                \ )
    return input
endf


function! rescreen#repl#rer#Extend(dict) "{{{3
    if g:rer#save == 2
        let save = 1
    elseif g:rer#save == 1
        let save = filereadable(expand('%:p:h') .'/.Rdata')
    else
        let save = 0
    endif
    let a:dict.shell = g:rer#shell
    let a:dict.repl_convert_path = g:rer#convert_path
    let a:dict.repl = join([g:rer#repl, save ? ' --save' : ' --no-save', g:rer#repl_args])
    let a:dict.repl_handler = copy(s:prototype)
    let cd = rer#R_setwd(a:dict)
    " TLogVAR cd
    let r_lib = a:dict.Filename(simplify(s:sfile .'/../../rer/rer_vim.R'))
    " TLogVAR r_lib
    let initial_lines = [
                \ cd,
                \ printf('rer.options <- %s', rer#RDict(g:rer#options)),
                \ printf('source(%s)', rer#ArgumentString(r_lib)),
                \ ]
    if !empty(g:rer#r_options)
        call insert(initial_lines, printf('options(%s)', g:rer#r_options))
    endif
    let a:dict.repl_handler.initial_lines = initial_lines
    call rescreen#ChangeMapLeader(a:dict, g:rer#mapleader)
    let b:rer = a:dict
endf

