"If pythonVersion is 0, we're using python 2, otherwise we're using python 3.
let pythonVersion=1
function! SwitchPythonVersion()
    if g:pythonVersion
        setlocal makeprg=/usr/local/bin/python3\ %
    else
        setlocal makeprg=python\ %
    endif
    let g:pythonVersion = !g:pythonVersion
endfunction

augroup python_make
    setlocal makeprg=python\ %
    setlocal errorformat=%C\ %.%#,%A\ \ File\ \"%f\"\\,\ line\ %l%.%#,%Z%[%^\ ]%\\@=%m
    command! SwitchPythonVersion call SwitchPythonVersion()
augroup END

