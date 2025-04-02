#!/usr/bin/env bash
set -e

# Делаем скрипт исполняемым
chmod +x "$0"

# Определяем, какой терминал открыть
TERMINAL=""
if [[ -n "$KDE_FULL_SESSION" ]]; then
    TERMINAL="konsole -e"
elif [[ -n "$GNOME_DESKTOP_SESSION_ID" ]]; then
    TERMINAL="gnome-terminal --"
elif [[ "$XDG_CURRENT_DESKTOP" == *"XFCE"* ]]; then
    TERMINAL="xfce4-terminal -e"
elif [[ "$XDG_CURRENT_DESKTOP" == *"Cinnamon"* ]]; then
    TERMINAL="x-terminal-emulator -e"
elif [[ "$XDG_CURRENT_DESKTOP" == *"MATE"* ]]; then
    TERMINAL="mate-terminal -e"
fi

# Проверяем, определился ли терминал
if [[ -z "$TERMINAL" ]]; then
    echo "Ошибка: не удалось определить терминал."
    exit 1
fi

# Открываем терминал и выполняем скрипт в нем
$TERMINAL bash -c '
    set -e
    sudo pacman -Syy

    if pacman-key --list-keys | grep -q "3056513887B78AEB"; then
        echo "Chaotic AUR ключ уже установлен."
    else
        echo "Ключ Chaotic AUR не найден."
    fi

    if pacman -Qi chaotic-keyring &>/dev/null; then
        echo "Chaotic Keyring уже установлен."
    else
        echo "Chaotic Keyring не найден."
    fi

    if grep -q "\[chaotic-aur\]" /etc/pacman.conf && grep -q "Include = /etc/pacman.d/chaotic-mirrorlist" /etc/pacman.conf; then
        echo "Chaotic AUR уже установлен в /etc/pacman.conf."
    else
        read -p "Установить Chaotic AUR? (y/n): " INSTALL_CHAOTIC
        if [[ "$INSTALL_CHAOTIC" == "y" ]]; then
            sudo pacman-key --recv-key 3056513887B78AEB --keyserver keyserver.ubuntu.com
            sudo pacman-key --lsign-key 3056513887B78AEB
            sudo pacman -U "https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-keyring.pkg.tar.zst"
            sudo pacman -U "https://cdn-mirror.chaotic.cx/chaotic-aur/chaotic-mirrorlist.pkg.tar.zst"

            if ! grep -q "\[chaotic-aur\]" /etc/pacman.conf; then
                echo -e "\n[chaotic-aur]\nInclude = /etc/pacman.d/chaotic-mirrorlist" | sudo tee -a /etc/pacman.conf
            fi
            echo "Chaotic AUR успешно установлен."
        else
            echo "Установка Chaotic AUR отменена."
        fi
    fi

    echo "Chaotic AUR уже установлен."

    if ! pacman -Qi yay &>/dev/null; then
        sudo pacman -S yay --noconfirm
    else
        echo "yay уже установлен."
    fi

    if ! pacman -Qi onlyoffice-bin &>/dev/null; then
        yay -S onlyoffice-bin --noconfirm
    else
        echo "onlyoffice-bin уже установлен."
    fi

    if ! pacman -Qi visual-studio-code-bin &>/dev/null; then
        yay -S visual-studio-code-bin --noconfirm
    else
        echo "visual-studio-code-bin уже установлен."
    fi

    if ! pacman -Qi yandex-browser-corporate &>/dev/null; then
        yay -S yandex-browser-corporate --noconfirm
    else
        echo "yandex-browser-corporate уже установлен."
    fi

    read -p "Нажмите любую клавишу для выхода..."
'
