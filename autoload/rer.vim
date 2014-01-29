" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    239


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


if !exists('g:rer#highlight_breakpoint')
    " Highlight group for breakpoint
    let g:rer#highlight_breakpoint = 'SpellBad'   "{{{2
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
    " Example:>
    "
    "   let g:rer#r_options = 'warn = 1'.(has('gui_running') ? ', help_type = "html"' : '')
    let g:rer#r_options = ''   "{{{2
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


function! s:IsKeyword(word) "{{{3
    return a:word =~ '^\(if\|else\|repeat\|while\|function\|for\|in\|next\|break\|[[:punct:]]\)$'
endf


" :display: rer#Keyword(?word = "", ?help_type = "")
function! rer#Keyword(...) "{{{3
    let word = a:0 >= 1 && !empty(a:1) ? a:1 : expand("<cword>")
    let help_type = a:0 >= 2 ? a:2 : ''
    " TLogVAR a:000, word, help_type
    let etc = ''
    if !empty(help_type)
        let etc .= 'help_type = '. string(help_type)
    endif
    " TLogVAR word
    if s:IsKeyword(word)
        let name = string(word)
        let namestring = '""'
    else
        let name = word
        let namestring = string(word)
    endif
    if !empty(etc)
        let etc = ', '. etc
    endif
    let r = printf('rerKeyword(%s, %s%s)', name, namestring, etc)
    call rescreen#Send(r, 'rer')
endf


" Inspect the word under the cursor.
function! rer#Inspect(...) "{{{3
    let word = a:0 >= 1 && !empty(a:1) ? a:1 : expand("<cword>")
    " TLogVAR word
    let r = printf('rerInspect(%s)', word)
    call rescreen#Send(r, 'rer')
endf


function! s:GetFunctionOfWord(base, noKeywords) "{{{3
    let line = getline('.')[0 : virtcol('.') - 1]
    " let rx = '\V\(\k\+\)\ze\s\*(\[^)]\{-}\$'
    let rx = '\V\(\[a-zA-Z0-9._]\+\)\ze\s\*(\[^()]\*\$'
    let fn = matchstr(line, rx)
    " TLogVAR a:base, line, fn
    if a:noKeywords && !empty(fn) && s:IsKeyword(fn)
        let fn = ''
    endif
    return fn
endf


function! rer#CommandComplete(ArgLead, CmdLine, CursorPos) "{{{3
    return rer#Completions(a:ArgLead)
endf


" Omnicompletion for R.
" If the base pattern contains no period ".", matches with periods are 
" removed from the list of possible completions.
" See also 'omnifunc'.
function! rer#Completions(base, ...) "{{{3
    let use_empty_base = a:0 >= 1 ? a:1 : exists('w:tskeleton_hypercomplete')
    let rescreen = rescreen#Init(1, {'repltype': 'rer'})
    let clist = []
    let fn = s:GetFunctionOfWord(a:base, 1)
    if !empty(fn)
        if fn =~ '^\(options\)$'
            let fn = string(fn)
        endif
        let r = printf('rerFormals(%s, names.only = TRUE)', fn)
        let args = rescreen.EvaluateInSession(r, 'r')
        if args !=# 'NULL'
            let argslist = split(args, '\n')
            let argslist = map(argslist, 'v:val == "..." ? v:val : v:val ." = "')
            " TLogVAR args, argslist
            let clist += argslist
        endif
    endif
    if !empty(a:base) || use_empty_base
        let r = printf('rerComplete(%s, %s)',
                    \ rer#ArgumentString('^'. escape(a:base, '^$.*\[]~"')),
                    \ rer#ArgumentString('')
                    \ )
        let completions = rescreen.EvaluateInSession(r, 'r')
        " TLogVAR completions
        if completions !=# 'NULL'
            let clist += sort(split(completions, '\n'))
        endif
    endif
    return clist
endf


function! rer#FunctionArgs(word) "{{{3
    if !empty(a:word) && !s:IsKeyword(a:word)
        let fn = s:GetFunctionOfWord(a:word, 1)
        " TLogVAR fn
        if empty(fn)
            let fn = "NULL"
        endif
        let rescreen = rescreen#Init(1, {'repltype': 'rer'})
        let r = printf('rerFunctionArgs(%s, %s)', a:word, fn)
        " TLogVAR r
        let val = rescreen.EvaluateInSession(r, 'r')
        if !empty(val) && val != "NULL"
            echohl Type
            echo val
            echohl NONE
        endif
    endif
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


" :display: rer#SourceBuffer(bufnr, ?nativeSource = FALSE)
function! rer#SourceBuffer(bufnr, ...) "{{{3
    if &modified
        echohl WarningMsg
        echom "Buffer was modified. Won't source a modified buffer."
        echohl NONE
    elseif empty(bufname(a:bufnr)) || getbufvar(a:bufnr, '&ft') != 'r' || getbufvar(a:bufnr, '&buftype') =~ 'nofile'
        echohl WarningMsg
        echom "Cannot source this buffer in R!"
        echohl NONE
    else
        let filename = bufname(a:bufnr)
        let filename = fnamemodify(filename, ':p')
        let filename = rer#Filename(filename, b:rer)
        let source = a:0 >= 1 && a:1 ? 'source' : 'rerSource'
        let r = printf('%s(%s)', source, rer#ArgumentString(filename))
        call rescreen#Send(r, 'rer')
    endif
endf


let s:debugged = []
let s:breakpoints = {}

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
        exec 'hi def link ReRBreakpoint' g:rer#highlight_breakpoint
        let s:hl_init = 1
    endif
    if !empty(s:debugged)
        let debugged = map(copy(s:debugged), 'escape(v:val, ''\'')')
        " TLogVAR debugged
        exec 'syntax match ReRDebug /\V\<\('. join(debugged, '\|') .'\)\>/'
    endif
    for lnum in get(s:breakpoints, expand('%:p:t'), {'lnums': []}).lnums
        exec 'syntax match ReRBreakpoint /^\%'. lnum .'l.*$/'
    endfor
endf


if exists('g:loaded_quickfixsigns')
    if !has_key(g:quickfixsigns#breakpoints#filetypes, 'r')
        let g:quickfixsigns#breakpoints#filetypes['r'] = 'rer#GetBreakpointsAsQFL'
    endif
endif


function! rer#GetBreakpointsAsQFL() "{{{3
    let acc = []
    for [filename, bpdef]  in items(s:breakpoints)
        let bufnr = bpdef.bufnr
        for lnum in bpdef.lnums
            let item = {
                        \ 'bufnr': bufnr,
                        \ 'lnum': lnum,
                        \ 'text': 'Breakpoint_'. lnum
                        \ }
            call add(acc, item)
        endfor
    endfor
    return acc
endf


" This function uses the basename of the filename argument. I.e. if you 
" have more than one file with a given basename is loaded in R, trouble 
" may follow.
function! rer#SetBreakpoint(filename, bplnums) "{{{3
    let filename = a:filename
    let bplnums = a:bplnums
    if empty(filename)
        if exists('g:loaded_tlib')
            let filename = tlib#input#List('s', 'Select filename:', keys(s:breakpoints))
        endif
    elseif filename == '%'
        let filename = expand("%:p")
    endif
    if empty(filename)
        throw "ReR: SetBreakpoint: Empty filename"
    endif
    " let filename = fnamemodify(filename, ':t')
    let filename = fnamemodify(filename, ':p')
    if !has_key(s:breakpoints, filename)
        let s:breakpoints[filename] = {'bufnr': bufnr(filename), 'lnums': []}
    endif
    let lnums = s:breakpoints[filename].lnums
    if empty(bplnums)
        if exists('g:loaded_tlib')
            let bplnums = tlib#input#List('m', 'Select breakpoint:', lnums)
            let bplnums = map(bplnums, 'str2nr(v:val, 10)')
        endif
    endif
    let view = winsaveview()
    try
        let bufnr = bufnr(filename)
        if bufnr != bufnr('%s')
            exec 'buffer' bufnr
        endif
        for lnum in bplnums
            let lnumi = index(lnums, lnum)
            if lnumi == -1
                let lnum = nextnonblank(lnum)
                call add(lnums, lnum)
                echom "Add breakpoint"
                let clear = "FALSE"
            else
                call remove(lnums, lnumi)
                echom "Remove breakpoint"
                let clear = "TRUE"
            endif
            let rescreen = rescreen#Init(1, {'repltype': 'rer'})
            let r = printf('rerSetBreakpoint(%s, %s, clear = %s, nameonly = FALSE)',
                        \ string(escape(filename, '\"')), lnum, clear)
            call rescreen#Send(r, 'rer')
            let s:breakpoints[filename].lnums = lnums
        endfor
        call s:HighlightDebug()
    finally
        call winrestview(view)
    endtry
endf


function! rer#ResetBreakpoints() "{{{3
    for [filename, lnums] in items(s:breakpoints)
        call rer#SetBreakpoint(filename, lnums)
    endfor
    let s:breakpoints = {}
endf


function! rer#SendR(word) "{{{3
    let word = a:word
    if !empty(word)
        let word = '('. word .')'
        let word .= repeat("\<Left>", len(word))
    endif
    call inputsave()
    let r = input('R: ', word, 'customlist,rer#CommandComplete')
    call inputrestore()
    if !empty(r)
        call rescreen#Send(r, 'rer')
    endif
endf

