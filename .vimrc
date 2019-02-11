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

" Enables matchit, which provides for more sophisticated use of % for
" matching programming language constructs. Required for
" https://github.com/nelstrom/vim-textobj-rubyblock, which I'm using to
" have intelligent matching of lua blocks (which also terminate with the
" `end` keyword).
runtime macros/matchit.vim

if has('python3')
    silent! python3 1
endif

" I don't like it when a computer tries to do things for me, I'd rather have
" custom mappings, like a mapping to duplicate the previous line's indent,
" to handle indenting. Otherwise, I find myself fighting the computer.
filetype indent plugin off
filetype on
filetype plugin on
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
set shiftround
set nofoldenable
colorscheme desert
highlight ColorColumn ctermbg=8
set shortmess=atTWAI
set cmdheight=2

" Run a case insensitive search. By default, run case sensitive searches
nnoremap <Leader>/ //c
set foldmethod=indent
set path=.,,
set incsearch
set splitright
" Disable all colors
" set t_Co=0
" Use :set list! to toggle the nonprinting characters.
set nolist

" Disable the completion popup. It's not really necessary, because there isn't
" (so far as I know) a way to jump directly to a match. If you need to cycle
" through them anyway, might as well cycle through them.
set completeopt=
set pumheight=1
set complete=.,b

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
nnoremap <Leader>w vi):s/,/,\r/g<CR>])i<CR><Esc>[(a<CR><Esc>vi)

" Search in current file (d is between s and f on
" my keyboard, i.e. 'search file'.
nnoremap <Leader>d :vimgrep <C-r>%<C-f><Esc>F<Space>a

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
set cscopequickfix=s-,c-,d-,i-,t-,e-

" At the end of each of these mappings we jump back to the previous jump,
" because cscope insists on jumping to the first match, and I don't want that.

" Find all uses of a symbol. Yeah, I know the shortcut doesn't make any sense. It's
" a holdover from my IntelliJ days.
nnoremap <Leader>b :cs find s <C-R>=expand("<cword>")<CR><CR>:copen<CR><c-w>k<c-o><c-w>j

" Open the location list with all identifiers that match the tag under the
" cursor, without jumping to any of them.
nnoremap g] :ltag <C-R><C-W><CR>:lopen<CR><c-w>k<c-o><c-w>j

nnoremap <c-y> :tnext<cr>

" ----------- Grepping -------------------
set grepprg=grep\ -n\ --exclude=tags\ --exclude=cscope.*\ --exclude=.classpath\ --exclude=.raw-classpath\ --exclude-dir=target\ --exclude-dir=.git\ $*
" Don't print the output to the terminal screen. If I want that, I'll run it
" directly! This applies to both grep and make.
set shellpipe=&>

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
    let pos = getpos(".")
    %s/\s\+$//e
    call setpos(".", pos)
endfunction
command! Trim call TrimWhiteSpace()

augroup trim
    autocmd!
    au BufWritePre * Trim
augroup END

" Should start using this instead of Caps Lock as escape, much more VM
" friendly.
inoremap jj <Esc>

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
" semantic completion
inoremap <c-l> <c-x><c-o>
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
inoremap jk <Esc>:let x=@/<CR>?^\s*\S<CR>"yy^<c-o>"yP:let @/=x<CR>a

" Automatically replace double dashes with a single longer dash in prose.
augroup dash
    autocmd!
    au FileType yaml iabbrev -- &mdash
augroup END

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

