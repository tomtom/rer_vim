" rer.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    41


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


if !exists('g:rer#options')
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
function! rer#Complete(findstart, base) "{{{3
    " TLogVAR a:findstart, a:base
    if a:findstart
        let line = getline('.')
        let start = col('.') - 1
        while start > 0 && line[start - 1] =~ '[._[:alnum:]]'
            let start -= 1
        endwhile
        return start
    else
        let rescreen = rescreen#Init(1, {'repltype': 'rer'})
        let r = printf('rerComplete(%s, %s)',
                    \ rer#ArgumentString('^'. escape(a:base, '^$.*\[]~"')),
                    \ rer#ArgumentString(exists('w:tskeleton_hypererplete') ? 'tskeleton' : ''))
        let completions = rescreen.EvaluateInSession(r, 'r')
        " TLogVAR completions
        let clist = split(completions, '\n')
        " TLogVAR clist
        return clist
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
        echoerr "Rer: Unsupport value: ". string(a:value)
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

