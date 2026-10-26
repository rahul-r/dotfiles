# History configuration
HISTFILE=${XDG_CONFIG_HOME}/zsh/zsh_history
HISTSIZE=50000
SAVEHIST=10000
## History command configuration
setopt extended_history       # record timestamp of command in HISTFILE
setopt hist_expire_dups_first # delete duplicates first when HISTFILE size exceeds HISTSIZE
setopt hist_ignore_dups       # ignore duplicated commands history list
setopt hist_ignore_space      # ignore commands that start with space
setopt hist_verify            # show command with history expansion to user before running it
setopt share_history          # share command history data

bindkey -e

# The following lines were added by compinstall
zstyle :compinstall filename '${XDG_CONFIG_HOME}/zsh/.zshrc'

autoload -Uz compinit
compinit
# End of lines added by compinstall

source ~/.aliases

source ${XDG_CONFIG_HOME}/zsh/completion.zsh
source ${XDG_CONFIG_HOME}/zsh/git.zsh

# ls colors
autoload -U colors && colors

# enable diff color if possible.
if command diff --color . . &>/dev/null; then
    alias diff='diff --color'
fi

setopt auto_cd
setopt multios
setopt prompt_subst

[[ -n "$WINDOW" ]] && SCREEN_NO="%B$WINDOW%b " || SCREEN_NO=""

ZSH_THEME_GIT_PROMPT_PREFIX="%{$fg_bold[blue]%}git:(%{$fg[red]%}"
ZSH_THEME_GIT_PROMPT_SUFFIX="%{$reset_color%} "
ZSH_THEME_GIT_PROMPT_DIRTY="%{$fg[blue]%}) %{$fg[yellow]%}✗"
ZSH_THEME_GIT_PROMPT_CLEAN="%{$fg[blue]%})"

PROMPT="%(?:%{$fg_bold[green]%}➜ :%{$fg_bold[red]%}➜ )"
PROMPT+=' %{$fg[cyan]%}%c%{$reset_color%} $(git_prompt_info)'

# Enable plugins
source ${XDG_CONFIG_HOME}/zsh/syntax-highlighting/zsh-syntax-highlighting.zsh
source ${XDG_CONFIG_HOME}/zsh/zsh-autosuggestions/zsh-autosuggestions.zsh

# The fzf shell scripts live in different directories per distribution, and
# `fzf --zsh` exists only from fzf 0.48.
if (( $+commands[fzf] )); then
  if fzf --zsh >/dev/null 2>&1; then
    source <(fzf --zsh)
  else
    for _fzf_shell_dir in \
      /usr/share/doc/fzf/examples \
      /usr/share/fzf \
      /usr/share/fzf/shell \
      /opt/homebrew/opt/fzf/shell \
      /usr/local/opt/fzf/shell \
      "$HOME/.fzf/shell"; do
      if [[ -r "$_fzf_shell_dir/key-bindings.zsh" ]]; then
        source "$_fzf_shell_dir/key-bindings.zsh"
        if [[ -r "$_fzf_shell_dir/completion.zsh" ]]; then
          source "$_fzf_shell_dir/completion.zsh"
        fi
        break
      fi
    done
  fi
  unset _fzf_shell_dir
fi

# Activate zoxide - this will replace the `cd` command
eval "$(zoxide init zsh --cmd cd)"

eval "$(starship init zsh)"

export DIRENV_LOG_FORMAT=
eval "$(direnv hook zsh)"

find_files() {
    selected=$(fzf)
 
    if [ -d "$selected" ]
    then
        cd "$selected"
    elif [ -f "$selected" ]
    then
        # Check if the file is a text file
        if file --mime-type "$selected" | grep -q text/
        then
            nvim "$selected"
        else
            # If it's not a text file, open it with the default program
            xdg-open "$selected"
        fi
    fi
}
bindkey -s "^P" 'find_files^M'
