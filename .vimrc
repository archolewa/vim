au BufRead,BufNewFile *.groovy set filetype=groovy
au BufRead,BufNewFile *.python set filetype=python
au BufNewFile,BufRead *.sedl, set filetype=yaml
au BufNewFile,BufRead *.hs, set filetype=haskell
au BufNewFile,BufRead *.yaml, set filetype=yaml
au BufNewFile,BufRead *.tex, set filetype=tex
au BufNewFile,BufRead *.txt, set filetype=markdown
au BufNewFile,BufRead *.md, set filetype=markdown
au BufNewFile,BufRead *.feature, set filetype=feature
au BufNewFile,BufRead *.js, set filetype=javascript
au BufNewFile,BufRead *.json, set filetype=javascript
au BufNewFile,BufRead *.java, set filetype=java
au BufRead,BufNewFile *.ebnf set filetype=ebnf
au BufRead,BufNewFile *.avdl set filetype=avdl
au BufRead,BufNewFile *.diff set filetype=diff

" Disable netrw.
let loaded_netrwPlugin = 1

" I use git for backups.
set noswapfile
set nobackup

" Enables matchit, which provides for more sophisticated use of % for
" matching programming language constructs. Required for
" https://github.com/nelstrom/vim-textobj-rubyblock, which I'm using to
" have intelligent matching of lua blocks (which also terminate with the
" `end` keyword).
runtime macros/matchit.vim

if has('python3')
    silent! python3 1
endif

"Pathogen load
call pathogen#infect()
call pathogen#helptags()
" I don't like it when a computer tries to do things for me, I'd rather have
" custom mappings, like a mapping to duplicate the previous line's indent,
" to handle indenting. Otherwise, I find myself fighting the computer.
filetype indent plugin off
filetype on
" I find syntax highlighting to be unnecessary visual stimulation. I don't
" know that syntax highlighting really contributes much.
syntax off
set backspace=indent,eol,start
" Hide buffers instead of closing them. Means I don't have to save before
" switching, and may speed things up maybe?
set hidden
" I don't want my search results to be highlighted by default. For one thing,
" I use search in some of my navigation keybindings, and I don't want to have
" to invoke nohlsearch after each such binding, or pollute my screen with
" unnecessary highlights.
set nohlsearch
" The computer is not allowed to do things for me.
set nowrap
set ruler
set list
set expandtab
set shiftwidth=4
set tabstop=4
autocmd FileType javascript setlocal tabstop=2
autocmd FileType javascript setlocal shiftwidth=2
set shiftround
set nofoldenable
colorscheme desert
highlight ColorColumn ctermbg=8

" Run a case insensitive search. By default, run case sensitive searches
nnoremap <Leader>/ //c
set foldmethod=indent
set path=.,,
set incsearch
set tags=./tags;~/tags
set splitright
" Disable all colors
set t_Co=0
set listchars=eol:¬,tab:>-,space:·
" Use :set list! to toggle the nonprinting characters.
set nolist

" Disable the completion popup. It's not really necessary, because there isn't
" (so far as I know) a way to jump directly to a match. If you need to cycle
" through them anyway, might as well cycle through them.
set completeopt=
set pumheight=1
set complete=.,w,b

function! ToggleStatusLine()
    if (&laststatus == 2)
        set laststatus=0
    else
        set laststatus=2
    endif
endfunction

" By default we don't display the status line, but we can turn it on and off
" if we need it (say to see the git branch/filename or current line number)
set laststatus=0
command! ToggleStatusLine :call ToggleStatusLine()<CR>

set statusline=%{fugitive#statusline()};
set statusline+=%f:%l:%c;

" Turn off that awful highlighting in the quickfix window
hi QuickFixLine cterm=NONE ctermfg=grey ctermbg=black

" Turn off unnecessary localizations in diffview
let g:diff_translations = 0

"Repeating the previous find will be quite useful considering how often I
"rely on it, but ; is SOOO convenient as the leader key.
nnoremap \ ;
let mapleader = ";"

set title

" Wrapping!
nnoremap <Leader>w :ArgWrap<CR>

" Search, but don't jump to the first result.
nnoremap <Leader>s :Ack!<Space>
" Search in current file (d is between s and f on 
" my keyboard, i.e. 'search file'.
nnoremap <Leader>d :vimgrep <C-r>%<C-f><Esc>F<Space>a

" ------- Code exploration ----------

" Cscope settings. Cscope lets us search for usages of a particular identifier.

" Use this directory's cscope database, or the global database otherwise.
if filereadable("cscope.out")
    cs add cscope.out
elseif $CSCOPE_DBS != ""
    cs add $CSCOPE_DBS
endif
set cscoperelative

" Putting cscope results in quickfix, which is much friendlier than whatever
" it uses by default.
set cscopequickfix=s-,c-,d-,i-,t-,e-,a-,g-

" At the end of each of these mappings we jump back to the previous jump,
" because cscope insists on jumping to the first match, and I don't want that.

" Find all uses of a symbol. Yeah, I know the shortcut doesn't make any sense. It's
" a holdover from my IntelliJ days.
nnoremap <Leader>b :cs find s <C-R>=expand("<cword>")<CR><CR>:copen<CR><c-w>k<c-o><c-w>j

" Open the location list with all identifiers that match the tag under the
" cursor, without jumping to any of them.
nnoremap g] :ltag <C-R><C-W><CR>:lopen<CR><c-w>k<c-o><c-w>j

nnoremap <c-y> :tnext<cr>

" ---------- Buffer management -----------
" Close current window, without actually closing the buffer. This gives me the
" ability to quickly open and close splits and what-not, while still being able
" to easily jump to the desired buffer.
nnoremap <space>d <C-w>c<CR>

"  Commands for navigating buffers and files.
" Wildcard File search
nnoremap <Leader>f q:ie **/
" This allows me to type in the buffer number, and press , to jump to
" that buffer. I hardly ever use f or t, so I'm not losing much here.
" Also makes it very easy to flip between the current and alternate buffer.
nnoremap , <C-^>

" Jump to next error.
nnoremap <Leader>n :cnext<CR>
nnoremap <Leader>p :cprevious<CR>

" Copy the name of the current file into the system clipboard for use in other
" programs.
command! CopyFilename let @+ = expand("%")

" ------ Line diffs ------
"
" This allows me to quickly open a diff of two particular lines. *Very* useful
" when looking at test failure outputs for complex data structures. 
vnoremap <Leader>ld :'<,'>Linediff<CR>
nnoremap <Leader>le :LinediffReset<CR>

" Remove all trailing spaces
function! TrimWhiteSpace()
    %s/\s*$//
    ''
endfunction
command! Trim call TrimWhiteSpace()

" Should start using this instead of Caps Lock as escape, much more portable.
inoremap jj <Esc>

" Colors are my nemesis!
let g:ackprg = 'ag --vimgrep --nocolor --word-regexp'
let g:ack_autofold_results = 1

" Prompt for whether to create any directories that don't exist when saving,
" or use w! to just do it.
augroup vimrc-auto-mkdir
  autocmd!
  autocmd BufWritePre * call s:auto_mkdir(expand('<afile>:p:h'), v:cmdbang)
  function! s:auto_mkdir(dir, force)
    if !isdirectory(a:dir)
          \   && (a:force
          \       || input("'" . a:dir . "' does not exist. Create? [y/N]") =~? '^y\%[es]$')
      call mkdir(iconv(a:dir, &encoding, &termencoding), 'p')
    endif
  endfunction
augroup END

" Disable tabs. The tabs that Macvim opens when I open a file in an already
" running instance aren't really "tabs." Besides, I use buffers.
autocmd BufWinEnter,BufNewFile * silent tabo

" Terminal mode customizations
" Provide a more intuitive, less awkward keymap for exiting terminal mode.
tnoremap <Leader><Esc> <C-\><C-n>
" The <Leader> key is because sometimes I open vim inside the terminal mode,
" for things like interactive rebase. With this mapping, trying to navigate in
" the inner vim with j won't kick me out of terminal mode.
tnoremap <Leader>jj <C-\><C-n>

" Remove the background colors when using vimdiff.
highlight DiffAdd ctermbg=NONE ctermfg=NONE
highlight DiffDelete ctermbg=NONE ctermfg=Red
highlight DiffText cterm=NONE ctermfg=Blue
highlight DiffChange ctermbg=NONE ctermfg=NONE
highlight DiffAdd guibg=NONE guifg=NONE
highlight DiffDelete guibg=NONE guifg=Red
highlight DiffText gui=NONE guifg=Green
highlight DiffChange guibg=NONE guifg=NONE

" Some changes to make macros more pleasant
" Don't render every keystroke of the macro, just the end result
set lazyredraw

" ----Completions ----
" The bindings have
" zero mnmemonic value, they're selected for being convenient to type.
" file completion
inoremap <c-h> <c-x><c-f>
" tag completion
inoremap <c-k> <c-x><c-]>
" semantic completion
inoremap <c-l> <c-x><c-o>
" keyword completion
inoremap <c-j> <c-p>

" Close the preview window.
nnoremap <Space>p :pc<CR>
" Close all windows but this one.
nnoremap <Space>o :only<CR>

" Show filler lines to keep files synchronized, and open diff split vertically.
set diffopt=filler,vertical

" Opens the file under the cursor in an already existing buffer.
nnoremap <Leader>gf :let mycurf=expand("<cfile>")<CR><C-w>w:execute("e ".mycurf)<CR>

" Colors! My nemesis!
au ColorScheme * hi Error NONE
au ColorScheme * hi ErrorMsg NONE
au GuiEnter * hi Error NONE
au GuiEnter * hi ErrorMsg NONE

" Allows me to cycle forward/backward through these pairs using %, g% [%, ]%
" etc.
let b:match_words='\[:\],<:>,\(:\),{:}'

" Indent to the same level as the previous line with text. There isn't any
" mnemonic for this, because it's optimized for typing speed and ease, since
" I'll be doing it often. Because I don't want the computer indenting for me.
inoremap jk <Esc>:let x=@/<CR>?^\s*\S<CR>"yy^<c-o>"yP:let @/=x<CR>a

" Delete the current line, then paste it below the one we're on now.
nnoremap - ddp
" Delete the current line, then paste it above the one we're on now.
nnoremap _ ddkP
" Converts current word to uppercase.
inoremap <c-u> <Esc>viwUi
nnoremap <c-u> viwU<Esc>

" Automatically replace double dashes with a single longer dash in prose.
augroup dash
    autocmd!
    au FileType yaml iabbrev -- &mdash
augroup END

" -------- Formatting -------- 
set nocindent
" Lets me find lines that are too long, without having to rely on colorcolumn.
command! LongLines /^.\{80\}

" ----- Java ----- 

" Ask the user for which class to import, and appends the import to the import
" list. The next step is to put it in the correct spot alphabetically.
nnoremap <Leader>ai :TideImport <C-R><C-W><CR>

" Contains java specific commands that are useful for following formatting
" rules.
augroup java_format
    autocmd!
    " Allows me to easily find lines that are too long without having to
    " rely on checkstyle, or an obnoxious colored column.
    au FileType java command! LongLines /^.\{120\}
augroup END

function! Translate_javaclasspath()
    let classpath=".,,src/main/java,src/main/test,"
    if filereadable(".raw-classpath")
        let java_classpath = join(map(split(readfile(".raw-classpath")[0], ":"), 'fnamemodify(v:val, ":h") . "/tide-sources/"'), ",")
    else
        let java_classpath = ""
    endif
    return classpath . java_classpath
endfunction

augroup java_include
    set tags=tags,~/tags
    autocmd!
    au FileType java set include=^import\ \\zs.\\{-\\}\\ze;
    au FileType java execute "set path=".Translate_javaclasspath()
    " Enable gf on import statements.  Convert . in the package
    " name to / and append .java to the name, then search the path.
    " Also allows using [i, but that's *way* too slow. 
    au FileType java set includeexpr=substitute(v:fname,'\\.','/','g')
    au FileType java set suffixesadd=.java
    command! Classname :let @@ = Translate_directory(@%)
augroup END

augroup java_completion
    au FileType java set omnifunc=TideOmniFunction
augroup END

" Make for java, using javac.
augroup java_make
    autocmd!
    " Just use make. Without any of these fancy neomake plugins or what-not.
    au FileType java set makeprg=javac\ -g:none\ -nowarn\ -classpath\ `cat\ .raw-classpath`\ -d\ /tmp\ `find\ .\ -name\ *.java`
    au FileType java set errorformat=%E%f:%l:\ %m,%-Z%p^,%+C%.%#
    " Copy just the part of the filename used in maven's test plugin to the
    " clipboard. This is useful for running my java-debug.sh script to start a
    " debugging session with this test.
    au FileType java command! CopyTestFilename let @+ = expand("%:t:r")
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

augroup java_search
    autocmd!
    " Find classes that implement this interface.
    command! -nargs=1 Implementors :Ack! --java "implements .*<args>"
    " Find classes that extend this class (i.e. subclasses).
    command! -nargs=1 Children :Ack! --java "extends <args>"
    " Find the class definition of the identifier under the cursor.
    command! -nargs=1 ClassDef :Ack! --java "class <args>"
    " Jump to parent or interface
    command! ParentIdentifier execute "/\\(\\<extends\\>\\|\\<implements\\>\\) \\S*" | normal nW
    " Jump to class declaration. The class declaration starts at the access modifier
    " that's"^/s*public fully indented to the left.
    command! ClassDeclaration execute "?^\\(public\\|private\\|protected\\|class\\)" | normal n2W

    " Allows me to jump to the start of a method definition in a class, since
    " all methods are indented 4 spaces in the Java projects I work on.
    " We also don't make use of package-private.
    au FileType java nnoremap [[ ?^ \{4\}\(protected\\|private\\|public\)<CR>
    au FileType java nnoremap ]] /^ \{4\}\(protected\\|private\\|public\)<CR>
    au FileType java vnoremap [[ ?^ \{4\}\(protected\\|private\\|public\)<CR>
    au FileType java vnoremap ]] /^ \{4\}\(protected\\|private\\|public\)<CR>
    au FileType java onoremap [[ ?^ \{4\}\(protected\\|private\\|public\)<CR>
    au FileType java onoremap ]] /^ \{4\}\(protected\\|private\\|public\)<CR>
    au FileType java nnoremap [\ ?^ \{4\}}$?e<CR>
    au FileType java nnoremap ]\ /^ \{4\}}$/e<CR>
    au FileType java vnoremap [\ ?^ \{4\}}$?e<CR>
    au FileType java vnoremap ]\ /^ \{4\}}$/e<CR>
    au FileType java onoremap [\ ?^ \{4\}}$?e<CR>
    au FileType java onoremap ]\ /^ \{4\}}$/e<CR>

    " Allows me to customize gd to understand Java functions.
    au FileType java nmap gd "syiw<CR>[[ /<C-R>s<CR>
augroup END

augroup java_tags
    autocmd!
    " Allows me to jump to the start of a method definition in a class, since
    " all methods are indented 4 spaces in the Java projects I work on.
    " We also don't make use of package-private.
    au FileType java nnoremap <C-\> :Tidetag <C-R><C-W><cr>
    au FileType java nnoremap g\ :Tidetselect <C-R><C-W><cr>
    au FileType java nnoremap g<C-\> :Tidetlist<CR>
    au FileType java nnoremap <C-n> :Tidetnext<CR>
    au FileType java nnoremap <C-p> :Tidetprevious<CR>
augroup END

augroup avdl_search
    autocmd!
    au FileType avdl nnoremap [[ ?^  record<CR>
    au FileType avdl nnoremap ]] /^  record<CR>
    au FileType avdl vnoremap [[ ?^  record<CR>
    au FileType avdl vnoremap ]] /^  record<CR>
    au FileType avdl onoremap [[ ?^  record<CR>
    au FileType avdl onoremap ]] /^  record<CR>
augroup END

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
    au FileType java command! Outline :call Outline("^\\s*public")
augroup END


" --- Lua ---
" Make for Lua. This works by just executing Lua with the current file.
augroup lua_make
    autocmd!
    au FileType lua setmakeprg=lua\ %
    au FileType lua seterrorformat=lua:\ %f:%l:\ %m
augroup END

augroup lua_overview
    au FileType lua command! Outline :call Outline("^\(M\|local\|function\)")
augroup END

" --- Markdown ---
augroup markdown_search
    autocmd!
    " Allows me to co-opt the `[[`, `]]` movements to jump between Markdown
    " headings.
    au FileType markdown nnoremap [[ ?^#<CR>
    au FileType markdown nnoremap ]] /^#<CR>
    au FileType markdown vnoremap [[ ?^#<CR>
    au FileType markdown vnoremap ]] /^#<CR>
    au FileType markdown onoremap [[ ?^#<CR>
    au FileType markdown onoremap ]] /^#<CR>
augroup END

augroup markdown_overview
    autocmd!
    " Outline returns all the headings in the file.
    au FileType markdown command! Outline :call Outline("^#")
augroup END 

" --- Git Review Diffs -- 
" Defines a collection of commands for navigating git diffs,
" where diffs are displayed using --word-diff=plain
augroup git_review_diffs
    autocmd!
    command! NextDiff call search("{+\\|[-")
    command! PreviousDiff call search("{+\\|[-", "b")
    " By using search, we can repeat searches for arbitrary
    " file patterns with `n`.
    command! -nargs=1 FindFile /^++.*<args>
    command! NextFile call search("^++")
    command! PreviousFile call search("^++", "b")

    au FileType diff nnoremap [[ :PreviousFile<CR>zt
    au FileType diff nnoremap ]] :NextFile<CR>zt
    au FileType diff vnoremap [[ :PreviousFile<CR>zt
    au FileType diff vnoremap ]] :NextFile<CR>zt
    au FileType diff onoremap [[ :PreviousFile<CR>zt
    au FileType diff onoremap ]] :NextFile<CR>zt
    au FileType diff nnoremap <Leader>p :PreviousDiff<CR>
    au FileType diff nnoremap <Leader>n :NextDiff<CR>
    au FileType diff vnoremap <Leader>p :PreviousDiff<CR>
    au FileType diff vnoremap <Leader>n :NextDiff<CR>
    au FileType diff onoremap <Leader>p :PreviousDiff<CR>
    au FileType diff onoremap <Leader>n :NextDiff<CR>
augroup END

" --- Quickfix ---
" This manages autocommands for keeping the quickfix tame. 
" I rely heavily on searching, tags, and cscope. However 
" all of those display file names and locations. Most of the
" time I don't care about that (though I do want Vim to know
" about them for easy jumping), so that is just noise. 
" This sets up my quickfix
" to hide filenames and locations except for when I 
" explicitly ask for them.
augroup quickfix_file_names
    autocmd!
    au FileType qf set conceallevel=2
    au FileType qf set concealcursor=n
    au FileType qf syntax match qfFileName /^.\{-\}\s\s*/ transparent conceal
    au FileType qf command! ConcealFile :set concealcursor=n
    au FileType qf command! ShowFile :set concealcursor=
    au FileType qf command! Show :set conceallevel=0
    au FileType qf command! Hide :set conceallevel=2
    au BufLeave quickfix set conceallevel=0
    au BufLeave quickfix delcommand ConcealFile
    au BufLeave quickfix delcommand ShowFile
    au BufLeave quickfix delcommand Show
    au BufLeave quickfix delcommand Hide
augroup END

" We have some private things we need (like the URL for corporate
" git repos), but I don't feel comfortable putting in a public dot file.
source ~/.vim/private.vim

" Display the current file name.
nnoremap <space>f :echom @%<CR>


command! -nargs=1 InsertPath r!find ~/ -name <args>
