if [[ $- != *i* ]]; then
    [[ -n "$SSH_CLIENT" ]] && source /etc/profile
    return
fi

source /etc/bashrc

# Prompt
source ~/.git-prompt.sh
GIT_PS1_SHOWDIRTYSTATE=1
GIT_PS1_SHOWUNTRACKEDFILES=1
GIT_PS1_SHOWUPSTREAM="auto"
prompt() {
    status="$?"
    user="\[\e[1;35m\]\u\[\e[00m\]"
    hostname="\[\e[1;35m\]\h\[\e[00m\]"
    directory="\[\e[1;34m\]\w\[\e[00m\]"
    git="$(__git_ps1 ' \[\e[1;36m\] %s\[\e[00m\]')"
    if [ -n "$GUIX_ENVIRONMENT" ]; then
        env=" \[\e[1;00m\][env]\[\e[00m\]"
    fi
    if [ "$status" = "0" ]; then
        indicator=" \[\e[1;32m\]$\[\e[00m\]"
    else
        indicator=" \[\e[1;31m\]$\[\e[00m\]"
    fi
    PS1="${user}@${hostname}:${directory}${git}${env}${indicator} "
}
PROMPT_COMMAND="prompt"

# Aliases
alias ls="ls -p --color=auto"
alias grep="grep --color=auto"
alias mv="mv --interactive"
alias cp="cp --interactive"
alias ln="ln --interactive"
alias cfg="git --git-dir $HOME/.cfg --work-tree $HOME"
