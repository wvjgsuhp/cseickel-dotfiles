nnoremap <silent> <C-t> :tabnew<cr><bar>:Startify<cr>
nnoremap <M-t> :TabooRename 

let $EDITOR="nvr --remote-wait -cc 'call DWM_New()'"

function! BufferDelete() abort
    if winnr('$') > 1
        bd
        call DWM_Focus()
    else
        bd
    endif
endfunction 
nnoremap <silent> <C-n>     :call DWM_New()<bar>Startify<cr>
nmap     <silent> <C-q>     <Plug>DWMClose
nmap     <silent> <M-q>     :call BufferDelete()<cr>
"nmap     <silent> <         <Plug>DWMShrinkMaster
"nmap     <silent> >         <Plug>DWMGrowMaster
nmap     <silent> <C-h>     <Plug>DWMFocus
nmap     <silent> <C-j>     <Plug>DWMMoveDown
nmap     <silent> <C-k>     <Plug>DWMMoveUp
nmap     <silent> <C-l>     <Plug>DWMMoveRight

function! ToggleWindowZoom(clear_decorations) abort
    if exists("b:is_zoomed_win") && b:is_zoomed_win
        unlet b:is_zoomed_win
        let l:name = expand("%:p")
        let l:top = line("w0")
        let l:line = line(".")
        tabclose
        let windowNr = bufwinnr(l:name)
        if windowNr > 0
            execute windowNr 'wincmd w'
            execute "normal " . l:top . "zt"
            execute l:line
        endif
    else
        if winnr('$') > 1 || a:clear_decorations
            let l:top = line("w0")
            let l:line = line(".")
            -1tabedit %
            let b:is_zoomed_win = 1
            execute "normal " . l:top . "zt"
            execute l:line
            execute "TabooRename  " . expand("%:t")
        endif
        if a:clear_decorations
            set nonumber
            set signcolumn=no
            IndentBlanklineDisable
        endif
    endif
endfunction

function! CloseAllTools()
    call CloseTerminal()
    cclose
    lclose
    redraw
endfunction


nnoremap <silent> <C-\> :lua shadow_term_toggle()<cr>
nnoremap <silent> <C-\> :ToggleTerm<cr>



"*****************************************************************************
"" LSP Mappings
"*****************************************************************************
nnoremap <silent>       K         :lua vim.lsp.buf.hover()<cr>
nnoremap <silent>       <leader>= :Neoformat<cr>

function! InitSql()
    nnoremap <silent><buffer> <M-x> :%DB $DBUI_URL<cr>
    vnoremap <silent><buffer> <M-x> :DB $DBUI_URL<cr>
    let b:db=$DBUI_URL
endfunction

augroup plugin_mappings_augroup
    autocmd!
    autocmd CursorHold * silent! lua vim.lsp.buf.document_highlight()
    autocmd CursorMoved * silent! lua vim.lsp.buf.clear_references()
    autocmd FileType typescript,javascript nnoremap <buffer><leader>= :lua vim.lsp.buf.formatting()<cr>
    autocmd FileType sql call InitSql()
    autocmd FileType qf,Trouble silent! call CloseAllTools()
    autocmd FileType Trouble setlocal cursorline
    autocmd FileType json nnoremap <buffer> <leader>= :%!python -m json.tool<cr>
    "autocmd FileType qf call timer_start(20, { tid -> execute('call ReplaceQuickfix()')})
augroup END

function! Syn()
  for id in synstack(line("."), col("."))
    echo synIDattr(id, "name")
  endfor
endfunction
command! -nargs=0 Syn call Syn()
