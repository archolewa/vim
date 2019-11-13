" --- Git Review Diffs --
" Defines a collection of commands for navigating git diffs,
" where diffs are displayed using --word-diff=plain

function! JumpToFileDiff()
    let fileName = split(getline("."))[0]
    execute "2buffer" 
    execute "FindFile " . fileName
endfunction 

function! JumpToDiff(buffernum, diffindicator)
    let line = trim(split(getline("."), a:diffindicator)[0])
    execute a:buffernum . "buffer"
    call search(line, 'scw')
endfunction

function! JumpToCode()
    let line = getline('.')
    let startaddition = match(line, "{+") + 2
    let endaddition = match(line, "+}") - 1
    if startaddition > 0
        let line = line[startaddition:endaddition]
    endif
    let line = trim(line)
    let searchCommand = ":grep -F " . "'" . line . "'"
    execute searchCommand
endfunction

augroup git_review_diffs
    autocmd!
    command! NextDiff call search("{+\\|\\[-\\|^+\\|^-", "s")
    command! PreviousDiff call search("{+\\|\\[-\\|^+\\|^-", "sb")
    command! -nargs=1 FindFile call search("^++.*" . "<args>", "s")
    command! NextFile call search("^+++", "s")
    command! PreviousFile call search("^+++", "sb")
    command! Outline :vimgrep "^+++" % <bar> copen
    command! NextComment call search("^{#", "s")
    command! PreviousComment call search("^{#", "sb")
    command! FileDiff call JumpToFileDiff()
    command! GithubDiff call JumpToDiff(3, "{+\\|\\[-\\|+}\\|-\\]")
    command! GitDiff call JumpToDiff(2, "+\\|-")
    command! JumpToCode :call JumpToCode()

    nnoremap [[ :PreviousFile<CR>zt
    nnoremap ]] :NextFile<CR>zt
    vnoremap [[ :PreviousFile<CR>zt
    vnoremap ]] :NextFile<CR>zt
    onoremap [[ :PreviousFile<CR>zt
    onoremap ]] :NextFile<CR>zt
    nnoremap <Leader>k :PreviousDiff<CR>
    nnoremap <Leader>j :NextDiff<CR>
    vnoremap <Leader>k :PreviousDiff<CR>
    vnoremap <Leader>j :NextDiff<CR>
    onoremap <Leader>k :PreviousDiff<CR>
    onoremap <Leader>j :NextDiff<CR>
    nnoremap <Leader>K :PreviousComment<CR>
    nnoremap <Leader>J :NextComment<CR>
    vnoremap <Leader>K :PreviousComment<CR>
    vnoremap <Leader>J :NextComment<CR>
    onoremap <Leader>K :PreviousComment<CR>
    onoremap <Leader>J :NextComment<CR>
    nnoremap <C-H> :GithubDiff<CR> 
    nnoremap <C-G> :GitDiff<CR>
augroup END

