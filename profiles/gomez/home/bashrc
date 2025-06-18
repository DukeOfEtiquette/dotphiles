alias c='clear'
alias la='ls -a'
alias ll='ls -l'
alias p='cd ~/Documents/projects'
alias ap='cd ~/Documents/devStation'
alias d='cd ~/Desktop'
alias do='cd ~/Documents'
alias retm='tmux source-file ~/.tmux.conf'  #Reload tmux config file after change
alias tmux='TERM=screen-256color-bce tmux'
alias vim='/usr/local/bin/vim' # Use brew installed vim
alias dcp='~/.everc/dotfiles/tmuxSessions/dev-cpp'
alias fs='~/.everc/dotfiles/tmuxSessions/flip-server'
alias mysql='/usr/local/mysql/bin/mysql -u root -p'
alias chrome='open -a "Google Chrome"'
#alias vim='/Applications/MacVim.app/Contents/MacOS/Vim'
alias arduino='./Applications/Arduino.app/Contents/MacOS/Arduino'
alias sshrp='ssh -l pi proxy8.yoics.net -p 32808'
alias ho='heroku open'
alias class='cd ~/Documents/apprenti/bend-201d1'
alias eve='cd ~/.everc'
alias dc='cd ~/.everc/personal/devcascadia'

# git shortcuts
alias gs='git status'
alias gac='git commit -am'

# DevStation
alias cf201='cd ~/Documents/devStation/201/201d2'
alias cf301='cd ~/Documents/devStation/301'
alias cf401='cd ~/Documents/devStation/401'

# Coloring for ls
export CLICOLOR=1
export LSCOLORS=dxFxBxDxCxegedabagacad
alias ls='ls -Gh'

export PATH=/usr/local/bin:~/bin/*/:$PATH


[[ -s "$HOME/.rvm/scripts/rvm" ]] && source "$HOME/.rvm/scripts/rvm" # Load RVM into a shell session *as a function*

function color_my_prompt {
    local __user_and_host="\[\033[01;32m\]\u"
    local __cur_location="\[\033[01;34m\]\w"
    local __git_branch_color="\[\033[31m\]"
    #local __git_branch="\`ruby -e \"print (%x{git branch 2> /dev/null}.grep(/^\*/).first || '').gsub(/^\* (.+)$/, '(\1) ')\"\`"
    local __git_branch='`git branch 2> /dev/null | grep -e ^* | sed -E  s/^\\\\\*\ \(.+\)$/\(\\\\\1\)\ /`'
    local __prompt_tail="\[\033[35m\]$"
    local __last_color="\[\033[00m\]"
    export PS1="$__user_and_host $__cur_location $__git_branch_color$__git_branch$__prompt_tail$__last_color "
}
color_my_prompt
export PATH="/usr/local/opt/mongodb@3.4/bin:$PATH"
export PATH="/usr/local/opt/mongodb\@3.4/bin:$PATH"
export PATH="/Users/teacher/.ebcli-virtual-env/executables:$PATH"
export PATH="$HOME/.gem/ruby/2.6.0/bin:$PATH"
eval "$(rbenv init -)"
