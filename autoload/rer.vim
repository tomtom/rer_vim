" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    325


if !exists('g:loaded_tlib') || g:loaded_tlib < 119
    runtime plugin/tlib.vim
    if !exists('g:loaded_tlib') || g:loaded_tlib < 119
        echoerr 'tlib >= 1.19 is required'
        finish
    endif
endif


if !exists('g:rer#debug')
    let g:rer#debug = 0
endif


if !exists('g:rer#quicklist')
    let g:rer#quicklist = ['??"%s"', 'str(%s)', 'summary(%s)', 'head(%s)', 'edit(%s)', 'fix(%s)', 'debugger()', 'traceback()', 'install.packages("%s")', 'update.packages()', 'example("%s")', 'graphics.off()']   "{{{2
    if exists('g:rer_quicklist_etc')
        let g:rer#quicklist += g:rer_quicklist_etc
    endif
endif


if !exists('g:rer#client_name')
    let g:rer#client_name = 'rescreen'   "{{{2
endif


if !exists('g:rer#mapleader')
    let g:rer#mapleader = '<LocalLeader>r'   "{{{2
endif


if !exists('g:rer#support_maps')
    " A list of map names. Enable maps similar to:
    " - statet
    let g:rer#support_maps = ['statet']   "{{{2
endif


if !exists('g:rer#map_eval')
    let g:rer#map_eval = '<c-cr>'   "{{{2
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


if !exists('g:rer#handlers')
    let g:rer#handlers = [{'key': 5, 'agent': 'rer#EditItem', 'key_name': '<c-e>', 'help': 'Edit item'}]   "{{{2
endif


if !exists('g:rer#tags_patterns')
    let g:rer#tags_patterns = '*.R */*.R'   "{{{2
    if has('fname_case')
        let g:rer#tags_patterns .= ' *.r */*.r'
    endif
endif


if !exists('g:rer#tags_cmd')
    let g:rer#tags_cmd = (has('win32') || has('win64') ? 'ctags.exe' : 'ctags') .' -R '. g:rer#tags_patterns   "{{{2
    if g:rer#debug
        let g:rer#tags_cmd .= ' || sleep 3'
    endif
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
    call rer#Send(r)
endf


" Inspect the word under the cursor.
function! rer#Inspect(...) "{{{3
    let word = a:0 >= 1 && !empty(a:1) ? a:1 : expand("<cword>")
    " TLogVAR word
    let r = printf('rerInspect(%s)', word)
    call rer#Send(r)
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
    let client = rer#GetClient()
    let clist = []
    let fn = s:GetFunctionOfWord(a:base, 1)
    if !empty(fn)
        if fn =~ '^\(options\)$'
            let fn = string(fn)
        endif
        let r = printf('rerFormals(%s, names.only = TRUE)', fn)
        let args = client.EvaluateInSession(r, 'r')
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
        let completions = client.EvaluateInSession(r, 'r')
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
        let client = rer#GetClient()
        let r = printf('rerFunctionArgs(%s, %s)', a:word, fn)
        " TLogVAR r
        let val = client.EvaluateInSession(r, 'r')
        if !empty(val) && val != "NULL"
            echohl Type
            echo val
            echohl NONE
        endif
    endif
endf


let s:wd = ''

function! rer#R_setwd(client) "{{{3
    let s:wd = rer#Filename(expand('%:p:h'), a:client)
    return printf('setwd(%s)', rer#ArgumentString(s:wd))
endf


function! rer#Cd() "{{{3
    let client = rer#GetClient()
    let r = rer#R_setwd(client)
    call client.EvaluateInSession(r, '')
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
        call rer#Send(r)
    endif
endf


let s:debugged = []
let s:breakpoints = {}

" Toggle the debug status of a function.
function! rer#Debug(fn) "{{{3
    " TLogVAR fn
    if !empty(a:fn) && index(s:debugged, a:fn) == -1
        let r = printf('{debug(%s); "ok"}', a:fn)
        let rv = rer#Send(r, 'r')
        " TLogVAR rv
        if rv == "ok"
            call add(s:debugged, a:fn)
            call s:HighlightDebug()
        else
            echohl Error
            echom "ReR: Cannot debug ". a:fn
            echohl NONE
        endif
    else
        call rer#Undebug(a:fn)
    endif
endf


" Undebug a debugged function.
function! rer#Undebug(fn) "{{{3
    let fn = a:fn
    if empty(fn)
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
        call rer#Send(r)
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
        let filename = tlib#input#List('s', 'Select filename:', keys(s:breakpoints))
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
        let bplnums = tlib#input#List('m', 'Select breakpoint:', lnums)
        let bplnums = map(bplnums, 'str2nr(v:val, 10)')
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
            let r = printf('rerSetBreakpoint(%s, %s, clear = %s, nameonly = FALSE)',
                        \ string(escape(filename, '\"')), lnum, clear)
            call rer#Send(r)
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
        call rer#Send(r)
    endif
endf


function! rer#Quicklist(word) "{{{3
    " TLogVAR a:word
    let ql = map(copy(g:rer#quicklist), 'tlib#string#Printf1(v:val, a:word)')
    let r = tlib#input#List('s', 'Select function:', ql, g:rer#handlers)
    if !empty(r)
        call rer#Send(r)
    endif
endf


function! rer#EditItem(world, items) "{{{3
    " TLogVAR a:items
    let item = get(a:items, 0, '')
    call inputsave()
    let item = input('R: ', item)
    call inputrestore()
    " TLogVAR item
    if item != ''
        let a:world.rv = item
        let a:world.state = 'picked'
        return a:world
    endif
    let a:world.state = 'redisplay'
    return a:world
endf


function! rer#Tags() "{{{3
    if empty(s:wd)
        echohl WarningMsg
        echom "rer#Tags: Working directory is not set; using expand('%:p:h')"
        echohl NONE
        let wd = expand('%:p:h')
    else
        let wd = s:wd
    endif
    exec 'lcd!' fnameescape(wd)
    try
        exec 'silent !' g:rer#tags_cmd
    finally
        lcd! -
    endtry
endf


function! rer#GetClient() abort "{{{3
    return rer#client#{g:rer#client_name}#GetInstance()
endf


function! rer#Send(code, ...) abort "{{{3
    let client = rer#GetClient()
    return call(client.Send, [a:code] + a:000, client)
endf

