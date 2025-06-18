set nocompatible              " be iMproved, required
filetype off                  " required

" set the runtime path to include Vundle and initialize
" set rtp+=~/.vim/bundle/Vundle.vim
" call vundle#begin()

" alternatively, pass a path where Vundle should install plugins
"call vundle#begin('~/some/path/here')

" Syntax highlighting for slim templates
" Plugin 'slim-template/vim-slim.git'
" let Vundle manage Vundle, required
" Plugin 'VundleVim/Vundle.vim'
" Plugin 'Rip-Rip/clang_complete'

" Autocomplete, syntax highlighting
" https://github.com/vim-ruby/vim-ruby/wiki/VimRubySupport
" Bundle 'vim-ruby/vim-ruby'

" The following are examples of different formats supported.
" Keep Plugin commands between vundle#begin/end.
" plugin on GitHub repo
" Plugin 'scrooloose/nerdtree'
" plugin on GitHub repo
" Plugin 'tpope/vim-fugitive'
" plugin for checking syntax in code
" Plugin 'scrooloose/syntastic'

" plugin for swift syntax highlighting
" Plugin 'keith/swift.vim'
" plugin from http://vim-scripts.org/vim/scripts.html
"Plugin 'L9'
" Git plugin not hosted on GitHub
"Plugin 'git://git.wincent.com/command-t.git'
" git repos on your local machine (i.e. when working on your own plugin)
"Plugin 'file:///home/gmarik/path/to/plugin'
" The sparkup vim script is in a subdirectory of this repo called vim.
" Pass the path to set the runtimepath properly.
"Plugin 'rstacruz/sparkup', {'rtp': 'vim/'}
" Avoid a name conflict with L9
"Plugin 'user/L9', {'name': 'newL9'}

" plugin on GitHub repo
"Plugin 'Valloric/YouCompleteMe'

"Plugin 'rdnetto/YCM-Generator'

" All of your Plugins must be added before the following line
" call vundle#end()            " required
" filetype plugin indent on    " required
" To ignore plugin indent changes, instead use:
"filetype plugin on
"
" Brief help
" :PluginList       - lists configured plugins
" :PluginInstall    - installs plugins; append `!` to update or just :PluginUpdate
" :PluginSearch foo - searches for foo; append `!` to refresh local cache
" :PluginClean      - confirms removal of unused plugins; append `!` to auto-approve removal
"
" see :h vundle for more details or wiki for FAQ
" Put your non-Plugin stuff after this line

"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Personal Settings
"""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set relativenumber
set number
set smarttab
set expandtab
set shiftround
set backspace=indent,eol,start

" default tab spacing
setlocal ts=2 sts=2 sw=2

" Filetype specific tab spacing
autocmd Filetype swift,py,html setlocal ts=4 sts=4 sw=4

" let g:loaded_matchparen=1 " Turn off matching () highlighting

set encoding=utf8
" set clipboard=unnamed

syntax on

" Random key-maps
" map <F5> :w  <enter>
" map <F6> :q  <enter>
" map <F7> :wq <enter>
map <C-c> :s/^/\/\//<Enter>
map <C-u> :s/^\/\///<Enter>
