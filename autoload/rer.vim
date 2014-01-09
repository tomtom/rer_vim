" rer.vim
" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    25


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
    let r = printf('rer.keyword(%s, %s)', name, namestring)
    call rescreen#Send(r, 'r')
endf


" Inspect the word under the cursor.
function! rer#Inspect(...) "{{{3
    let word = a:0 >= 1 && !empty(a:1) ? a:1 : expand("<cword>")
    " TLogVAR word
    let r = printf('rer.inspect(%s)', word)
    call rescreen#Send(r, 'r')
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
        let rescreen = rescreen#Init(1, {'repltype': 'r'})
        let r = printf('rer.complete(%s, %s)',
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
    let wd = s:RFilename(expand('%:p:h'), a:dict)
    return printf('setwd(%s)', rer#ArgumentString(wd))
endf


function! rer#Cd() "{{{3
    let rescreen = rescreen#Init(1, {'repltype': 'r'})
    let r = rer#R_setwd(rescreen)
    call rescreen.EvaluateInSession(r, '')
endf

