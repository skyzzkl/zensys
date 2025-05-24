#!/usr/bin/env bash
# core.sh - Script principal do Zen Shell
# Responsável por carregar tema e módulo MOTD e executar

set -uo pipefail

init=false
ZEN_HOME="${HOME}/.zen"
THEME="${ZEN_THEME:-default}"
THEME_PATH="${ZEN_HOME}/themes/${THEME}.theme"
MOTD_PATH="${ZEN_HOME}/native/motd.sh"
PROMPT_PATH="${ZEN_HOME}/native/prompt.sh"
DEBUG=${ZEN_DEBUG:-0}

log() {
  local level="$1"
  local msg="$2"
  if [[ "$level" == "ERROR" ]]; then
    >&2 echo -e "\033[1;31m[ERRO]\033[0m ${msg}"
  elif [[ "$level" == "INFO" && $DEBUG -eq 1 ]]; then
    echo -e "\033[1;34m[INFO]\033[0m ${msg}"
  fi
}

check_path() {
  local path="$1"
  local type="$2"
  if [[ "$type" == "file" && ! -f "$path" ]]; then
    log ERROR "Arquivo não encontrado: $path"
    exit 2
  elif [[ "$type" == "dir" && ! -d "$path" ]]; then
    log ERROR "Diretório não encontrado: $path"
    exit 3
  fi
}

plugins() {
  local parameters=$#
  for i in $(seq 1 $parameters); do
    local plugin_core="$ZEN_HOME/native/plugins/${1}/${1}.plugin.zsh"
    local plugin="$ZEN_HOME/native/plugins/${1}"
    
    check_path "$plugin" "dir"
    check_path "$plugin_core" "file"
    source "$plugin_core"
    
    shift
  done
}

main() {
  if [ "$init" = false ]; then
    init=true
    check_path "$ZEN_HOME" "dir"
    check_path "${ZEN_HOME}/themes" "dir"
    check_path "${ZEN_HOME}/native" "dir"
    check_path "$THEME_PATH" "file"
    check_path "$MOTD_PATH" "file"
    check_path "$PROMPT_PATH" "file"
  
    log INFO "Carregando tema '${THEME}'"
    source "$THEME_PATH"
  
    log INFO "Carregando módulo MOTD"
    log INFO "Carregando módulo PROMPT"
    source "$MOTD_PATH"
    source "$PROMPT_PATH"
  
    motd
    prompt
  fi
}; main


    if [ -n "$ZSH_VERSION" ]; then
      plugins zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting
    fi
    
