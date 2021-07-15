
# If not running interactively, don't do anything
[[ $- != *i* ]] && return


HISTCONTROL=ignoreboth # wtf ?
HISTSIZE=
HISTFILESIZE=


PS1='\[\033[01;32m\]rambi\[\033[00m\] \[\033[01;34m\]\w \$\[\033[00m\] '



# couleurs pour grep
alias grep='grep --color=auto'
alias ls='ls --color=auto'


#        _           
# __   _(_)_ __ ___  
# \ \ / / | '_ ` _ \ 
#  \ V /| | | | | | |
#   \_/ |_|_| |_| |_|
#                    


alias vi=nvim
alias c=clear

alias ssh="env TERM=xterm-256color ssh"

#ignore upper and lowercase when TAB completion
bind "set completion-ignore-case on"

set -o vi

# fetcher
macchina 
