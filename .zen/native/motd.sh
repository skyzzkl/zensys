#!/usr/bin/env bash

motd() {
  get_term_width() {
    local cols=$(tput cols 2>/dev/null || echo 80)
    echo $((cols < 60 ? 60 : cols))
  }

  dynamic_divider() {
    local width=$(get_term_width)
    local div=""
    for ((i=0; i<width-2; i++)); do
      div+="─"
    done
    echo -e "${SEPARATOR}╰${div}${RESET}"
  }

  format_info() {
    local term_width=$(get_term_width)
    local label_fmt="%-14s"
    local max_val_len=$((term_width - 18))
    local val_trunc=$(echo "$2" | cut -c1-$max_val_len)
    printf "${LABEL}${label_fmt} ${VALUE}%s${RESET}\n" "$1" "$val_trunc"
  }

  header() {
    local width=$(get_term_width)
    if (( width >= 60 )); then
      echo -e "${TITLE}     ___       ___       ___       ___       ___       ___ ";
      echo -e "${TITLE}    /\  \     /\  \     /\__\     /\  \     /\__\     /\  \ ";
      echo -e "${TITLE}   _\:\  \   /::\  \   /:| _|_   /::\  \   |::L__L   /::\  \ ";
      echo -e "${TITLE}  /::::\__\ /::\:\__\ /::|/\__\ /\:\:\__\  |:::\__\ /\:\:\__\ ";
      echo -e "${TITLE}  \::;;/__/ \:\:\/  / \/|::/  / \:\:\/__/  /:;;/__/ \:\:\/__/ ";
      echo -e "${TITLE}   \:\__\    \:\/  /    |:/  /   \::/  /   \/__/     \::/  / ";
      echo -e "${TITLE}    \/__/     \/__/     \/__/     \/__/               \/__/ ";
      echo -e "${RESET}"
      echo -e "${TITLE}     ZENSYS${RESET}"
    else
      echo -e "${TITLE}     ZENSYS${RESET}"
    fi
  }

  clear

  header

  echo -e "\n${SEPARATOR}╭$(dynamic_divider)"
  echo -e "${SEPARATOR}│${TITLE}${BOLD} 󰒳 SYSTEM${RESET}"
  echo -e "${SEPARATOR}├$(dynamic_divider)"

  format_info "󰟀 HOST:" "$(whoami)@$(hostname 2>/dev/null || echo 'unknown')"
  echo -e "${SEPARATOR}│  $(dynamic_divider)"
  format_info "󰸗 DATE:" "$(date '+%Y-%m-%d %H:%M:%S' 2>/dev/null || echo 'unknown')"
  echo -e "${SEPARATOR}│  $(dynamic_divider)"
  format_info "󰅐 UPTIME:" "$(uptime -p 2>/dev/null | sed 's/up //' || echo 'unknown')"
  echo -e "${SEPARATOR}│  $(dynamic_divider)"
  format_info " SHELL:" "$(basename "$SHELL" 2>/dev/null || echo 'unknown')"
  echo -e "${SEPARATOR}│  $(dynamic_divider)"
  format_info " TERM:" "${COLUMNS:-$(tput cols)}x${LINES:-$(tput lines)}"
  echo -e "${SEPARATOR}│  $(dynamic_divider)"

  local pkg_count=$(pkg list-installed 2>/dev/null | wc -l | awk '{printf "%'"'"'d", $1}' || echo 0)
  format_info "󰏖 PKGS:" "$pkg_count"
  echo -e "${SEPARATOR}│  $(dynamic_divider)"

  echo -e "\n${SEPARATOR}├$(dynamic_divider)"
  echo -e "${SEPARATOR}│${TITLE}${BOLD} 󰍛 HARDWARE${RESET}"
  echo -e "${SEPARATOR}├$(dynamic_divider)"

  local disk_usage=$(df -h "$HOME" 2>/dev/null | awk 'NR==2 {print $3 "/" $2 " (" $5 ")"}' || echo "n/a")
  format_info "󰋊 STORAGE:" "$disk_usage"
  echo -e "${SEPARATOR}│  $(dynamic_divider)"

  echo -e "\n${SEPARATOR}├$(dynamic_divider)"
  echo -e "${SEPARATOR}│${TITLE}${BOLD} 󰀂 NETWORK${RESET}"
  echo -e "${SEPARATOR}├$(dynamic_divider)"

  local ip_address=$(ip a show wlan0 2>/dev/null | awk '/inet / {print $2}' | cut -d/ -f1 || echo "offline")
  format_info "󰩠 IPv4:" "${ip_address:-offline}"
  echo -e "${SEPARATOR}│  $(dynamic_divider)"

  echo -e "\n${SEPARATOR}├$(dynamic_divider)"
  echo -e "${SEPARATOR}│${TIP} 󰍜 Monitor: ${VALUE}htop ${TIP}  󰛳 Network: ${VALUE}netstat -tuln${RESET}"
  echo -e "${SEPARATOR}╰$(dynamic_divider)\n"
}