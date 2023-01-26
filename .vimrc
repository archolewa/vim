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

" I use git for backups.
set noswapfile
set nobackup

set nocp

execute pathogen#infect()

set tags=./tags,tags
set showfulltag

" Enables matchit, which provides for more sophisticated use of % for
" matching programming language constructs. Required for
" https://github.com/nelstrom/vim-textobj-rubyblock, which I'm using to
" have intelligent matching of lua blocks (which also terminate with the
" `end` keyword).
runtime macros/matchit.vim

if has('python3')
    silent! python3 1
endif

filetype indent plugin on
filetype on
filetype plugin on
" I find syntax highlighting to be unnecessary visual stimulation.
syntax off
set backspace=indent,eol,start
" Hide buffers instead of closing them. Means I don't have to save before
" switching?
set hidden
" I don't want my search results to be highlighted by default. For one thing,
" I use search in some of my navigation keybindings, and I don't want to have
" to invoke nohlsearch after each such binding, or pollute my screen with
" unnecessary highlights.
set nohlsearch
" The computer is not allowed to do things for me.
set nowrap
set ruler
set expandtab
set shiftwidth=4
set tabstop=4
set shiftround
set nofoldenable
set shortmess=atTWAI
set cmdheight=2
" Run a case insensitive search. By default, run case sensitive searches
nnoremap <Leader>/ /\c
set foldmethod=indent
set path=.,,~/tide-sources/java/**/,**
set incsearch
set splitright
" Disable all colors
" set t_Co=0
" Use :set list! to toggle the nonprinting characters.
set nolist
set listchars=eol:$,tab:>-,space:·

" Disable the completion popup. It's not really necessary, because there isn't
" (so far as I know) a way to jump directly to a match. If you need to cycle
" through them anyway, might as well cycle through them.
set completeopt=
set pumheight=1
" Not tag completing, because a bug in vim (or maybe Catalina) means that 
" vim doesn't recognize a tag as sorted, which slows down keyword completion.
" We can uncomment this when I pull down the latest vim and use that instead
" of the older homebrew version.
",t
set complete=.,b

" Turn off the status line.
set statusline+=%f:%l:%c;

" Turn off that awful highlighting in the quickfix window
hi QuickFixLine cterm=NONE ctermfg=grey ctermbg=black

" Turn off unnecessary localizations in diffview
let g:diff_translations = 0

"Repeating the previous find will be quite useful considering how often I
"rely on it, but ; is SOOO convenient as the leader key.
nnoremap - ;
let mapleader = ";"

set title

" Wrapping!
nnoremap <Leader>w :ArgWrap<CR>

" Search in current file
nnoremap <Leader>s :vimgrep <C-r>%<C-f><Esc>F<Space>a
" Search last visually selected block of text
nnoremap <Leader>/ /\%V
vnoremap / <Esc>/\%V

" ------- Code exploration ----------

" Cscope settings. Cscope lets us search for usages of a particular identifier.

"Some systemwide vimrc settings set cst. I don't *want* to use cscope for tags.
" For one thing, it opens an obnoxious dialogue box instead of just jumping to
" a tag when :tag is used.
set nocst
" Tells vim to build absolute paths from cscope's relative paths.
set cscoperelative

" Putting cscope results in quickfix, which is much friendlier than whatever
" it uses by default.
set cscopequickfix=s-,c-,d-,i-,t-,e-,a-

" Find all calls of a function. Yeah, I know the shortcut doesn't make any sense. It's
" a holdover from my IntelliJ days.
nnoremap <Leader>b :cs find c <cword><CR>
" Find all uses of this symbol.
nnoremap <Leader>c :cs find s <cword><CR>
" Find where the symbol under the cursor is assigned a value.
nnoremap <Leader>a :cs find a <cword><CR>
" Find files including this file. It's not perfect, it won't find files in the
" same package that use it for example, but it's something.
nnoremap <Leader>d :grep -l "^import .*<cword>;$" -r . -G .java<CR>

" Open the location list with all identifiers that match the tag under the
" cursor, without jumping to any of them.
nnoremap g] :ltag <C-R><C-W><CR>:lopen<CR><c-w>k<c-o><c-w>j

nnoremap <c-y> :tnext<cr>

" From a custom plugin I wrote that just keeps a stack of cursor positions
" that I can manually push to. Allows me to do nested searches and
" explorations and still jump back to where I wanted to be.
nnoremap <Space>p :Push<CR>
nnoremap <Space>o :Pop<CR>

" ----------- Grepping -------------------
set grepprg=rg\ --vimgrep\ --no-messages\ -g!.package-map\ -g!tags\ -g!cscope.*\ -g!*.class\ -g!.classpath\ -g!.raw-classpath\ -g!target\ -g!.git\ $*
set grepformat=%f:%l:%c:%m
" Don't print the output to the terminal screen. If I want that, I'll run it
" directly! This applies to both grep and make.
set shellpipe=&>

map <Leader>* :grep <cword><CR><CR><CR>

" ---------- Buffer management -----------
" Close current window, without actually closing the buffer. This gives me the
" ability to quickly open and close splits and what-not, while still being able
" to easily jump to the desired buffer.
nnoremap <space>d <C-w>c<CR>

"  Commands for navigating buffers and files.
" This puts the cursor in front of the double wildcards, instead of after.
" This makes it easy to wildcard inside a particular sub directory. Useful in
" large codebases.
nnoremap <Leader>f :find<Space>
nnoremap <Leader>e :e **/<Left><Left><Left>
nnoremap <C-e> :find <C-R><C-W><CR>
" Ignore class files when opening files.
set wildignore+=*.class
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
    let pos = getpos(".")
    %s/\s\+$//e
    call setpos(".", pos)
endfunction
command! Trim call TrimWhiteSpace()

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

" Don't render every keystroke of the macro, just the end result
set lazyredraw

" ----Completions ----
" The bindings have
" zero mnmemonic value, they're selected for being convenient to type.
" file completion
inoremap <c-h> <c-x><c-f>
" tag completion
inoremap <c-k> <c-x><c-]>
" semantic completion Want <c-l> for parenthesis completion, don't
" really use this much.
" inoremap <c-l> <c-x><c-o>
" keyword completion
inoremap <c-j> <c-p>

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
" Because I'm weird.
" inoremap jk <Esc>:let x=@/<CR>?^\s*\S<CR>"yy^<c-o>"yP:let @/=x<CR>a

" -------- Formatting --------
set nocindent
" Lets me find lines that are too long, without having to rely on colorcolumn.
command! LongLines /^.\{80\}

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
    au FileType qf syntax match qfFileName /\v^\/[^|]*\// transparent conceal
    au FileType qf command! HideFile :set concealcursor=n
    au FileType qf command! ShowFile :set concealcursor=
    au FileType qf command! Show :set conceallevel=0
    au FileType qf command! Hide :set conceallevel=2
    au BufLeave quickfix set conceallevel=0
    au BufLeave quickfix delcommand HideFile
    au BufLeave quickfix delcommand ShowFile
    au BufLeave quickfix delcommand Show
    au BufLeave quickfix delcommand Hide
augroup END

" Display the current file name.
nnoremap <space>f :echom @%<CR>

command! -nargs=1 InsertPath r!find ~/ -name <args>

" Filters the quickfix list down to entries whose body match the
" given pattern.
function! FilterQuickFix(pattern)
    let qflist = getqflist()
    let qflist = filter(qflist, 'match(v:val.text, a:pattern) >= 0')
    call setqflist(qflist)
endfunction

" Like FilterQuickFix, except filter based on the filename rather
" than entry body.
function! FilterQuickFixFile(pattern)
    let qflist = getqflist()
    let qflist = filter(qflist, 'match(bufname(v:val.bufnr), a:pattern) >= 0')
    call setqflist(qflist)
endfunction

command! -nargs=1 FilterQF call FilterQuickFix("<args>")
command! -nargs=1 FilterQFFile call FilterQuickFixFile("<args>")
nnoremap <Leader>q :FilterQF<Space>

" We have some private things we need (like the URL for corporate
" git repos), but I don't feel comfortable putting in a public dot file.
source ~/.vim/private.vim

command! Checkstyle ?^/Users

" Make it easier to pipe a line into the shell and replace it with the output.
nnoremap <C-s> !!bash<CR>

" Simple shortcut for generating open close parens.
inoremap <C-a> ()
inoremap <C-s> ()<Esc>i


