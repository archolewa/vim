" --- Ocaml ---
augroup ocaml_make
    autocmd!
    set makeprg=dune\ build\ @all
    set errorformat=%EFile\ \"%f\"\\,\ line\ %l\\,\ characters\ %c-%*\\d:,%CError:\ %m,%CWarning\ %m,%ZHint:\ %m,%Z%m
augroup END

augroup ocaml_prefix
    autocmd!
    inoremap l- let () =<Space>
    inoremap l= let =<Esc>hi<Space>
augroup END

