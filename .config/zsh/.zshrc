#!/usr/bin/env sh
# https://github.com/nekwebdev/chocodots-template
# @nekwebdev
# LICENSE: GPLv3

# a few lines from Luke's config for the Zoomer Shell
HISTSIZE=10000000
SAVEHIST=10000000
HISTFILE=${XDG_CACHE_HOME}/zhistory

# some useful options (man zshoptions)
setopt appendhistory
setopt autocd extendedglob nomatch menucomplete
setopt interactive_comments
stty stop undef		# Disable ctrl-s to freeze terminal.
zle_highlight=('paste:none')

# beeping is annoying, remove it everywhere we can!
unsetopt BEEP

# check the effect
unsetopt PROMPT_SP

# basic auto/tab complete:
autoload -U compinit
zstyle ':completion:*' menu select
zmodload zsh/complist

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search

# colors
autoload -Uz colors && colors

# functions
source "${ZDOTDIR}/zsh-functions"

# normal files to source
zsh_add_file "zsh-aliases"

# themes and plugins, will clone from github, use username/repository format
# for more plugins: https://github.com/unixorn/awesome-zsh-plugins
zsh_add_plugin "Aloxaf/fzf-tab"
zsh_add_plugin "romkatv/powerlevel10k"
zsh_add_plugin "chrissicool/zsh-256color"
zsh_add_plugin "zsh-users/zsh-autosuggestions"
zsh_add_plugin "zsh-users/zsh-syntax-highlighting"
zsh_add_plugin "kazhala/dotbare"

# completions, will clone from github, use username/repository format
# zsh_add_completion "esc/conda-zsh-completion" false

# enable powerlevel10k instant prompt
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# fzf-tab module, only build it once
if [[ -f "${ZDOTDIR}/plugins/fzf-tab/modules/config.h.in" ]]; then
  [[ ! -f "${ZDOTDIR}/plugins/fzf-tab/modules/config.h" ]] && build-fzf-tab-module
fi

# disable sort when completing `git checkout`
zstyle ':completion:*:git-checkout:*' sort false
# set descriptions format to enable group support
zstyle ':completion:*:descriptions' format '[%d]'
# set list-colors to enable filename colorizing
zstyle ':completion:*' list-colors ${(s.:.)LS_COLORS}
# preview directory's content with exa when completing cd
zstyle ':fzf-tab:complete:cd:*' fzf-preview 'exa -1 --color=always $realpath'
# switch group using `,` and `.`
zstyle ':fzf-tab:*' switch-group ',' '.'

# add key-bindings
# examples:
# bindkey -s '^o' 'ranger^M'
# bindkey -s '^s' 'ncdu^M'
# bindkey -s '^n' 'nvim $(fzf)^M'
# bindkey -s '^v' 'nvim\n'
# bindkey -s '^f' 'zi^M'
bindkey -s '^z' 'zi^M'
bindkey '^[[P' delete-char
bindkey "^p" up-line-or-beginning-search # up
bindkey "^n" down-line-or-beginning-search # down
bindkey "^k" up-line-or-beginning-search # up
bindkey "^j" down-line-or-beginning-search # down
# remove key-bindings
bindkey -r "^u"
bindkey -r "^d"

# FZF 
[ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh
[ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
[ -f /usr/share/doc/fzf/examples/completion.zsh ] && source /usr/share/doc/fzf/examples/completion.zsh
[ -f /usr/share/doc/fzf/examples/key-bindings.zsh ] && source /usr/share/doc/fzf/examples/key-bindings.zsh
# [ -f ~/.fzf.zsh ] && source ~/.fzf.zsh

# activate completions
# change to `compinit` to get a check
compinit -u
_comp_options+=(globdots)		# include hidden files.
_dotbare_completion_cmd

eval "$(zoxide init --cmd cd zsh)"
