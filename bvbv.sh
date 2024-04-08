#!/bin/bash

# Проверяем, установлен ли Python
if ! command -v python3 &> /dev/null; then
    echo "Python не установлен. Установка Python..."
    sudo apt update
    sudo apt install python3 -y
fi

# Скачиваем ваш Python-скрипт
echo "Скачиваем ваш Python-скрипт..."
curl -O https://raw.githubusercontent.com/IIIAMANE/script/main/uwu.py

# Запускаем Python-скрипт
echo "Запускаем ваш Python-скрипт..."
python3 uwu.py
