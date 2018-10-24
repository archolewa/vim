au BufRead,BufNewFile *.groovy set filetype=groovy
au BufRead,BufNewFile *.python set filetype=python
au BufNewFile,BufRead *.sedl, set filetype=yaml
au BufNewFile,BufRead *.hs, set filetype=haskell
au BufNewFile,BufRead *.yaml, set filetype=yaml
au BufNewFile,BufRead *.tex, set filetype=tex
au BufNewFile,BufRead *.txt, set filetype=txt
au BufNewFile,BufRead *.md, set filetype=markdown
au BufNewFile,BufRead *.feature, set filetype=feature
au BufNewFile,BufRead *.js, set filetype=javascript
au BufNewFile,BufRead *.json, set filetype=javascript
au BufNewFile,BufRead *.java, set filetype=java
au BufRead,BufNewFile *.ebnf set filetype=ebnf

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

" yank to clipboard
if has("clipboard")
  set clipboard=unnamed " copy to the system clipboard

  if has("unnamedplus") " X11 support
    set clipboard+=unnamedplus
  endif
endif

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
" I find syntax highlighting to be unnecessary visual stimulation. I don't
" know that syntax highlighting really contributes much.
syntax off

set clipboard=unnamed
set backspace=indent,eol,start
" Hide buffers instead of closing them. Means I don't have to save before
" switching, and may speed things up maybe?
set hidden
" I don't want my search results to be highlighted by default. For one thing,
" I use search in some of my navigation keybindings, and I don't want to have
" to invoke nohlsearch after each such binding, or pollute my screen with
" unnecessary highlights.
set nohlsearch
" Sometimes, I want ot turn highlighting on temporarily.
nnoremap <Leader>h :set hlsearch<CR>
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
set colorcolumn=80
colorscheme desert
autocmd FileType java setlocal colorcolumn=120
autocmd FileType groovy setlocal colorcolumn=120
autocmd FileType javascript setlocal colorcolumn=120
highlight ColorColumn ctermbg=8

" Run a case insensitive search. By default, run case sensitive searches
nnoremap <Leader>/ //c
set foldmethod=indent
set path=.,/usr/include,,**
set incsearch
set tags=./tags;$HOME
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
nnoremap <Leader>st :call ToggleStatusLine()<CR>

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
" Search in current file.
nnoremap <Leader>sf :Ack! <C-r>%<C-f><Esc>F<Space>a
" Search for character under the cursor
nnoremap <Leader>sc :Ack! <C-r><C-w><CR>
" Search in particular file types
nnoremap <Leader>sj :Ack! --java<Space>
nnoremap <Leader>sg :Ack! --groovy<Space>
nnoremap <Leader>sl :Ack! --lua<Space>
nnoremap <Leader>sp :Ack! --python<Space>

" ------- Code exploration ----------

" Cscope settings. Cscope lets us search for usages of a particular identifier.

" Use this directory's cscope database, or the global database otherwise.
if filereadable("cscope.out")
    cs add cscope.out
elseif $CSCOPE_DBS != ""
    cs add $CSCOPE_DBS
endif

" Putting cscope results in quickfix, which is much friendlier than whatever
" it uses by default.
set cscopequickfix=s-,c-,d-,i-,t-,e-,a-,g-

" At the end of each of these mappings we jump back to the previous jump,
" because cscope insists on jumping to the first match, and I don't want that.

" Find all uses of a symbol
nnoremap <Leader>bu :cs find s <C-R>=expand("<cword>")<CR><CR>:copen<CR><c-w>k<c-o>

" Open the location list with all identifiers that match the tag under the
" cursor, without jumping to any of them.
" TODO: Figure out a way to interrogate the location list, and automatically
" jump if there is one entry in the list. That, or figure out how to do some
" inspection to the left and right so that I can apply some heuristics to
" prefilter out matches.
nnoremap g] :ltag <C-R><C-W><CR>:lopen<CR><c-w>k<c-o><c-w>j

" Jump
nnoremap <c-]> :ltag <C-R><C-W><cr>

" ---------- Buffer management -----------
" Close current window, without actually closing the buffer. This gives me the
" ability to quickly open and close splits and what-not, while still being able
" to easily jump to the desired buffer.
nnoremap <space>d <C-w>c<CR>
" If you *really* want to close the buffer.
nnoremap <space>D :bd<CR>

"  Commands for navigating buffers and files.
" Regex File search
nnoremap <Leader>f :e **/<c-f>
" Regex buffer search.
nnoremap gt :filter ## ls<c-f>BB
" This allows me to type in the buffer number, and press , to jump to
" that buffer. I hardly ever use f or t, so I'm not losing much here.
nnoremap , <C-^>

" This will build the project and drop any compilation errors into the quickfix
" window.
nnoremap <Leader>m :make<CR><copen><CR>
" Jump to next error.
nnoremap <Leader>n :cnext<CR>

" Copy the name of the current file into the system clipboard for use in other
" programs.
nnoremap <Leader>yy :let @" = expand("%")
" Copy just the part of the filename used in maven's test plugin to the
" clipboard. This is useful for running my java-debug.sh script to start a
" debugging session with this specification.
nnoremap <Leader>yf :let @+ = expand("%:t:r")<CR>

" ------------ Gulp Commands ---------
nnoremap <Leader>gt :Dispatch gulp unit -f %<CR>:copen<CR>
nnoremap <Leader>gg :Dispatch gulp unit<CR>:copen<CR>

" ------ Line diffs ------
"
" This allows me to quickly open a diff of two particular lines. *Very* useful
" when looking at test failure outputs from some test frameworks (like Spock).
vnoremap <Leader>ld :'<,'>Linediff<CR>
nnoremap <Leader>le :LinediffReset<CR>

" Remove all trailing spaces
function! TrimWhiteSpace()
    %s/\s*$//
    ''
endfunction
nnoremap <Leader>t :call TrimWhiteSpace()<CR>

" Folding colors that don't make me cry.
highlight Folded ctermfg=green ctermbg=black
hi clear SpellBad
hi SpellBad cterm=underline
let g:tex_fold_enabled=0
let g:markdown_fold_style = 'nested'

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

" Git shortcuts
nnoremap <Leader>gs :Gstatus<CR>
nnoremap <Leader>gb :Gblame<CR>
nnoremap <Leader>gc :Gcommit<CR>
" Git lookup
nnoremap <Leader>gl :Gbrowse<CR>
vnoremap <Leader>gl :'<,'>Gbrowse<CR>

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
" We use the default <c-p> for keyword (text) completion. The bindings have
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

" ---- Easytags settings
" Easytags is convenient, because it auto generates tags for me, and I rely
" *heavily* on tags.
" We don't bother highlighting tags. Easytags also computes
" the tags asynchronously, because tag generation is slow otherwise.
let g:easytags_auto_highlight= 0
let g:easytags_async=1

" Opens the file under the cursor in an already existing buffer.
nnoremap <Leader>gf :let mycurf=expand("<cfile>")<CR><C-w>w:execute("e ".mycurf)<CR>

" Use the unix utility 'par' to handle paragraph formatting rather than Vim's
" built in utility.
"set formatprg=par

" Colors! My nemesis!
au ColorScheme * hi Error NONE
au ColorScheme * hi ErrorMsg NONE
au GuiEnter * hi Error NONE
au GuiEnter * hi ErrorMsg NONE

" Toggle on undo tree.
" This provides a nice visualization of vim's undo tree, and easy navigation
" of it, complete with diffs!
" I don't use it often, but when I do, it's *very* useful.
nnoremap <Leader>u :MundoToggle<CR>

" Toggle numbers. Mostly for working with others.
nnoremap <Space>n :set invnu<CR>

" Allows me to cycle forward/backward through these pairs using %, g% [%, ]%
" etc.
let b:match_words='\[:\],<:>,\(:\),{:}'

" Faster tabbing over without having to go into and out of normal mode
inoremap <S-Tab> <Tab><Tab>
inoremap 2<Tab> <Tab><Tab>
imap 3<Tab> <Tab>2<Tab>
imap 4<Tab> <Tab>3<Tab>
imap 5<Tab> <Tab>4<Tab>
imap 6<Tab> <Tab>5<Tab>
imap 7<Tab> <Tab>6<Tab>
imap 8<Tab> <Tab>7<Tab>
imap 9<Tab> <Tab>8<Tab>
" Indent to the same level as the previous line with text. There isn't any
" mnemonic for this, because it's optimized for typing speed and ease, since
" I'll be doing it often. Because I don't want the computer indenting for me.
  imap jk <Esc>?^\s*\S<CR>y^<c-o>Pa
" imap jk <Esc>k0y^jPa

" Allows me to jump to the start/end of a method definition in a class, since
" all methods are indented 4 spaces in the Java projects I work on.
au FileType java nnoremap [[ ?^    \S*}<CR>
au FileType java nnoremap ]] /^    \S*}<CR>
au FileType java vnoremap [[ ?^    \S*}<CR>
au FileType java vnoremap ]] /^    \S*}<CR>
au FileType java onoremap [[ ?^    \S*}<CR>
au FileType java onoremap ]] /^    \S*}<CR>

" Delete the current line, then paste it below the one we're on now.
nnoremap - ddp
" Delete the current line, then paste it above the one we're on now.
nnoremap _ ddkP
" Converts current word to uppercase.
inoremap <c-u> <Esc>viwUi
nnoremap <c-u> viwU<Esc>

" Abbreviations
iabbrev teh the

" Automatically replace double dashes with a single longer dash in prose.
augroup dash
    autocmd!
    au FileType yaml iabbrev -- &mdash
augroup END

" Automatically save when modifying text. I don't run anything expensive on
" write anymore (like Syntastic), so this won't inhibit me.
augroup auto_save
    autocmd!
    au InsertLeave *.* :w
    au TextChanged *.*  :w
augroup END

augroup java_include
    autocmd!
    au FileType java set include=^import\ \\zs.\\{-\\}\\ze;
    " Enable gf on import statements.  Convert . in the package
    " name to / and append .java to the name, then search the path.
    " Also allows using [i, but that's *way* too slow. Better off to write
    " a simple vim function that pulls out the list of tags, and then filters
    " using the below expression to convert imports to file paths.
    au FileType java set includeexpr=substitute(v:fname,'\\.','/','g')
    au FileType java set suffixesadd=.java
    au FileType java set path+=~/sources/*/src/main/java
    au FileType java set path+=~/fili/fili-core/src/main/java
    au FileType java set path+=src/main/java
augroup END

augroup java_make
    autocmd!
    " Just use make. Without any of these fancy neomake plugins or what-not.
    au FileType java set makeprg=mvn\ compile\ -q\ -f\ pom.xml
    " We want to print both errors and warnings.
    au FileType java set errorformat=[ERROR]\ %f:[%l\\,%v]\ %m,[ERROR]\ %f[%l:%v]\ %m,[ERROR]\%f[%l]\ %m,[WARNING]\ %f:[%l\\,%v]\ %m,[WARN]\ %f:[%l\\,%v]\ %m,%f:%l:%v:\ %m
    " ------------- Maven commands -----------
    au FileType java nnoremap <Leader>mc :! mvn clean<CR>
    " Test globally
    au FileType java nnoremap <Leader>mg :set makeprg=mvn\ -q\ test\ -f\ pom.xml<CR>:make<CR>:set makeprg=mvn\ compile\ -q\ -f\ pom.xml<CR>:copen<CR>
    au FileType java nnoremap <Leader>mcg :! mvn clean test<CR>
    " Test this file
    au FileType java nnoremap <Leader>mt :set makeprg=mvn\ test\ -q\ -Dcheckstyle.skip=true\ -Dtest=%:t:r\ -f\ pom.xml<CR>:make<CR>:set makeprg=mvn\ compile\ -q\ -f\ pom.xml<CR>:copen<CR>
augroup END

augroup java_search
    autocmd!
    " Find classes that implement this interface.
    au FileType java nnoremap <Leader>bi :Ack! --java "implements .*<C-R><C-W>"<CR>
    " Find classes that extend this class (i.e. subclasses).
    au FileType java nnoremap <Leader>bs :Ack! --java "extends .*<C-R><C-W>"<CR>
    " Find the class definition of the identifier under the cursor.
    au FileType java nnoremap <Leader>bc :Ack! --java "class <C-R><C-W>"<CR>
    " Jump to parent class identifier
    au FileType java nnoremap <Leader>p /\<extends\> \S*<CR>w
    " Jump to interface being implemented
    au FileType java nmap <Leader>i /\<implements\> \S*<CR>w
    " Jump to class declaration. The class declaration starts at the access modifier
    " that's fully indented to the left.
    au FileType java nmap <Leader>c ?^\(public\\|private\\|protected\\|class\)<CR>
augroup END


" We have some private things we need (like the URL for corporate
" git repos), but I don't feel comfortable putting in a public dot file.
source ~/.vim/private.vim

" Display the current file name.
nnoremap <space>f :echom @%<CR>

nnoremap <Leader>q :call QuickFixToggle()<CR>

let g:quickfix_is_open = 0

function! QuickFixToggle()
    if g:quickfix_is_open
        cclose
        let g:quickfix_is_open = 0
        execute g:quickfix_return_to_window . "wincmd w"
    else
        let g:quickfix_return_to_window = winnr()
        copen
        let g:quickfix_is_open = 1
    endif
endfunction

" Ask the user for which class to import, and appends the import to the import
" list. The next step is to put it in the correct spot alphabetically.
nnoremap <Leader>ai :call Import("<C-r><C-w>")<CR>
