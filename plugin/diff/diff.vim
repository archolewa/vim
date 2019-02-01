" --- Git Review Diffs --
" Defines a collection of commands for navigating git diffs,
" where diffs are displayed using --word-diff=plain
augroup git_review_diffs
    autocmd!
    command! NextDiff call search("^\\(+\\|-\\)")
    command! PreviousDiff call search("^\\(+\\|-\\)", "b")
    " By using search, we can repeat searches for arbitrary
    " file patterns with `n`.
    command! -nargs=1 FindFile /^++.*<args>
    command! NextFile call search("^+++")
    command! PreviousFile call search("^+++", "b")
    command! NextComment call search("^{#")
    command! PreviousComment call search("^{#", "b")

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
augroup END

