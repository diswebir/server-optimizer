#!/bin/bash

# رنگ‌ها برای نمایش وضعیت
GREEN="\e[32m"
RED="\e[31m"
RESET="\e[0m"

# تابع افزودن کاربر ادمین
add_admin_user() {
    echo "Enter the username you want to create:"
    read username

    if id "$username" &>/dev/null; then
        echo -e "${RED}User '$username' already exists.${RESET}"
        return 1
    fi

    # ساخت کاربر
    if adduser "$username"; then
        echo -e "${GREEN}User '$username' created successfully.${RESET}"
    else
        echo -e "${RED}Failed to create user '$username'.${RESET}"
        return 1
    fi

    # افزودن دسترسی sudo با visudo
    echo "$username ALL=(ALL:ALL) ALL" | EDITOR='tee -a' visudo >/dev/null

    if sudo -l -U "$username" | grep -q "(ALL : ALL) ALL"; then
        echo -e "${GREEN}User '$username' is now an admin (sudoer).${RESET}"
    else
        echo -e "${RED}Failed to add '$username' to sudoers.${RESET}"
        return 1
    fi
}

# منوی اصلی
while true; do
    echo ""
    echo "لیست عملیات‌ها:"
    echo "1 - add admin user"
    echo "2 - add your pubkey to ssh keys"
    echo "3 - change ssh security"
    echo "4 - ufw"
    echo "5 - fail2ban"
    echo "0 - Exit"
    echo -n "گزینه مورد نظر را انتخاب کنید: "
    read choice

    case $choice in
        1) add_admin_user ;;
        0) echo "خروج..."; exit 0 ;;
        *) echo -e "${RED}گزینه نامعتبر است.${RESET}" ;;
    esac
done
