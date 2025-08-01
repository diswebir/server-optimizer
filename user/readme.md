Installation and Usage
----------------------


# Advanced Linux User Management Script

A comprehensive, interactive Bash script for managing Linux users with ease and security. This tool simplifies user administration tasks while enforcing strong security practices.

## 🚀 Quick Installation & Usage

```bash
curl -fsSL -o users.sh https://raw.githubusercontent.com/diswebir/server-optimizer/main/users.sh
```
### then run

```bash

sudo bash users.sh
```

## 📋 Features Overview

### 🔐 Enhanced Security Features

- **Password Policies**:
  - Minimum 8 characters
  - Requires uppercase, lowercase, digits, and special characters
  
- **PAM Integration**:
  - Automatic configuration for password quality requirements
  
- **Account Management**:
  - Locking/unlocking capabilities
  - Optional forced password change on first login


### 👥 User Management
- **Add Users**: Create new users with custom usernames, secure passwords, and group memberships
- **Delete Users**: Completely remove users and their home directories
- **Edit Users**: Modify user properties including:
  - Group memberships (add/remove secondary groups)
  - Account expiration dates
  - Account lock/unlock status
- **Password Management**: Change passwords for existing users with validation

### 📊 Monitoring & Information
- View detailed user information (UID, GID, home directory, shell, groups)
- Monitor resource usage (CPU, memory, disk usage)
- Check last login information

### 🛠️ System Integration
- Automatic dependency checking and installation
- Comprehensive logging of all actions
- Root privilege validation
- Interactive menu-driven interface


## ✨ Why Choose Our Linux User Management Tool?

Discover the ultimate solution for effortless Linux server administration with these powerful features:

🔹 **Complete All-in-One Toolkit**  
Simplify server management by replacing complex Linux commands with an intuitive interface - perfect for both beginners and experts

🔹 **Enterprise-Grade Security**  
Protect your system with automated password policies, secure account configurations, and built-in security best practices

🔹 **Intuitive Guided Interface**  
Step-by-step interactive menus eliminate guesswork and ensure successful operations every time

🔹 **Accident-Proof Design**  
Smart confirmation dialogs and safeguards prevent costly mistakes when managing sensitive user accounts

🔹 **Real-Time Resource Insights**  
Monitor disk usage, active processes, and system performance metrics at a glance

🔹 **Self-Configuring System**  
Automatic dependency checks and installations get you up and running in seconds


## 📖 How to Use

1. Run the script with sudo privileges
2. Navigate through the intuitive menu system
3. Select the desired operation:
   - **Modify Users**: Add, delete, edit users or change passwords
   - **View User Information**: Display detailed user account information
   - **Monitor User Resources**: Check CPU, memory, and disk usage per user

## 🛡️ Security Features

- Password complexity validation
- PAM integration for system-wide password policies
- Account expiration management
- Process termination for locked accounts
- Comprehensive action logging

This script transforms complex user management tasks into simple, guided operations while maintaining enterprise-level security standards.