export JAVA_HOME=/Library/Java/JavaVirtualMachines/jdk-11.jdk/Contents/Home
export PATH=$JAVA_HOME/bin:$PATH:
export PATH="/opt/homebrew/bin:$PATH"
export PATH="$HOME/miniconda3/bin:$PATH"


# >>> conda initialize >>>
# !! Contents within this block are managed by 'conda init' !!
__conda_setup="$('/opt/homebrew/Caskroom/miniconda/base/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
if [ $? -eq 0 ]; then
    eval "$__conda_setup"
else
    if [ -f "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh" ]; then
        . "/opt/homebrew/Caskroom/miniconda/base/etc/profile.d/conda.sh"
    else
        export PATH="/opt/homebrew/Caskroom/miniconda/base/bin:$PATH"
    fi
fi
unset __conda_setup
# <<< conda initialize <<<

export PATH=$HOME/edirect:${PATH}
export PATH="/opt/homebrew/opt/ruby/bin:$PATH"
export PATH="$HOME/.local/bin:$PATH"

# Oh My Zsh — Agnoster (powerline-style) theme
# Use a Nerd Font or Powerline font in the terminal (e.g. MesloLGS Nerd Font) so symbols render correctly
export ZSH="$HOME/.oh-my-zsh"
ZSH_THEME="agnoster"
# Hide user@host when the login user matches (cleaner on your own machine)
export DEFAULT_USER="${USER}"
plugins=(git)
source $ZSH/oh-my-zsh.sh
