if exists('g:brazil_loaded')
    finish
endif
let g:brazil_loaded=1


function! s:GetWorkspaces(A,L,P)
    return system("b lws | grep '^" . a:A . "'")
endfunction

function! s:GetPackages(A,L,P)
    return system("b lspkg " . a:A)
endfunction

function! s:GetWPackages(A,L,P)
    return system("b pkgs | grep '^" . a:A . "'")
endfunction

function! s:WAddPkg(pdashb)
    let output = system("b addpkg " . a:pdashb)
    call s:WRefresh()
endfunction

function! s:WAddPkgBranch(p,b)
    let output = system("b addpkg " . a:p . " " . a:b)
    call s:WRefresh()
endfunction

function! s:WRmPkg(p)
    let output = system("b rmpkg " . a:p)
    call s:WRefresh()
endfunction

function! s:WPkgs()
    echo system("b pkgs")
endfunction

function! s:WList()
    echo system("b lws")
endfunction

function! s:WRefresh()
    source $CWS/workspace.vim
endfunction

function! s:WSwitch(ws)
    let $CWS = system("b sws " . a:ws . " p")
    let g:cws=$CWS
    call s:WRefresh()
endfunction

function! s:WP4(f)
    echo system("b p4db " . a:f)
endfunction

function! s:WSources()
    let bname='__SourceBrowser__'
    let winnum = bufwinnr(bname)
    if winnum != -1
        if winnr() != winnum
            exe winnum . 'wincmd w'
        endif
        return
    endif

    " Increase the window size, if needed, to accomodate the new
    " window
    if &columns < (80 + 20)
        " one extra column is needed to include the vertical split
        let &columns= &columns + (20 + 1)
        let s:br_winsize_chgd = 1
    else
        let s:br_winsize_chgd = 0
    endif

    " Open the window at the leftmost place
    let win_dir = 'topleft vertical'
    let win_width = 40

    let bufnum = bufnr(bname)
    if bufnum == -1
        let wcmd = bname
    else
        let wcmd = '+buffer' . bufnum
    endif

    exe 'silent! ' . win_dir . ' ' . win_width . 'split ' . wcmd
    
    setlocal buftype=nofile
    setlocal bufhidden=delete
    setlocal noswapfile
    setlocal nowrap
    setlocal nobuflisted
    setlocal nonumber

    nnoremap <buffer> <silent> <CR> gf<C-W>=
    nnoremap <buffer> <silent> ' gf<C-W>o
    cnoremap <buffer> <silent> <C-q> <Esc>:q<CR>
    "read ~/.jcache
    read $CWS/.jcache
endfunction

command WList :call <SID>WList()
command WPkgs :call <SID>WPkgs()
command WRefresh :call <SID>WRefresh()
command WSources :call <SID>WSources()
command -nargs=1 -complete=custom,s:GetWorkspaces WSwitch :call <SID>WSwitch(<f-args>)
command -nargs=1 -complete=custom,s:GetPackages WAddPkg :call <SID>WAddPkg(<f-args>)
command -nargs=1 -complete=custom,s:GetWPackages WRmPkg :call <SID>WRmPkg(<f-args>)

command -nargs=1 -complete=file WP4 :call <SID>WP4(<f-args>)

let g:cws=$CWS
call s:WRefresh()
