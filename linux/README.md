# Linux SSH Setup Automation

This directory contains the SSH setup automation script for Linux systems.

## Prerequisites

- Linux distribution with bash shell
- OpenSSH client installed
- Write permissions to `~/.ssh/` directory

## Installation

1. **Install OpenSSH** (if not already installed):
   ```bash
   # Ubuntu/Debian
   sudo apt update
   sudo apt install openssh-client

   # CentOS/RHEL/Fedora
   sudo yum install openssh-clients
   # or
   sudo dnf install openssh-clients

   # Arch Linux
   sudo pacman -S openssh
   ```

2. **Make the script executable**:
   ```bash
   chmod +x setup-ssh.sh
   ```

## Usage

### Basic Usage

Run the script:
```bash
./setup-ssh.sh
```

The script will:
1. Prompt for an account name/alias
2. Ask for the associated email
3. Generate a new SSH key
4. Configure SSH settings
5. Display the public key for manual addition

### Example Session

```bash
$ ./setup-ssh.sh

================================
  SSH Setup Automation Script
================================

Enter the account name/alias (e.g., github-personal, gitlab-work):
github-personal

Enter the email associated with this account:
user@example.com

[INFO] Creating SSH directory...
[INFO] Backing up existing SSH config to /home/user/.ssh/config.backup.20231201_143022
[INFO] Generating SSH key for github-personal...
[INFO] Adding SSH config entry for github-personal...
[INFO] SSH config entry added successfully
[INFO] Setting up SSH agent...
[INFO] Starting SSH agent...
[INFO] Adding SSH key to agent...
[INFO] SSH agent setup complete

================================
  Your Public SSH Key
================================
Copy the following public key and add it to your account:

ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC... user@example.com

================================
Setup complete!
Next steps:
1. Copy the public key above
2. Go to your account settings (GitHub/GitLab/etc.)
3. Add the SSH key to your account
4. Test the connection: ssh -T github-personal
```

## Features

- **Interactive Setup**: Guided prompts for account information
- **Input Validation**: Validates email format and account names
- **Automatic Backup**: Backs up existing SSH config before modifications
- **SSH Agent Integration**: Automatically starts and configures SSH agent
- **Smart Host Detection**: Automatically detects GitHub/GitLab/Bitbucket based on account name
- **Permission Management**: Sets proper file permissions for security
- **Error Handling**: Graceful error handling with informative messages

## Account Name Examples

- `github-personal` - Personal GitHub account
- `github-work` - Work GitHub account
- `gitlab-company` - Company GitLab account
- `bitbucket-project` - Project-specific Bitbucket account
- `custom-server` - Custom SSH server

## Generated Files

The script creates the following files:
- `~/.ssh/id_rsa_[account-name]` - Private SSH key
- `~/.ssh/id_rsa_[account-name].pub` - Public SSH key
- `~/.ssh/config` - SSH configuration file (updated)

## SSH Config Structure

The script automatically adds entries to `~/.ssh/config`:

```
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github-personal
    IdentitiesOnly yes
```

## Testing the Setup

After running the script and adding the public key to your account:

```bash
# Test GitHub connection
ssh -T github-personal

# Test GitLab connection
ssh -T gitlab-company

# Test Bitbucket connection
ssh -T bitbucket-project
```

## Troubleshooting

### Common Issues

1. **Permission Denied**:
   ```bash
   chmod 700 ~/.ssh
   chmod 600 ~/.ssh/config
   chmod 600 ~/.ssh/id_rsa_*
   chmod 644 ~/.ssh/id_rsa_*.pub
   ```

2. **SSH Agent Not Running**:
   ```bash
   eval "$(ssh-agent -s)"
   ssh-add ~/.ssh/id_rsa_[account-name]
   ```

3. **Key Already Exists**:
   - The script will prompt to overwrite existing keys
   - Choose 'y' to overwrite or 'N' to cancel

4. **Invalid Account Name**:
   - Use only letters, numbers, hyphens, and underscores
   - Examples: `github-personal`, `gitlab_work`, `bitbucket123`

### Getting Help

If you encounter issues:
1. Check that OpenSSH is properly installed
2. Verify you have write permissions to `~/.ssh/`
3. Ensure the SSH agent is running
4. Check the SSH config syntax: `ssh -T [account-name]`

## Security Notes

- SSH keys are generated with RSA 4096-bit encryption
- Private keys are protected with 600 permissions
- Public keys are set to 644 permissions
- SSH config is protected with 600 permissions
- The script creates automatic backups before modifications 