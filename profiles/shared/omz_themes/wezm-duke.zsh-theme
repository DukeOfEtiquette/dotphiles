PROMPT='<%n> $(git_prompt_info)%(?,,%{${fg_bold[white]}%}[%?]%{$reset_color%} )%{$FG[226]%}$%{$reset_color%} '
RPROMPT='%{$fg[green]%}%~%{$reset_color%}'

ZSH_THEME_GIT_PROMPT_PREFIX="%{$FG[178]%}("
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_DIRTY="%{$FG[178]%})%{$FG[red]%}⚡%{$reset_color%}"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$FG[178]%})"
