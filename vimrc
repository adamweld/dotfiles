" Dotfiles
" 29 Oct 2014 (Wed)

"start pathogen plugin manager
execute pathogen#infect()
call pathogen#helptags()

"quick window switching
map <C-J> <C-W>j<C-W>_
map <C-K> <C-W>k<C-W>_

" Leader
let mapleader = " "

set ruler         " show the cursor position all the time
set showcmd       " display incomplete commands
set mouse=a
set mousehide     " Hide the mouse cursor while typing
set ttyfast
set incsearch     " do incremental searching
set autowrite     " Automatically :write before running commands
set shortmess+=filmnrxoOtT
set history=1000
"set spell
set hidden
set backupdir=~/.vim/backup//
set directory=~/.vim/swp//

" Numbers
set number
set numberwidth=5


" Softtabs, 2 spaces
set tabstop=2
set shiftwidth=2
set shiftround
set expandtab

" Display extra whitespace
set list listchars=tab:»·,trail:·

" Use The Silver Searcher https://github.com/ggreer/the_silver_searcher
if executable('ag')
  " Use Ag over Grep
  set grepprg=ag\ --nogroup\ --nocolor

  " Use ag in CtrlP for listing files. Lightning fast and respects
  "       .gitignore
  let g:ctrlp_user_command = 'ag %s -l --nocolor -g ""'

  " ag is fast enough that CtrlP doesn't need to cache
  let g:ctrlp_use_caching = 0
endif

" Color scheme
"colorscheme github
"set background=dark
highlight NonText guibg=#060606
highlight Folded  guibg=#0A0A0A guifg=#9090D0

" Tab completion
" will insert tab at beginning of line,
" will use completion if not at beginning
set wildmode=list:longest,list:full
function! InsertTabWrapper()
  let col = col('.') - 1
  if !col || getline('.')[col - 1] !~ '\k'
    return "\<tab>"
  else
    return "\<c-p>"
  endif
endfunction
inoremap <Tab> <c-r>=InsertTabWrapper()<cr>
inoremap <S-Tab> <c-n>

syntax on

set laststatus=2

"vim-airline
let g:airline_powerline_fonts = 1
let g:airline_theme             = 'powerlineish'
let g:airline_enable_syntastic  = 1

" Switch between the last two files
nnoremap <leader><leader> <c-^>

nnoremap <Left> :echoe "Use h"<CR>
nnoremap <Right> :echoe "Use l"<CR>
nnoremap <Up> :echoe "Use k"<CR>
nnoremap <Down> :echoe "Use j"<CR>

"folding settings
"set foldmethod=indent   "fold based on indent
set foldmethod=syntax
set foldnestmax=10      "deepest fold is 10 levels
set nofoldenable        "dont fold by default
set foldlevel=1         "this is just what i use

"text expansion
iab <expr> dts strftime("%-d %b %Y (%a)")
