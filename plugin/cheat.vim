" vim-cheat
"
" Maintainer:   Wang Shidong <wsdjeg@outlook.com>
" License:      MIT
" Version:      0.1.0

if exists('g:loaded_cheat')
    finish
endif

" Set the path to the cheat sheets cache file, can be overriden from
" .vimrc with:
"               let g:cheats_dir = '/path/to/your/cache/file'
let s:cheats_dir = get(g:, 'cheats_dir', $HOME . '/.cheats/')

" Set the split direction for the output buffer.
" It can be overriden from .vimrc as well, by setting g:cheats_split to hor | ver
let s:cheats_split = get(g:, 'cheats_split', 'hor')

" Constants
let s:splitCmdMap = { 'ver' : 'vsp' ,  'hor' : 'sp' }

let s:cheat_sheets = join(map(split(globpath(s:cheats_dir, '*'),'\n'), "fnamemodify(v:val, ':t')"),"\n")

" Func Defs
func! FindOrCreateOutWin(bufName)
    let l:outWinNr = bufwinnr(a:bufName)
    let l:outBufNr = bufnr(a:bufName)

    " Find or create a window for the bufName
    if l:outWinNr == -1
        " Create a new window
        exec s:splitCmdMap[s:cheats_split]

        let l:outWinNr = bufwinnr('%')
        if l:outBufNr != -1
            " The buffer already exists. Open it here.
            exec 'b'.l:outBufNr
        endif
        " Jump back to the previous window the user was editing in.
        exec 'wincmd p'
    endif

    " Find the buffer number or create one for bufName
    if l:outBufNr == -1
        " Jump to the output window
        exec l:outWinNr.' wincmd w'
        " Open a new output buffer
        exec 'e '.a:bufName
        setlocal noswapfile
        setlocal buftype=nofile
        setlocal wrap
        let l:outBufNr = bufnr('%')
        " Jump back to the previous window the user was editing in.
        exec 'wincmd p'
    endif
    return l:outBufNr
endf

func! RunAndRedirectOut(cheatName, bufName)
    " Change to the output buffer window
    let l:outWinNr = bufwinnr(a:bufName)
    exec l:outWinNr.' wincmd w'

    " Build the final (vim) command we're gonna run
    let l:runCmd = 'r ' . fnameescape(s:cheats_dir . a:cheatName)

    " Run it
    normal! G
    silent! exec l:runCmd

    normal! gg
endf

func! CheatCompletion(ArgLead, CmdLine, CursorPos)
    return s:cheat_sheets
endf

func! Cheat(c)
    let l:c = !empty(a:c) ? a:c : input('Cheat Sheet: ', '', 'custom,CheatCompletion')
    let l:outBuf = FindOrCreateOutWin('-cheat_output-')
    call RunAndRedirectOut(l:c, l:outBuf)
endf

func! CheatCurrent()
    call Cheat(expand('<cword>'))
endf

" Commands Mappings
comm! -nargs=1 -complete=custom,CheatCompletion Cheat :call Cheat(<q-args>)
comm! CheatCurrent :call CheatCurrent()
comm! CheatRecent :call Cheat('recent')

" Disable default mappings
"       let g:Cheat_EnableDefaultMappings = 0
if get(g:, 'Cheat_EnableDefaultMappings', 1)
    if empty(maparg('<Leader>C', 'n'))
        nnoremap <Leader>C :call Cheat('')<CR>
    endif
    " Ask for cheatsheet for the word under cursor
    if empty(maparg('<Leader>ch', 'n'))
        nmap <leader>ch :call CheatCurrent()<CR>
    endif
    if empty(maparg('<Leader>ch', 'v'))
        vmap <leader>ch <ESC>:call CheatCurrent()<CR>
    endif
endif
let g:loaded_cheat = 1
