set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath = &runtimepath
source ~/.vimrc

" Include coc configuration
source ~/.config/nvim/coc.vim
