Installation and Usage
----------------------


# Advanced Linux User Management Script

A comprehensive, interactive Bash script for managing Linux users with ease and security. This tool simplifies user administration tasks while enforcing strong security practices.

## 🚀 Quick Installation & Usage

```bash
curl -fsSL -o users.sh https://raw.githubusercontent.com/diswebir/server-optimizer/main/users.sh
```
then run

```bash

sudo bash users.sh
```

## 📋 Features Overview

### 🔐 Enhanced Security
- Enforces strong password policies (min 8 characters with uppercase, lowercase, digits, and special characters)
- Automatic PAM configuration for password quality requirements
- Account locking/unlocking capabilities
- Forced password change on first login option

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

## 🎯 Key Benefits

1. **All-in-One Solution**: No need to remember multiple Linux commands
2. **Security First**: Built-in strong password enforcement and account security features
3. **User-Friendly**: Interactive prompts guide you through each process
4. **Safe Operations**: Confirmation prompts prevent accidental deletions
5. **Resource Monitoring**: Track user resource consumption directly from the interface
6. **Automatic Setup**: Checks and installs required dependencies

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