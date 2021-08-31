# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
# Initialization code that may require console input (password prompts, [y/n]
# confirmations, etc.) must go above this block; everything else may go below.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

SAVEHIST=1000  # Save most-recent 1000 lines
HISTFILE=~/.zsh_history

# Created by newuser for 5.8
# clone from git clone https://github.com/zsh-users/zsh-autosuggestions ~/.zsh/zsh-autosuggestions
source ~/powerlevel10k/powerlevel10k.zsh-theme
source ~/.zsh/git.plugin.zsh
source ~/.zsh/zsh-autosuggestions/zsh-autosuggestions.zsh
source ~/.zsh/colorize.plugin.zsh

# To customize prompt, run `p10k configure` or edit ~/.p10k.zsh.
[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

alias ll='ls -alF'
alias la='ls -A'
alias l='ls -CF'
export CLICOLOR=1
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"

cd /root/dcloud/phoenix_cloud/code/
alias tmux="TERM=screen-256color-bce tmux"
alias gstp="gst . -- ':!./src/devops' ':!./dockerbuild' ':!./src/roboCloud/roboLib/uploadlogslib/roboClientLogUtils.py' ':!./src/cportal/cportalserver/html/allrobocssfiles.html' ':!./src/cportal/cportalserver/html/robo_navigator.html'"

c() {
    if [ "$3" != "" ]
    then
        awk "NR==$1, NR==$2" $3
    else
        cat "$1"
    fi
}
