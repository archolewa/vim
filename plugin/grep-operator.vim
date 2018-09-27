nnoremap <Leader>g :set operatorfunc=<SID>GrepOperator<cr>g@
vnoremap <Leader>g :<C-U>call <SID>GrepOperator(visualmode())<CR>

function! s:GrepOperator(type)
    let saved_unnamed_register = @@
    if a:type==# 'v'
        normal! `<v`>""y
    elseif a:type ==# 'char'
        normal! `[""y`]
    else
        return
    endif

    silent execute "Ack! -R " . shellescape(@@) . " ."
    copen
    let @@ = saved_unnamed_register
    echom(@@)
endfunction

" Get 10 text lines from buffer: getline(1, 10)
" append('$', lines) appends text lines in buffer.
