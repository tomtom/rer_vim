" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    48


function! s:RFilename(filename, ...) "{{{3
    let filename = substitute(a:filename, '\\', '/', 'g')
    if a:0 >= 1
        let filename = a:1.Filename(filename)
    endif
    return filename
endf


let s:sfile = s:RFilename(expand('<sfile>:p:h'))


let s:prototype = {} "{{{2


function! s:prototype.ExitRepl() dict "{{{3
    call self.rescreen.EvaluateInSession('rer.quit()', '')
    sleep 1
endf


function! s:prototype.WrapResultPrinter(input) dict "{{{3
    <+BODY+>
endf


function! s:prototype.WrapResultWriter(input, xtempfile) dict "{{{3
    <+BODY+>
endf


function! s:SourceBuffer(bufnr) "{{{3
    if !&modified && !empty(bufname(a:bufnr)) && getbufvar(a:bufnr, '&ft') == 'r' && getbufvar(a:bufnr, '&buftype') !~ 'nofile'
        let filename = s:RFilename(fnamemodify(bufname(a:bufnr), ':p'), b:rer)
        let r = printf('source(%s)', rer#ArgumentString(filename))
        call rescreen#Send(r, 'r')
    endif
endf


function! rescreen#repl#r#Extend(dict) "{{{3
    let a:dict.repl_handler = copy(s:prototype)
    let cd = rer#R_setwd(a:dict)
    TLogVAR cd
    let r_lib = a:dict.Filename(s:sfile .'/../../rer/rer_vim.R')
    TLogVAR r_lib
    let a:dict.repl_handler.inital_lines = [
                \ cd,
                \ printf('source(%s)', rer#ArgumentString(r_lib))
                \ ]
    let b:rer = a:dict
    " <+TODO+> setup buffer local maps
    " exec 'nnoremap <buffer> '. g:rcom_mapop .'p :let b:rcom_mode = b:rcom_mode == "p" ? "" : "p" \| redraw \| echom "RCom: Printing turned ". (b:rcom_mode == "p" ? "on" : "off")<cr>'
    " exec 'nnoremap <buffer> '. g:rcom_mapop .'d :call rcom#Debug(expand("<cword>"))<cr>'
    " exec 'vnoremap <buffer> '. g:rcom_mapop .'d ""p:call rcom#Debug(@")<cr>'
    " exec 'nnoremap <buffer> '. g:rcom_mapop .'l :call rcom#LogBuffer()<cr>'
    " exec 'nnoremap <buffer> '. g:rcom_mapop .'t :call rcom#TranscriptBuffer()<cr>'
    " exec 'nnoremap <buffer> '. g:rcom_mapop .'s :call rcom#SourceBuffer(bufnr("%"))<cr>'
endf

