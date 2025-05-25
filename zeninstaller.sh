#!/data/data/com.termux/files/usr/bin/bash

download() { mkdir -p "$2"; curl -s "$1" | jq -c '.[]' | while read -r i; do n=$(echo $i | jq -r '.name'); p=$(echo $i | jq -r '.path'); t=$(echo $i | jq -r '.type'); u=$(echo $i | jq -r '.download_url'); if [[ $t == "file" ]]; then curl -s -L "$u" -o "$2/$n"; else download "https://api.github.com/repos/skyzzkl/zensys/contents/$p?ref=main" "$2/$n"; fi; done; }; download "https://api.github.com/repos/skyzzkl/zensys/contents/.zen?ref=main" "$HOME/.zen"


RESET='\033[0m'
BOLD='\033[1m'
TITLE='\033[38;5;85m'
LABEL='\033[38;5;120m'
VALUE='\033[38;5;158m'
SEPARATOR='\033[38;5;240m'
TIP='\033[38;5;245m'

CHECK="${LABEL}✔${RESET}"
CROSS="${LABEL}✕${RESET}"
ARROW="${LABEL}➜${RESET}"

# ========== CHECKS ========== #
TERMUX_DIR="$HOME/.termux"
CORE_SOURCE="$HOME/.zen/core.sh"
ZEN_DIR="$HOME/.zen/"
FONT_SOURCE="$HOME/.zen/native/font.ttf"
FONT_DEST="$TERMUX_DIR/font.ttf"

get_term_width() { tput cols 2>/dev/null || echo 80; }
separator() {
    local width=$(get_term_width)
    local div=""
    for ((i=0; i<width-2; i++)); do
      div+="─"
    done
    echo -e "${SEPARATOR}${div}${RESET}"
  }

section_title() {
  echo -e "\n${TITLE}${BOLD} $1 ${RESET}"
  separator
}

verify_resources() {
  section_title "Verificando Recursos"
  
  local missing=0
  for resource in "$FONT_SOURCE" "$CORE_SOURCE" "$TERMUX_DIR"; do
    if [ -e "$resource" ]; then
      echo -e "${CHECK} ${VALUE}${resource}${RESET}"
    else
      echo -e "${CROSS} ${LABEL}Ausente:${RESET} ${VALUE}${resource}${RESET}"
      missing=1
    fi
  done
  
  
  [ $missing -eq 0 ] || exit 1
}

# ========== DEPENDÊNCIAS ========== #
install_packages() {
  section_title "Instalando Dependências"
  
  echo -e "${ARROW} ${LABEL}Atualizando pacotes...${RESET}"
  pkg update -y > /dev/null 2>&1 && pkg upgrade -y > /dev/null 2>&1
  
  local deps=(gum termux-api bash coreutils git jq tree ncurses-utils which procps iproute2 nodejs fzf proot)
  echo -e "${ARROW} ${LABEL}Instalando:\n${RESET} ${VALUE}${deps[*]}${RESET}"
  pkg install -y "${deps[@]}" > /dev/null 2>&1
  
  if [ -n "$ZSH_VERSION" ]; then
    echo -e "${ARROW} ${LABEL}Configurando ZSH...${RESET}"
    plugins=(
      "fast-syntax-highlighting https://github.com/zdharma-continuum/fast-syntax-highlighting.git"
      "zsh-syntax-highlighting https://github.com/zsh-users/zsh-syntax-highlighting.git"
      "zsh-autosuggestions https://github.com/zsh-users/zsh-autosuggestions.git"
    )
    
    for item in "${plugins[@]}"; do
      plugin="${item%% *}"
      url="${item#* }"
      
      if [ ! -d "$ZEN_DIR/native/plugins/$plugin" ]; then
        git clone --depth 1 "$url" "$ZEN_DIR/native/plugins/$plugin"
      fi
    done
  fi
}

# ========== PREPARAÇÃO ========== #
system_prepare() {
  section_title "Preparando Ambiente"
  
  if [ -n "$ZSH_VERSION" ]; then
    echo -e "${ARROW} ${LABEL}Ativando plugins...${RESET}"
    plugins=(git)
    sed -i "/^plugins=/d" ~/.zshrc
    echo "plugins=(${plugins[*]})" >> ~/.zshrc
    if ! grep -q 'plugins zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting' "$CORE_SOURCE"; then
      echo '
    if [ -n "$ZSH_VERSION" ]; then
      plugins zsh-autosuggestions zsh-syntax-highlighting fast-syntax-highlighting
    fi
    ' >> "$CORE_SOURCE"
    fi
  fi
  
  echo -e "${ARROW} ${LABEL}Instalando fonte...${RESET}"
  mkdir -p "$TERMUX_DIR"
  mv -f "$FONT_SOURCE" "$FONT_DEST" 2>/dev/null || {
    echo -e "${CROSS} ${LABEL}Falha na instalação da fonte${RESET}"
    exit 1
  }
  
  echo -e "${ARROW} ${LABEL}Removendo motd...${RESET}"
  rm -rf "$PREFIX/etc/motd" 2>/dev/null
  
}

# ========== BOOTSTRAP ========== #
configure_shell() {
  section_title "Configurando Shell"
  
  local marker="# ZENSYS"
  local config="
  $marker
  if [ -f \"\$HOME/.zen/core.sh\" ]; then
    source \"\$HOME/.zen/core.sh\"
  else
    echo \"Zen não instalado corretamente\"
  fi"
  
  for shell_file in ~/.bashrc ~/.zshrc; do
    if [ -f "$shell_file" ]; then
      echo -e "${ARROW} ${LABEL}Configurando ${VALUE}${shell_file}${RESET}"
      grep -q "$marker" "$shell_file" || printf "\n%s\n" "$config" >> "$shell_file"
    fi
  done
  
  
}

# ========== MAIN ========== #
main() {
  clear
  download
  verify_resources
  echo -e ""
  echo -e ""
  install_packages
  echo -e ""
  echo -e ""
  system_prepare
  echo -e ""
  echo -e ""
  configure_shell
  
  echo -e "\n${TITLE}${BOLD} Instalação Concluída ${RESET}"
  echo -e "${TIP}Reinicie o terminal para aplicar as configurações${RESET}\n"
}

if [ "$(uname -o)" = "Android" ]; then
  main
else
  echo -e "${CROSS} ${LABEL}Este script requer o Termux (Android)${RESET}" >&2
  exit 1
fi
