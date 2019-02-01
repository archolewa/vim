" Contains java specific commands that are useful for following formatting
" rules.
augroup java_format
    autocmd!
    " Allows me to easily find lines that are too long without having to
    " rely on checkstyle, or an obnoxious colored column.
    command! LongLines /^.\{120\}
    au BufWritePre * TideUnusedImports
augroup END

function! Translate_javaclasspath()
    let classpath=".,,src/main/java,src/main/test," . fnamemodify("~/tide-sources/", ":p") . ","
    if filereadable(".classpath")
        let java_classpath = join(map(readfile(".classpath"), 'fnamemodify(v:val, ":p:h") . "/tide-sources/"'), ",")
    else
        let java_classpath = ""
    endif
    return classpath . java_classpath
endfunction

augroup java_include
    set tags=tags
    autocmd!
     set include=^import\ \\zs.\\{-\\}\\ze;
     execute "set path=".Translate_javaclasspath()
    " Enable gf on import statements.  Convert . in the package
    " name to / and append .java to the name, then search the path.
    " Also allows using [i, but that's *way* too slow.
     set includeexpr=substitute(v:fname,'\\.','/','g')
     set suffixesadd=.java
    command! Classname :let @@ = Translate_directory(@%)
     set omnifunc=TideOmniFunction
augroup END

" Make for java, using javac.
augroup java_make
    autocmd!
    " Just use make. Without any of these fancy neomake plugins or what-not.
     set makeprg=javac\ -g:none\ -nowarn\ -classpath\ `cat\ .raw-classpath`\ -d\ /tmp\ `find\ .\ -name\ *.java`
     set errorformat=%E%f:%l:\ %m,%-Z%p^,%+C%.%#
    " Copy just the part of the filename used in maven's test plugin to the
    " clipboard. This is useful for running my java-debug.sh script to start a
    " debugging session with this test.
     command! CopyTestFilename let @+ = expand("%:t:r")
augroup END

" Defines a collection of commands for making common patterns in Java easier.
augroup java_generate
    autocmd!
    function! GetClassname()
        let c = @c
        let @c = expand("%:t:r")
        normal "cp
        let @c = c
    endfunction
    command! Classname :call GetClassname()
    " Extracts a variable out of a function signature and creates
    " a local variable of the same type and name.
    " So the line:
    " foo(int x)
    " becomes
    " int x =
    " foo(x)
    command! ExtractVariable :normal 2yw"_dw0"ay^O<Esc>"app
    nnoremap <Leader>v :ExtractVariable<CR>
augroup END

function! Children(className, directory)
    execute 'grep -r --include=*.java "\\(extends\\|implements\\) ' . a:className . '"' . a:directory
endfunction
augroup java_search
    autocmd!
    " Find classes that extend this class or implement this interface.
    command! -nargs=+ Children :call Children(<f-args>)
    " Find the class definition of the identifier under the cursor.
    command! -nargs=+ ClassDef :grep -r --include=*.java "class <args>" <args>
    " Jump to parent or interface
    command! ParentIdentifier execute "/\\(\\<extends\\>\\|\\<implements\\>\\) \\S*" | normal nW
    " Jump to class declaration. The class declaration starts at the access modifier
    " that's"^/s*public fully indented to the left.
    command! ClassDeclaration execute "?^\\(public\\|private\\|protected\\|class\\)" | normal n2W

    " Allows me to jump to the start of a method definition in a class, since
    " all methods are indented 4 spaces in the Java projects I work on.
    " We also don't make use of package-private.
     nnoremap [[ ?^ \{4\}\S<CR>
     nnoremap ]] /^ \{4\}\S<CR>
     vnoremap [[ ?^ \{4\}\S<CR>
     vnoremap ]] /^ \{4\}\S<CR>
     onoremap [[ ?^ \{4\}\S<CR>
     onoremap ]] /^ \{4\}\S<CR>
     nnoremap [\ ?^ \{4\}}$?e<CR>
     nnoremap ]\ /^ \{4\}}$/e<CR>
     vnoremap [\ ?^ \{4\}}$?e<CR>
     vnoremap ]\ /^ \{4\}}$/e<CR>
     onoremap [\ ?^ \{4\}}$?e<CR>
     onoremap ]\ /^ \{4\}}$/e<CR>

    " Allows me to customize gd to understand Java functions.
     nmap gd "syiw<CR>[[ /<C-R>s<CR>
augroup END

augroup java_tags
    autocmd!
    " Allows me to jump to the start of a method definition in a class, since
    " all methods are indented 4 spaces in the Java projects I work on.
    " We also don't make use of package-private.
     nnoremap <C-\> :Tidetag <C-R><C-W><cr>
     nnoremap g\ :Tidetselect <C-R><C-W><cr>
     nnoremap g<C-\> :Tidetlist<CR>
     nnoremap <C-n> :Tidetnext<CR>
     nnoremap <C-p> :Tidetprevious<CR>
augroup END

" Ask the user for which class to import, and appends the import to the import
" list. The next step is to put it in the correct spot alphabetically.
nnoremap <Leader>i :TideImport <C-R><C-W><CR>

" A function for finding the 'outline' of a file, whatever that means.
" We get the outline by performing a search of the specified pattern, and then
" opening the quickfix window.
function! Outline(pattern)
    execute 'vimgrep ' . '"' . a:pattern . '" '. expand("%")
    execute 'copen'
endfunction

augroup java_overview
    autocmd!
    " Display a list of public methods/members.
     command! Outline :call Outline("^\\s*public")
augroup END


