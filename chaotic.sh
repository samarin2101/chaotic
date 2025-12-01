#!/bin/bash
# chaotic.ch — автоматическая установка Chaotic-AUR с проверкой

KEY_ID="3056513887B78AEB"
CONF_FILE="/etc/pacman.conf"
MIRROR_FILE="/etc/pacman.d/chaotic-mirrorlist"

# Проверка, установлен ли Chaotic-AUR
if pacman-key --list-keys | grep -q "$KEY_ID" && \
   grep -q "\[chaotic-aur\]" "$CONF_FILE" && \
   [[ -f "$MIRROR_FILE" ]]; then
  echo "Chaotic установлен"
  exit 0
fi

echo "==> Импорт ключей Chaotic-AUR..."
sudo pacman-key --recv-key $KEY_ID --keyserver keyserver.ubuntu.com
sudo pacman-key --lsign-key $KEY_ID

echo "==> Установка ключей и зеркал Chaotic-AUR..."
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst'
sudo pacman -U --noconfirm 'https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst'

echo "==> Добавление репозитория в $CONF_FILE..."
if ! grep -q "\[chaotic-aur\]" "$CONF_FILE"; then
  echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a "$CONF_FILE" > /dev/null
  echo "Репозиторий Chaotic-AUR добавлен."
fi

echo "==> Обновление баз пакетов..."
sudo pacman -Syy

echo "==> Установка Chaotic-AUR завершена!"
