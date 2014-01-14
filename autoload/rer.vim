" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    64


if !exists('g:rer#mapleader')
    let g:rer#mapleader = g:rescreen#mapleader   "{{{2
endif


if !exists('g:rer#map_eval_and_print')
    let g:rer#map_eval_and_print = '<c-s-cr>'   "{{{2
endif


if !exists('g:rer#convert_path')
    let g:rer#convert_path = ''   "{{{2
endif


if !exists('g:rer#highlight_debug')
    " Highlight group for debugged functions.
    let g:rer#highlight_debug = 'SpellRare'   "{{{2
endif


if !exists('g:rer#shell')
    let g:rer#shell = g:rescreen#shell   "{{{2
endif


if !exists('g:rer#repl')
    let g:rer#repl = executable('Rterm') ? 'Rterm --ess' : 'R'   "{{{2
endif


if !exists('g:rer#repl_args')
    let g:rer#repl_args = ''   "{{{2
endif

if !exists('g:rer#save')
    " Values:
    "     0 ... Don't save the image
    "     1 ... Save an image only if a file .Rdata exists
    "     2 ... Always save an image
    let g:rer#save = 1   "{{{2
endif


if !exists('g:rer#r_options')
    " Options (as string) passed to R.
    let g:rer#r_options = 'warn = 1'.(has('gui_running') ? ', help_type = "html"' : '')   "{{{2
endif


if !exists('g:rer#options')
    " Define a feature set.
    " :nodoc:
    let g:rer#options = {'features': ['history']}   "{{{2
endif


" :nodoc:
function! rer#Filename(filename, ...) "{{{3
    let filename = substitute(a:filename, '\\', '/', 'g')
    if a:0 >= 1
        let filename = a:1.Filename(filename)
    endif
    return filename
endf


" :nodoc:
function! rer#ArgumentString(text) "{{{3
    return string(escape(a:text, '\'))
endf


function! rer#Keyword(...) "{{{3
    let word = a:0 >= 1 && !empty(a:1) ? a:1 : expand("<cword>")
    " TLogVAR word
    if word =~ '^\(if\|else\|repeat\|while\|function\|for\|in\|next\|break\|[[:punct:]]\)$'
        let name = string(word)
        let namestring = '""'
    else
        let name = word
        let namestring = string(word)
    endif
    let r = printf('rerKeyword(%s, %s)', name, namestring)
    call rescreen#Send(r, 'rer')
endf


" Inspect the word under the cursor.
function! rer#Inspect(...) "{{{3
    let word = a:0 >= 1 && !empty(a:1) ? a:1 : expand("<cword>")
    " TLogVAR word
    let r = printf('rerInspect(%s)', word)
    call rescreen#Send(r, 'rer')
endf


" Omnicompletion for R.
" See also 'omnifunc'.
function! rer#Completions(base) "{{{3
    " TLogVAR a:findstart, a:base
    let rescreen = rescreen#Init(1, {'repltype': 'rer'})
    let r = printf('rerComplete(%s, %s)',
                \ rer#ArgumentString('^'. escape(a:base, '^$.*\[]~"')),
                \ rer#ArgumentString('')
                \ )
    let completions = rescreen.EvaluateInSession(r, 'r')
    " TLogVAR completions
    let clist = split(completions, '\n')
    " TLogVAR clist
    return clist
endf


function! rer#R_setwd(dict) "{{{3
    let wd = rer#Filename(expand('%:p:h'), a:dict)
    return printf('setwd(%s)', rer#ArgumentString(wd))
endf


function! rer#Cd() "{{{3
    let rescreen = rescreen#Init(1, {'repltype': 'rer'})
    let r = rer#R_setwd(rescreen)
    call rescreen.EvaluateInSession(r, '')
endf


function! rer#RVal(value) "{{{3
    if type(a:value) == 0        " Number
        return a:value
    elseif type(a:value) == 1    " String
        return string(a:value)
    elseif type(a:value) == 3    " List
        let rlist = map(copy(a:value), 'rer#RVal(v:val)')
        return printf('c(%s)', join(rlist, ', '))
    elseif type(a:value) == 4    " Dictionary
        return rer#RDict(a:value)
    elseif type(a:value) == 5    " Float
        return a:value
    else
        echoerr "ReR: Unsupport value: ". string(a:value)
    endif
endf


function! rer#RDict(dict) "{{{3
    let rv = []
    for [key, val] in items(a:dict)
        call add(rv, printf('%s = %s', string(key), rer#RVal(val)))
        unlet val
    endfor
    return printf('list(%s)', join(rv, ', '))
endf


function! rer#SourceBuffer(bufnr) "{{{3
    if !&modified && !empty(bufname(a:bufnr)) && getbufvar(a:bufnr, '&ft') == 'r' && getbufvar(a:bufnr, '&buftype') !~ 'nofile'
        let filename = rer#Filename(fnamemodify(bufname(a:bufnr), ':p'), b:rer)
        let r = printf('source(%s)', rer#ArgumentString(filename))
        call rescreen#Send(r, 'rer')
    endif
endf


let s:debugged = []

" Toggle the debug status of a function.
function! rer#Debug(fn) "{{{3
    " TLogVAR fn
    if index(s:debugged, a:fn) == -1
        let r = printf('debug(%s)', a:fn)
        call rescreen#Send(r, 'rer')
        call add(s:debugged, a:fn)
        echom "rer: Debug:" a:fn
        call s:HighlightDebug()
    else
        call rer#Undebug(a:fn)
    endif
endf


" Undebug a debugged function.
function! rer#Undebug(fn) "{{{3
    let fn = a:fn
    if empty(fn) && exists('g:loaded_tlib')
        let fn = tlib#input#List('s', 'Select function:', s:debugged)
    endif
    if !empty(fn)
        let i = index(s:debugged, fn)
        if i != -1
            call remove(s:debugged, i)
            echom "ReR: Undebug:" a:fn
        else
            echom "ReR: Not a debugged function?" fn
        endif
        let r = printf('undebug(%s)', fn)
        call rescreen#Send(r, 'rer')
        call s:HighlightDebug()
    endif
endf


let s:hl_init = 0

function! s:HighlightDebug() "{{{3
    if s:hl_init
        syntax clear ReRDebug
    else
        exec 'hi def link ReRDebug' g:rer#highlight_debug
        let s:hl_init = 1
    endif
    if !empty(s:debugged)
        let debugged = map(copy(s:debugged), 'escape(v:val, ''\'')')
        " TLogVAR debugged
        exec 'syntax match ReRDebug /\V\<\('. join(debugged, '\|') .'\)\>/'
    endif
endf

