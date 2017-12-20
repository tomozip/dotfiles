eval "$(rbenv init -)"

fpath=($(brew --prefix)/share/zsh/site-functions $fpath)

autoload -U compinit
compinit

# $ prompt [prompt名]
autoload -U promptinit
promptinit

# prompt
# (color_code): https://qiita.com/tmd45/items/226e7c380453809bc62a
# (setting):    http://raichel.hatenablog.com/entry/2015/08/16/225536
setopt prompt_subst
zstyle ':vcs_info:*' formats '%F{59}(%f%F{183}%b%f%F{59})%f'
zstyle ':vcs_info:*' actionformats '[%F{green}%b%f(%F{red}%a%f)]'
# precmd() { vcs_info }

PROMPT='%F{60}[%f%F{74}%n@%m%f%F{60}]%f${vcs_info_msg_0_}
%(?.%B%F{74}.%B%F{blue})%(?!( ੭ ˙ᗜ˙ )੭ < !(;^ω^%) < )%f%b'
RPROMPT='%F{50}%~%f'
