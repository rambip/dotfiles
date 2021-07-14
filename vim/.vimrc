set relativenumber
set nu rnu
set smartindent
set expandtab
set shiftwidth=4
syntax on
set splitright
set ignorecase

" core mappings
map é <c-w>
map É <c-v>

" -> like D
map Y y$ 

map <c-s> :w<cr>
map s j
map S <Nop>
nnoremap <leader>S :setlocal spell spelllang=
nmap Z <Cmd>echo "à définir"<CR>
nmap <tab> gt

let mapleader=" "

map <leader>c <Cmd>wa\|make<CR>
map <leader>t <Cmd>wa\|split\|:te "make"<CR>

" remap c-c for yank and hide highlight
vmap <c-c> "+y
nmap <silent> <c-c> :noh<CR>

" TODO: 
command TmuxReplStart call system('tmux -f .tmux-repl.conf')| echo 'join session with "tmux a"'
command TmuxReplKill call system('tmux kill-session -t repl')

map Z !!tee -a /tmp/tmux-repl<cr>

" vim surround for vim-surround
let b:surround_84 = "\1Type: \1<\r>"



set runtimepath+=~/.vim/bundle/Vundle.vim
filetype off
call vundle#begin()

" Plugin manager
Plugin 'gmarik/Vundle.vim'

" extensions
Plugin 'tpope/vim-surround'
Plugin 'tpope/vim-repeat'

" languages
Plugin 'rust-lang/rust.vim'
Plugin 'elm-tooling/elm-vim'
Plugin 'LnL7/vim-nix'
Plugin 'edwinb/idris2-vim'

" Plugin 'kshenoy/vim-signature'
" Plugin 'numToStr/FTerm.nvim'
" Plugin 'tversteeg/registers.nvim'
" Plugin 'nvim-telescope/telescope.nvim'
" Plugin 'glacambre/firenvim'
" Plugin 'numToStr/Navigator.nvim'
" Plugin 'jghauser/kitty-runner.nvim'
" jbyuki/nabla.nvim
" b3nj5m1n/kommentary
" jbyuki/instant.nvim
" lunar vim
"Plugin tommcdo/vim-exchange
call vundle#end()
filetype on

