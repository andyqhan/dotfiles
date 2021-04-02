
# Created by `userpath` on 2020-05-04 22:59:29
export PATH="$PATH:/Users/andyhan/.local/bin"


  # Set Spaceship ZSH as a prompt
  autoload -U promptinit; promptinit
  prompt spaceship

# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/Users/andyhan/miniconda3/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/Users/andyhan/miniconda3/etc/profile.d/conda.sh" ]; then
        . "/Users/andyhan/miniconda3/etc/profile.d/conda.sh"
    else
        export PATH="/Users/andyhan/miniconda3/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

# kitty config
autoload -Uz compinit
compinit
# completion for kitty
kitty + complete setup zsh | source /dev/stdin

# zsh-autosuggestions activation
source /usr/local/share/zsh-autosuggestions/zsh-autosuggestions.zsh

# zsh-syntax-highlighting activatation
source /usr/local/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

# add alias for gtri vpn script
alias gtri="~/gtri/gtrivpn.sh"