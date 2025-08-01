#!/bin/bash

# Script Name: Advanced Linux User Management Script by t.me/disreza
# Author: bash mackeer2 (Your Expert Linux Admin AI)
# Date: August 1, 2025
# Description: A comprehensive, interactive Bash script for managing Linux users,
#              including adding, deleting, editing, password management,
#              resource usage monitoring, and robust security features.

# --- Configuration & Global Variables ---
LOG_FILE="/var/log/user_management_script.log"
PAM_PASSWORD_CONFIG="/etc/pam.d/common-password"
REQUIRED_PACKAGES=("sudo" "ps" "grep" "awk" "sed" "du" "cut" "column" "useradd" "userdel" "usermod" "passwd" "lastlog" "chage" "pam_pwquality")

# --- Colors for Output ---0
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[0;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# --- Logging Function ---
log_action() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    local action="$1"
    echo -e "${timestamp} - ${action}" | sudo tee -a "${LOG_FILE}" > /dev/null
}

# --- Check for Root/Sudo Privileges ---
check_privileges() {
    if [[ "$EUID" -ne 0 ]]; then
        echo -e "${RED}Error: This script must be run with root privileges or using sudo.${NC}"
        echo -e "${YELLOW}Please run with: sudo ./$(basename "$0")${NC}"
        log_action "Attempted to run without sufficient privileges. Exiting."
        exit 1
    fi
}

# --- Check for essential commands/packages (NEW & IMPROVED) ---
check_dependencies() {
    echo -e "${BLUE}Checking for required packages...${NC}"
    local packages_to_install=()
    local apt_pkg=""

    for pkg in "${REQUIRED_PACKAGES[@]}"; do
        # Special handling for pam_pwquality since the package name is different on Debian/Ubuntu
        if [[ "$pkg" == "pam_pwquality" ]]; then
            # The actual package name is libpam-pwquality. Check for its presence using dpkg.
            if ! dpkg -s "libpam-pwquality" &>/dev/null; then
                 packages_to_install+=("libpam-pwquality")
            fi
        # For other commands, check if they exist in the PATH.
        elif ! command -v "$pkg" &>/dev/null; then
            packages_to_install+=("$pkg")
        fi
    done

    if [[ ${#packages_to_install[@]} -gt 0 ]]; then
        echo -e "${RED}The following required packages are not installed: ${NC}${packages_to_install[*]}${NC}"
        echo -ne "${BLUE}Do you want to install them now? (y/n): ${NC}"
        read -r install_choice

        if [[ "$install_choice" == "y" || "$install_choice" == "Y" ]]; then
            echo -e "${GREEN}Attempting to install missing packages...${NC}"
            sudo apt-get update
            if sudo apt-get install -y "${packages_to_install[@]}"; then
                echo -e "${GREEN}All missing packages installed successfully.${NC}"
            else
                echo -e "${RED}Error installing packages. Please check your internet connection or package sources.${NC}"
                log_action "Failed to install dependencies. Exiting."
                exit 1
            fi
        else
            echo -e "${YELLOW}Installation cancelled. The script cannot continue without these dependencies. Exiting.${NC}"
            log_action "Dependency installation cancelled. Exiting."
            exit 1
        fi
    fi
}

# --- Clear Screen Function ---
clear_screen() {
    clear
    echo -e "${BLUE}#################################################################${NC}"
    echo -e "${BLUE}#     Advanced Linux User Management Script by ${NC}${YELLOW}t.me/disreza    ${NC}${BLUE} #${NC}"
    echo -e "${BLUE}#################################################################${NC}"
    echo ""
}

# --- Pause Function ---
press_enter_to_continue() {
    echo -e "\n${YELLOW}Press Enter to continue...${NC}"
    read -r
}

# --- Get List of Non-System Users ---
get_users() {
    awk -F: '$3 >= 1000 && $7 != "/usr/sbin/nologin" && $7 != "/bin/false" {print $1}' /etc/passwd | sort
}

# --- Display List of Users (for selection) ---
display_users_for_selection() {
    local users=($(get_users))
    if [[ ${#users[@]} -eq 0 ]]; then
        echo -e "${RED}No regular users found on the system to manage.${NC}"
        return 1
    fi

    echo -e "${BLUE}Available Users:${NC}"
    local i=1
    for user in "${users[@]}"; do
        echo -e "  ${YELLOW}${i}.${NC} ${user}"
        i=$((i+1))
    done
    echo ""
    return 0
}

# --- PAM Configuration for Password Policy ---
configure_pam_password_policy() {
    echo -e "${BLUE}Configuring PAM password policy for strong passwords...${NC}"
    if [[ ! -f "${PAM_PASSWORD_CONFIG}.bak" ]]; then
        sudo cp "${PAM_PASSWORD_CONFIG}" "${PAM_PASSWORD_CONFIG}.bak"
        log_action "Backed up ${PAM_PASSWORD_CONFIG} to ${PAM_PASSWORD_CONFIG}.bak."
    fi

    if ! grep -q "pam_pwquality.so" "${PAM_PASSWORD_CONFIG}"; then
        sudo sed -i "/^password\s\+\[success=1 default=ignore]\s\+pam_unix.so/i password\trequisite\tpam_pwquality.so retry=3 minlen=8 difok=2 remember=5 ucredit=-1 lcredit=-1 dcredit=-1 ocredit=-1\n" "${PAM_PASSWORD_CONFIG}"
        log_action "Added pam_pwquality.so configuration in ${PAM_PASSWORD_CONFIG} for strong passwords."
        echo -e "${GREEN}PAM password policy configured successfully: Min 8 chars, requires upper/lower/digit/special.${NC}"
        echo -e "${YELLOW}Note: These changes directly modify system authentication files. A backup has been created at ${PAM_PASSWORD_CONFIG}.bak${NC}"
    else
        echo -e "${YELLOW}PAM password quality configuration already present or updated. Skipping direct modification.${NC}"
    fi
}

# --- PASSWORD VALIDATION FUNCTION ---
# This function checks if a password meets our security requirements.
validate_password() {
    local password="$1"
    if [[ ${#password} -lt 8 ]]; then
        return 1 # Too short
    fi
    if ! [[ "$password" =~ [[:lower:]] ]]; then
        return 1 # No lowercase
    fi
    if ! [[ "$password" =~ [[:upper:]] ]]; then
        return 1 # No uppercase
    fi
    if ! [[ "$password" =~ [[:digit:]] ]]; then
        return 1 # No digit
    fi
    if ! [[ "$password" =~ [[:punct:]] ]]; then
        return 1 # No special character
    fi
    return 0 # Valid password
}

# --- CORE FUNCTIONS (PHASE 2 & 3) ---

# Function to add a new user
add_user() {
    clear_screen
    echo -e "${BLUE}--- Add New User ---${NC}"
    log_action "Initiating 'Add User' process."
    
    local username password groups shell
    
    # 1. Get and validate username
    while true; do
        echo -ne "${BLUE}Enter new username: ${NC}"
        read -r username
        if [[ -z "$username" ]]; then
            echo -e "${RED}Error: Username cannot be empty.${NC}"
        elif [[ "$username" =~ [^a-zA-Z0-9_-] ]]; then
            echo -e "${RED}Error: Username can only contain letters, numbers, hyphens, and underscores.${NC}"
        elif sudo id -u "$username" &>/dev/null; then
            echo -e "${YELLOW}Warning: User '$username' already exists.${NC}"
            echo -ne "${YELLOW}Do you want to edit this user? (y/n)${NC}"
            read -r choice
            if [[ "$choice" == "y" || "$choice" == "Y" ]]; then
                edit_user "$username" # Pass username to edit function
                return
            else
                echo -e "${YELLOW}Please enter a different username.${NC}"
                continue
            fi
        else
            break
        fi
    done
    
    # 2. Get and validate password
    while true; do
        echo -ne "${BLUE}Enter password for the user: ${NC}"
        read -rs password
        echo "" # Newline for readability
        echo -ne "${BLUE}Confirm password: ${NC}"
        read -rs password_confirm
        echo "" # Newline for readability
        
        if [[ "$password" != "$password_confirm" ]]; then
            echo -e "${RED}Error: Passwords do not match.${NC}"
        elif ! validate_password "$password"; then
            echo -e "${RED}Error: Weak password. It must be at least 8 characters long and include upper/lower/digit/special characters.${NC}"
        else
            break
        fi
    done

    # 3. Set default shell to /bin/bash as requested
    local shell="/bin/bash"

    # 4. Choose secondary groups
    local all_groups=($(cut -d: -f1 /etc/group | sort))
    local selected_groups=""
    local group_choices=""
    
    echo -e "${BLUE}Select secondary groups for the user (by number):${NC}"
    echo -e "${YELLOW}(To select multiple groups, enter numbers separated by spaces, e.g.: 1 5 10)${NC}"
    
    local i=1
    for group in "${all_groups[@]}"; do
        # Add some descriptive text for common groups
        local description=""
        case "$group" in
            sudo) description=" - Grants root privileges" ;;
            docker) description=" - Allows Docker management" ;;
            www-data) description=" - Web server file access" ;;
            adm) description=" - Access to log files" ;;
        esac
        echo -e "  [${status}] ${YELLOW}${i}.${NC} ${group}${description}"
        i=$((i+1))
    done
    
    echo -ne "${BLUE}Enter the numbers of the groups to add/remove: ${NC}"
    read -r group_choices
    
    for choice in $group_choices; do
        if [[ "$choice" -ge 1 && "$choice" -le ${#all_groups[@]} ]]; then
            selected_groups+="${all_groups[$((choice-1))]},"
        fi
    done
    selected_groups=${selected_groups%,} # Remove trailing comma

    # 5. Force password change on first login
    local expire_password_flag="-e 1" # -e 1 forces password to be expired
    echo -ne "${BLUE}Should the user be forced to change their password on first login? (y/n)${NC}"
    read -r force_change_choice
    if [[ "$force_change_choice" == "n" || "$force_change_choice" == "N" ]]; then
        expire_password_flag=""
    fi
    
    # 6. Add the user
    local useradd_cmd="sudo useradd -m -s $shell"
    if [[ -n "$selected_groups" ]]; then
        useradd_cmd+=" -G $selected_groups"
    fi
    if [[ -n "$expire_password_flag" ]]; then
        useradd_cmd+=" $expire_password_flag"
    fi
    
    useradd_cmd+=" $username"
    
    if $useradd_cmd; then
        log_action "User '$username' added successfully."
        echo -e "${GREEN}User '$username' added successfully.${NC}"
        
        # Set password using passwd --stdin for better PAM integration
        echo "$username:$password" | sudo passwd --stdin "$username" &>/dev/null
        
        # Force password change if flag is set
        if [[ -n "$expire_password_flag" ]]; then
             sudo passwd --expire "$username" &>/dev/null
             echo -e "${YELLOW}User is forced to change password on first login.${NC}"
        fi
        
    else
        log_action "Error adding user '$username'."
        echo -e "${RED}Error: Failed to add user '$username'.${NC}"
    fi

    press_enter_to_continue
}

# Function to delete an existing user
delete_user() {
    clear_screen
    echo -e "${BLUE}--- Delete Existing User ---${NC}"
    log_action "Initiating 'Delete User' process."

    if ! display_users_for_selection; then
        press_enter_to_continue
        return
    fi
    
    local users=($(get_users))
    local user_choice
    echo -ne "${BLUE}Enter the number or username to delete: ${NC}"
    read -r user_choice
    
    local username_to_delete
    if [[ "$user_choice" =~ ^[0-9]+$ ]] && [[ "$user_choice" -ge 1 && "$user_choice" -le ${#users[@]} ]]; then
        username_to_delete="${users[$((user_choice-1))]}"
    else
        if sudo id -u "$user_choice" &>/dev/null; then
            username_to_delete="$user_choice"
        else
            echo -e "${RED}Error: Invalid username or number.${NC}"
            press_enter_to_continue
            return
        fi
    fi
    
    echo -e "${YELLOW}Warning: You are about to delete user '${username_to_delete}'. This action is irreversible.${NC}"
    echo -ne "${BLUE}Are you sure? (y/n) ${NC}"
    read -r confirm_delete

    if [[ "$confirm_delete" == "y" || "$confirm_delete" == "Y" ]]; then
        # Check if user is logged in
        if sudo who | grep -q "^${username_to_delete}"; then
            echo -e "${YELLOW}Warning: User '${username_to_delete}' is currently logged in.${NC}"
            echo -ne "${BLUE}Do you want to forcefully terminate all user processes and delete the user? (y/n) ${NC}"
            read -r force_delete_choice
            
            if [[ "$force_delete_choice" == "y" || "$force_delete_choice" == "Y" ]]; then
                echo -e "${RED}Forcefully terminating all user processes...${NC}"
                sudo pkill -KILL -u "${username_to_delete}"
                sleep 2
            else
                echo -e "${YELLOW}User deletion cancelled.${NC}"
                press_enter_to_continue
                return
            fi
        fi

        # Use userdel -r to remove home directory and mail spool
        if sudo userdel -r "${username_to_delete}"; then
            log_action "User '${username_to_delete}' deleted successfully."
            echo -e "${GREEN}User '${username_to_delete}' and all related files deleted successfully.${NC}"
        else
            log_action "Error deleting user '${username_to_delete}'."
            echo -e "${RED}Error: Failed to delete user. Please check the logs.${NC}"
        fi
    else
        echo -e "${YELLOW}User deletion cancelled.${NC}"
    fi

    press_enter_to_continue
}

# Function to view user information
view_user_info() {
    clear_screen
    echo -e "${BLUE}--- View User Information ---${NC}"
    log_action "Initiating 'View User Info' process."

    if ! display_users_for_selection; then
        press_enter_to_continue
        return
    fi
    
    local users=($(get_users))
    local user_choice
    echo -ne "${BLUE}Enter the number or username to view: ${NC}"
    read -r user_choice
    
    local username_to_view
    if [[ "$user_choice" =~ ^[0-9]+$ ]] && [[ "$user_choice" -ge 1 && "$user_choice" -le ${#users[@]} ]]; then
        username_to_view="${users[$((user_choice-1))]}"
    else
        if sudo id -u "$user_choice" &>/dev/null; then
            username_to_view="$user_choice"
        else
            echo -e "${RED}Error: Invalid username or number.${NC}"
            press_enter_to_continue
            return
        fi
    fi
    
    echo -e "\n${BLUE}User Information for '${username_to_view}':${NC}"
    echo "-------------------------------------"
    
    local user_info=$(sudo getent passwd "${username_to_view}")
    if [[ -n "$user_info" ]]; then
        local uid=$(echo "$user_info" | cut -d: -f3)
        local gid=$(echo "$user_info" | cut -d: -f4)
        local full_name=$(echo "$user_info" | cut -d: -f5 | cut -d, -f1)
        local home_dir=$(echo "$user_info" | cut -d: -f6)
        local shell=$(echo "$user_info" | cut -d: -f7)
        
        echo -e "${YELLOW}Username:${NC}       ${username_to_view}"
        echo -e "${YELLOW}UID:${NC}              ${uid}"
        echo -e "${YELLOW}GID:${NC}              ${gid}"
        echo -e "${YELLOW}Full Name:${NC}      ${full_name:-N/A}"
        echo -e "${YELLOW}Home Directory:${NC} ${home_dir}"
        echo -e "${YELLOW}Shell:${NC}          ${shell}"
    else
        echo -e "${RED}No information found for user '${username_to_view}'.${NC}"
        press_enter_to_continue
        return
    fi
    
    local groups=$(sudo groups "${username_to_view}")
    if [[ -n "$groups" ]]; then
        echo -e "${YELLOW}Groups:${NC}         ${groups}"
    fi

    local last_login=$(sudo lastlog -u "${username_to_view}" | tail -n 1 | awk '{print $4, $5, $6, $7, $8}')
    echo -e "${YELLOW}Last Login:${NC}      ${last_login:-Never logged in}"
    
    log_action "User information for '${username_to_view}' viewed."
    press_enter_to_continue
}

# --- IMPLEMENTATION OF PHASE 3 FUNCTIONS ---

# Function to edit an existing user
edit_user() {
    local username_to_edit="$1"
    if [[ -z "$username_to_edit" ]]; then
        clear_screen
        echo -e "${BLUE}--- Edit Existing User ---${NC}"
        log_action "Initiating 'Edit User' process."
        
        if ! display_users_for_selection; then
            press_enter_to_continue
            return
        fi
        
        local users=($(get_users))
        local user_choice
        echo -ne "${BLUE}Enter the number or username to edit: ${NC}"
        read -r user_choice
        
        if [[ "$user_choice" =~ ^[0-9]+$ ]] && [[ "$user_choice" -ge 1 && "$user_choice" -le ${#users[@]} ]]; then
            username_to_edit="${users[$((user_choice-1))]}"
        else
            if sudo id -u "$user_choice" &>/dev/null; then
                username_to_edit="$user_choice"
            else
                echo -e "${RED}Error: Invalid username or number.${NC}"
                press_enter_to_continue
                return
            fi
        fi
    fi

    clear_screen
    echo -e "${BLUE}--- Editing User: ${username_to_edit} ---${NC}"
    log_action "Editing user '${username_to_edit}'."

    while true; do
        echo -e "${GREEN}Select a property to edit:${NC}"
        echo -e "  ${YELLOW}1.${NC} Add/Remove Secondary Groups"
        echo -e "  ${YELLOW}2.${NC} Lock/Unlock Account"
        echo -e "  ${YELLOW}3.${NC} Change Account Expiration Date"
        echo -e "  ${YELLOW}4.${NC} Return to Main Menu"
        echo -ne "${BLUE}Enter your choice (1-4): ${NC}"
        read -r edit_choice
        
        case "$edit_choice" in
            1)
                local all_groups=($(cut -d: -f1 /etc/group | sort))
                local current_groups=$(sudo groups "${username_to_edit}" | cut -d: -f2 | sed 's/ /\n/g' | grep -v "^${username_to_edit}$")
                
                echo -e "${BLUE}Current secondary groups for '${username_to_edit}':${NC}"
                if [[ -z "$current_groups" ]]; then
                    echo -e "  (None)"
                else
                    echo -e "  ${YELLOW}${current_groups}${NC}"
                fi

                echo -e "${BLUE}Select groups to add/remove (by number):${NC}"
                echo -e "${YELLOW}(Enter numbers separated by spaces. To remove a group, deselect it.)${NC}"
                
                local i=1
                for group in "${all_groups[@]}"; do
                    local status=" "
                    if [[ " ${current_groups[@]} " =~ " ${group} " ]]; then
                        status="*"
                    fi
                    local description=""
                    case "$group" in
                        sudo) description=" - Grants root privileges" ;;
                        docker) description=" - Allows Docker management" ;;
                        www-data) description=" - Web server file access" ;;
                        adm) description=" - Access to log files" ;;
                    esac
                    echo -e "  [${status}] ${YELLOW}${i}.${NC} ${group}${description}"
                    i=$((i+1))
                done

                echo -ne "${BLUE}Enter the numbers of the groups to add/remove: ${NC}"
                read -r group_choices

                local new_groups=""
                for choice in $group_choices; do
                    if [[ "$choice" -ge 1 && "$choice" -le ${#all_groups[@]} ]]; then
                        new_groups+="${all_groups[$((choice-1))]},"
                    fi
                done
                new_groups=${new_groups%,}
                
                if [[ -n "$new_groups" ]]; then
                    sudo usermod -G "$new_groups" "${username_to_edit}"
                    log_action "User '${username_to_edit}' groups updated to: $new_groups"
                    echo -e "${GREEN}Groups for user '${username_to_edit}' have been updated.${NC}"
                else
                    sudo usermod -G "" "${username_to_edit}"
                    log_action "User '${username_to_edit}' groups cleared."
                    echo -e "${YELLOW}All secondary groups for user '${username_to_edit}' have been removed.${NC}"
                fi
                press_enter_to_continue
                ;;
            2)
                local lock_status=$(sudo passwd -S "${username_to_edit}" | awk '{print $2}')
                echo -e "${BLUE}Current account status for '${username_to_edit}': ${NC}${lock_status}${NC}"
                
                if [[ "$lock_status" == "P" ]]; then
                    echo -ne "${BLUE}Do you want to lock this account? (y/n) ${NC}"
                    read -r lock_choice
                    if [[ "$lock_choice" == "y" || "$lock_choice" == "Y" ]]; then
                        # Forcefully kill all processes for the user before locking
                        echo -e "${RED}Forcefully terminating all user processes...${NC}"
                        sudo pkill -KILL -u "${username_to_edit}" &>/dev/null
                        
                        sudo usermod -L "${username_to_edit}"
                        log_action "User '${username_to_edit}' account has been locked."
                        echo -e "${YELLOW}Account for '${username_to_edit}' has been locked.${NC}"
                    fi
                elif [[ "$lock_status" == "L" ]]; then
                    echo -ne "${BLUE}Do you want to unlock this account? (y/n) ${NC}"
                    read -r unlock_choice
                    if [[ "$unlock_choice" == "y" || "$unlock_choice" == "Y" ]]; then
                        sudo usermod -U "${username_to_edit}"
                        log_action "User '${username_to_edit}' account has been unlocked."
                        echo -e "${GREEN}Account for '${username_to_edit}' has been unlocked.${NC}"
                    fi
                else
                    echo -e "${YELLOW}Cannot determine lock status. Skipping.${NC}"
                fi
                press_enter_to_continue
                ;;
            3)
                echo -ne "${BLUE}Enter account expiration date (YYYY-MM-DD) or 'never' to remove: ${NC}"
                read -r expire_date
                
                if [[ "$expire_date" == "never" ]]; then
                    sudo chage -E -1 "${username_to_edit}"
                    log_action "Account for user '${username_to_edit}' set to never expire."
                    echo -e "${GREEN}Account for '${username_to_edit}' is now set to never expire.${NC}"
                elif [[ "$expire_date" =~ ^[0-9]{4}-[0-9]{2}-[0-9]{2}$ ]]; then
                    sudo chage -E "$expire_date" "${username_to_edit}"
                    log_action "Account for user '${username_to_edit}' set to expire on ${expire_date}."
                    echo -e "${GREEN}Account for '${username_to_edit}' will expire on ${expire_date}.${NC}"
                else
                    echo -e "${RED}Error: Invalid date format. Please use YYYY-MM-DD.${NC}"
                fi
                press_enter_to_continue
                ;;
            4)
                return
                ;;
            *)
                echo -e "${RED}Invalid choice. Please enter a number between 1 and 4.${NC}"
                press_enter_to_continue
                ;;
        esac
    done
}

# Function to change a user's password
change_password() {
    clear_screen
    echo -e "${BLUE}--- Change User Password ---${NC}"
    log_action "Initiating 'Change Password' process."

    if ! display_users_for_selection; then
        press_enter_to_continue
        return
    fi
    
    local users=($(get_users))
    local user_choice
    echo -ne "${BLUE}Enter the number or username to change password for: ${NC}"
    read -r user_choice
    
    local username_to_change
    if [[ "$user_choice" =~ ^[0-9]+$ ]] && [[ "$user_choice" -ge 1 && "$user_choice" -le ${#users[@]} ]]; then
        username_to_change="${users[$((user_choice-1))]}"
    else
        if sudo id -u "$user_choice" &>/dev/null; then
            username_to_change="$user_choice"
        else
            echo -e "${RED}Error: Invalid username or number.${NC}"
            press_enter_to_continue
            return
        fi
    fi

    local new_password new_password_confirm
    while true; do
        echo -ne "${BLUE}Enter new password for '${username_to_change}': ${NC}"
        read -rs new_password
        echo ""
        echo -ne "${BLUE}Confirm new password: ${NC}"
        read -rs new_password_confirm
        echo ""
        
        if [[ "$new_password" != "$new_password_confirm" ]]; then
            echo -e "${RED}Error: Passwords do not match.${NC}"
        elif ! validate_password "$new_password"; then
            echo -e "${RED}Error: Weak password. It must be at least 8 characters long and include upper/lower/digit/special characters.${NC}"
        else
            break
        fi
    done

    # Use passwd --stdin for better PAM integration
    if echo "$username_to_change:$new_password" | sudo passwd --stdin "$username_to_change" &>/dev/null; then
        log_action "Password for user '${username_to_change}' changed successfully."
        echo -e "${GREEN}Password for '${username_to_change}' changed successfully.${NC}"
    else
        log_action "Error changing password for user '${username_to_change}'."
        echo -e "${RED}Error: Failed to change password for '${username_to_change}'.${NC}"
    fi

    press_enter_to_continue
}

# Function to monitor user resource usage
monitor_user_resources() {
    clear_screen
    echo -e "${BLUE}--- Monitor User Resource Usage ---${NC}"
    log_action "Initiating 'Monitor User Resources' process."

    if ! display_users_for_selection; then
        press_enter_to_continue
        return
    fi
    
    local users=($(get_users))
    local user_choice
    echo -ne "${BLUE}Enter the number or username to monitor: ${NC}"
    read -r user_choice
    
    local username_to_monitor
    if [[ "$user_choice" =~ ^[0-9]+$ ]] && [[ "$user_choice" -ge 1 && "$user_choice" -le ${#users[@]} ]]; then
        username_to_monitor="${users[$((user_choice-1))]}"
    else
        if sudo id -u "$user_choice" &>/dev/null; then
            username_to_monitor="$user_choice"
        else
            echo -e "${RED}Error: Invalid username or number.${NC}"
            press_enter_to_continue
            return
        fi
    fi
    
    echo -e "\n${BLUE}Monitoring resource usage for '${username_to_monitor}'...${NC}"
    
    # Check for running processes and their resource usage
    local processes=$(ps -o pid,pcpu,pmem,cmd -u "${username_to_monitor}" --no-headers | column -t)
    
    if [[ -n "$processes" ]]; then
        echo -e "\n${YELLOW}Active Processes (CPU%, MEM%):${NC}"
        echo -e "${YELLOW}PID    %CPU  %MEM  COMMAND${NC}"
        echo -e "$processes"
    else
        echo -e "\n${YELLOW}No active processes found for '${username_to_monitor}'.${NC}"
    fi

    # Check for disk usage of home directory
    local home_dir=$(getent passwd "${username_to_monitor}" | cut -d: -f6)
    if [[ -d "$home_dir" ]]; then
        local disk_usage=$(sudo du -sh "$home_dir" 2>/dev/null | awk '{print $1}')
        echo -e "\n${YELLOW}Disk Usage:${NC}"
        echo -e "  Home directory (${home_dir}): ${disk_usage}"
    else
        echo -e "\n${YELLOW}Home directory for '${username_to_monitor}' not found.${NC}"
    fi

    log_action "Resource usage for user '${username_to_monitor}' monitored."
    press_enter_to_continue
}

# --- New sub-menu for user modification ---
modify_users_menu() {
    while true; do
        clear_screen
        echo -e "${GREEN}Select a modification option:${NC}"
        echo -e "  ${YELLOW}1.${NC} Add New User"
        echo -e "  ${YELLOW}2.${NC} Delete Existing User"
        echo -e "  ${YELLOW}3.${NC} Edit Existing User"
        echo -e "  ${YELLOW}4.${NC} Change User Password"
        echo -e "  ${YELLOW}5.${NC} Return to Main Menu"
        echo ""
        echo -ne "${BLUE}Enter your choice (1-5): ${NC}"
        read -r modify_choice

        case "$modify_choice" in
            1) add_user ;;
            2) delete_user ;;
            3) edit_user ;;
            4) change_password ;;
            5) return ;;
            *)
                echo -e "${RED}Invalid choice. Please enter a number between 1 and 5.${NC}"
                press_enter_to_continue
                ;;
        esac
    done
}


# --- Main Menu Function ---
main_menu() {
    while true; do
        clear_screen
        echo -e "${GREEN}Select an option:${NC}"
        echo -e "  ${YELLOW}1.${NC} Modify Users"
        echo -e "  ${YELLOW}2.${NC} View User Information"
        echo -e "  ${YELLOW}3.${NC} Monitor User Resource Usage"
        echo -e "  ${YELLOW}4.${NC} Exit"
        echo -e ""
        echo -ne "${BLUE}Enter your choice (1-4): ${NC}"
        read -r choice

        case "$choice" in
            1) modify_users_menu ;;
            2) view_user_info ;;
            3) monitor_user_resources ;;
            4)
                echo -e "${GREEN}Exiting script. Goodbye!${NC}"
                log_action "Script exited gracefully."
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid choice. Please enter a number between 1 and 4.${NC}"
                press_enter_to_continue
                ;;
        esac
    done
}

# --- Script Execution Flow ---
check_privileges
check_dependencies
configure_pam_password_policy
main_menu
