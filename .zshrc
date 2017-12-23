# Environmental Variables
export LANG=ja_JP.UTF-8
export EDITOR=/usr/local/bin/atom
export PATH=/usr/local/bin:$PATH
# export PATH=$HOME/.nodebrew/current/bin:$PATH
# export PATH=$HOME/.rbenv/bin:$PATH
# export PATH=$HOME/.exenv/bin:$PATH
# export PYENV_ROOT=$HOME/.pyenv
# export PATH=$PYENV_ROOT/bin:$PATH
# export PATH=/usr/local/Cellar/git/2.15.1/share/git-core/contrib/diff-highlight:$PATH
# if [ -x "`which go`" ]; then
#   export GOROOT=`go env GOROOT`
#   export GOPATH=$HOME/code/go-local
#   export PATH=$PATH:$GOROOT/bin:$GOPATH/bin
# fi
# eval "$(exenv init - zsh)"
# eval "$(rbenv init - zsh)"
# eval "$(pyenv init - zsh)"
# Load Color
autoload -Uz colors
colors
# setopt prompt_subst
####### option
setopt auto_cd
setopt auto_menu
setopt auto_param_keys
setopt auto_param_slash
setopt auto_pushd
setopt correct
setopt extended_glob
setopt nonomatch
setopt hist_ignore_all_dups
setopt hist_ignore_space
setopt hist_reduce_blanks
# Load Alias
if [ -f ~/.aliases ]; then
  . ~/.aliases
fi
# Shell Settings
setopt ignore_eof
setopt interactive_comments
setopt magic_equal_subst
setopt mark_dirs
setopt no_beep
setopt no_flow_control
setopt prompt_subst
setopt print_eight_bit
setopt pushd_ignore_dups
setopt share_history
# History
HISTFILE=~/.zsh_history
HISTSIZE=1000000
SAVEHIST=1000000
setopt extended_history
setopt HIST_IGNORE_SPACE
setopt HIST_FIND_NO_DUPS
setopt HIST_IGNORE_DUPS
setopt APPEND_HISTORY
chpwd() {
   ls_abbrev
}
ls_abbrev() {
   # -a : Do not ignore entries starting with ..
   # -C : Force multi-column output.
   # -F : Append indicator (one of */=>@|) to entries.
   local cmd_ls='ls'
   local -a opt_ls
   opt_ls=('-aCF' '--color=always')
   case "${OSTYPE}" in
       freebsd*|darwin*)
           if type gls > /dev/null 2>&1; then
               cmd_ls='gls'
           else
           fi
           ;;
   esac
   local ls_result
   ls_result=$(clicolor_force=1 columns=$columns command $cmd_ls ${opt_ls[@]} | sed $'/^\e\[[0-9;]*m$/d')
   echo "$ls_result"
}
bindkey -d
bindkey -e
gvim() {
  if [ $# -eq 0 ]; then
    open -a MacVim
  elif [ $# -eq 1 ]; then
  if [ ! -f "$1" ]; then
    touch "$1" || return 1
    fi
    touch -t $( date -v+1S +'%Y%m%d%H%M' ) ~/.compare
    open -a MacVim "$1" && {
      sleep 0.2
      if [ ~/.compare -ot "$1" ]; then
        [ ! -s "$1" ] && rm "$1"
        fi
        rm ~/.compare
      }
    else
      echo "$@: invalid arguments"
      return 1
      fi
      return 0
    }
[[ -s "/Users/yogoken/.gvm/scripts/gvm" ]] && source "/Users/yogoken/.gvm/scripts/gvm"
# gcloud
if [ -f '/Users/yogoken/google-cloud-sdk/path.zsh.inc' ]; then source '/Users/yogoken/google-cloud-sdk/path.zsh.inc'; fi
if [ -f '/Users/yogoken/google-cloud-sdk/completion.zsh.inc' ]; then source '/Users/yogoken/google-cloud-sdk/completion.zsh.inc'; fi

#propmt
function rprompt-git-current-branch {
  local name st color
  if [[ "$PWD" =~ '/\.git(/.*)?$' ]]; then
      return
  fi
  name=$(basename "`git symbolic-ref HEAD 2> /dev/null`")
  name=`git symbolic-ref HEAD 2>/dev/null | sed -E 's!refs/heads/!!'`
  if [[ -z $name ]]; then
      return
  fi
  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
      color=${fg[green]}
  elif [[ -n `echo "$st" | grep "^nothing added"` ]]; then
      color=${fg[yellow]}
  elif [[ -n `echo "$st" | grep "^# Untracked"` ]]; then
      color=${fg_bold[red]}
  else
      color=${fg[red]}
  fi
  echo "%{$color%}$name%{$reset_color%} "
}
# PROMPT='%(?.%B%F{green}.%B%F{blue})%(?!U^ｪ^U ﾜﾝ < !UTｪTU ｸｩﾝ < )%f%b'
PROMPT='%(?.%B%F{74}.%B%F{blue})%(?!( ੭ ˙ᗜ˙ )੭ < !(;^ω^%) < )%f%b'
RPROMPT='`rprompt-git-current-branch`%F{cyan}%~$f %F{white}[%*]%f'
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'
zstyle ':completion:*' list-colors 'di=34' 'ln=35' 'so=32' 'ex=31' 'bd=46;34' 'cd=43;34'


# export LSCOLORS=exfxcxdxbxegedabagacad
# export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31:bd=46;34:cd=43;34:su=41;30:sg=46;30:tw=42;30:ow=43;30'
# typeset -U chpwd_functions
# CD_HISTORY_FILE=${HOME}/.cd_history_file # cd 履歴の記録先ファイル
# function chpwd_record_history() {
#     echo $PWD >> ${CD_HISTORY_FILE}
# }
# chpwd_functions=($chpwd_functions chpwd_record_history)
# zle -N percol_cd_history
# zle -N percol_insert_history
# function percol_get_destination_from_history() {
#     sort ${CD_HISTORY_FILE} | uniq -c | sort -r | \
#         sed -e 's/^[ ]*[0-9]*[ ]*//' | \
#         sed -e s"/^${HOME//\//\\/}/~/" | \
#         percol | xargs echo
# }
# function percol_cd_history() {
#     local destination=$(percol_get_destination_from_history)
#     [ -n $destination ] && cd ${destination/#\~/${HOME}}
#     zle reset-prompt
# }
# function percol_insert_history() {
#     local destination=$(percol_get_destination_from_history)
#     if [ $? -eq 0 ]; then
#         local new_left="${LBUFFER} ${destination} "
#         BUFFER=${new_left}${RBUFFER}
#         CURSOR=${#new_left}
#     fi
#     zle reset-prompt
# }
# #
# # bindkey '^x;' percol_cd_history
# # bindkey '^xi' percol_insert_history
# # Peco
# alias -g B='`git branch | peco | sed -e "s/^\*[ ]*//g"`'
# zle -N peco-src
# zle -N peco-select-history
# zle -N peco-find-file
# zle -N peco-find
# bindkey '^]' peco-src
# bindkey '^r' peco-select-history
# bindkey '^q' peco-find-file
# bindkey '^f' peco-find
# function peco-src () {
#   local selected_dir=$(ghq list -p | peco --query "$LBUFFER")
#   if [ -n "$selected_dir" ]; then
#     BUFFER="cd ${selected_dir}"
#     zle accept-line
#   fi
#   zle clear-screen
# }
# function peco-select-history() {
#   BUFFER=$(fc -l -r -n 1 | peco --query "$LBUFFER")
#   CURSOR=$#BUFFER
#   zle redisplay
# }
# function peco-find-file() {
#   if git rev-parse 2> /dev/null; then
#       source_files=$(git ls-files)
#   else
#       source_files=$(find . -type f)
#   fi
#   selected_files=$(echo $source_files | peco --prompt "[find file]")
#   BUFFER="${BUFFER}${echo $selected_files | tr '\n' ' '}"
#   CURSOR=$#BUFFER
#   zle redisplay
# }
# function peco-find() {
#   local current_buffer=$BUFFER
#   local search_root=""
#   local file_path=""
#   if git rev-parse --is-inside-work-tree > /dev/null 2>&1; then
#     search_root=`git rev-parse --show-toplevel`
#   else
#     search_root=`pwd`
#   fi
#   file_path="$(find ${search_root} -maxdepth 5 | peco)"
#   BUFFER="${current_buffer} ${file_path}"
#   CURSOR=$#BUFFER
#   zle clear-screen
# }

export NVM_DIR="$HOME/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && \. "$NVM_DIR/nvm.sh"  # This loads nvm
[ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"  # This loads nvm bash_completion
