" @Author:      Tom Link (mailto:micathom AT gmail com?subject=[vim])
" @License:     GPL (see http://www.gnu.org/licenses/gpl.txt)
" @Revision:    23

" if !exists('g:tinykeymap#map#rdebug#map')
"     " Map leader for the "rdebug" tinykeymap.
"     let g:tinykeymap#map#rdebug#map = "gxD"
" endif


call tinykeymap#EnterMap("rdebug", "", {
            \ 'automap': 0,
            \ 'message': string('R Debugger (Press Q to quit)'),
            \ 'unknown_key': 'tinykeymap#rdebug#UnkownKey',
            \ 'disable_count': 1,
            \ })
call tinykeymap#Map('rdebug', '<CR>', 'call tinykeymap#rdebug#Send("n")')
call tinykeymap#Map('rdebug', ' ', 'call tinykeymap#rdebug#Send("f")')
call tinykeymap#Map('rdebug', 'n', 'call tinykeymap#rdebug#Send("n")')
call tinykeymap#Map('rdebug', 'f', 'call tinykeymap#rdebug#Send("f")')
call tinykeymap#Map('rdebug', 'c', 'call tinykeymap#rdebug#Send("c")')
call tinykeymap#Map('rdebug', 's', 'call tinykeymap#rdebug#Send("s")')
call tinykeymap#Map('rdebug', 'w', 'call tinykeymap#rdebug#Send("where")')
call tinykeymap#Map('rdebug', 'Q', 'call tinykeymap#rdebug#Send("Q")', {'exit': 1})
call tinykeymap#Map('rdebug', ':', 'call tinykeymap#rdebug#Input("")')
call tinykeymap#Map('rdebug', '?', 'call tinykeymap#rdebug#Send("?browser")')

