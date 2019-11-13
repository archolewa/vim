" --- Lua ---
" Make for Lua. This works by just executing Lua with the current file.
augroup lua_make
    autocmd!
    set makeprg=lua\ %
    set errorformat=lua:\ %f:%l:\ %m
augroup END

augroup lua_overview
    command! Outline :call Outline("^\(M\|local\|function\)")
augroup END

