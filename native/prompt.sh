#!/usr/bin/env bash

prompt() {
  if [ "$(basename "$SHELL")" = "zsh" ]; then
    autoload -Uz vcs_info
    add-zsh-hook precmd vcs_info
    zstyle ':vcs_info:*' enable git
    zstyle ':vcs_info:git:*' formats "${SEPARATOR}(${VALUE}git:%b${SEPARATOR})-"
    typeset -g RPROMPT=""
    for i in {1..100}; do
      typeset -g RPS$i=""
    done
    precmd() {
      vcs_info
      PROMPT="%{${SEPARATOR}%}┌──${vcs_info_msg_0_}%{${SEPARATOR}%}(%{${VALUE}%}%n@%m%{${SEPARATOR}%})-[%{${VALUE}%}%~%{${SEPARATOR}%}]
%{${LABEL}%}$ %{${RESET}%}"
    }

  else
    parse_git_branch() {
      git branch 2>/dev/null | grep '^*' | sed 's/* //'
    }
    set_prompt() {
      local branch=$(parse_git_branch)
      local git_part=""
      [[ -n "$branch" ]] && git_part="${SEPARATOR}(${VALUE}git:${branch}${SEPARATOR})-"
      PS1="\n${SEPARATOR}┌──${git_part}${SEPARATOR}(${VALUE}\u@\h${SEPARATOR})-[${VALUE}\w${SEPARATOR}]\n${LABEL}\$ ${RESET}"
    }
    PROMPT_COMMAND=set_prompt
  fi
}

# Definir variáveis de estilo (ESSENCIAIS - ajuste conforme seu tema)
SEPARATOR=$'\e[38;5;240m'  # Cinza escuro
VALUE=$'\e[38;5;158m'      # Ciano claro
LABEL=$'\e[38;5;120m'      # Verde água
RESET=$'\e[0m'             # Resetar estilo