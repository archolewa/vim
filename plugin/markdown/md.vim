" --- Markdown ---
augroup markdown_search
    autocmd!
    " Allows me to co-opt the `[[`, `]]` movements to jump between Markdown
    " headings.
     nnoremap [[ ?^#<CR>
     nnoremap ]] /^#<CR>
     vnoremap [[ ?^#<CR>
     vnoremap ]] /^#<CR>
     onoremap [[ ?^#<CR>
     onoremap ]] /^#<CR>
augroup END

augroup markdown_overview
    autocmd!
    " Outline returns all the headings in the file.
     command! Outline :call Outline("^#")
augroup END

