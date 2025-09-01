This directory contains the SSH setup automation script for macOS systems.

## Prerequisites

- macOS 10.14 (Mojave) or later
- Terminal with bash/zsh shell
- OpenSSH client (usually pre-installed)
- Write permissions to `~/.ssh/` directory

## Installation

### 1. Install OpenSSH (if not already installed)

**Option A: Xcode Command Line Tools (Recommended)**
```bash
xcode-select --install
```

**Option B: Homebrew**
```bash
# Install Homebrew first (if not installed)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install OpenSSH
brew install openssh
```

**Option C: Check if already installed**
```bash
ssh-keygen -V
```

### 2. Make the script executable
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
3. Let you choose SSH key type (RSA 4096-bit or Ed25519)
4. Let you select SSH server (GitHub, GitLab, etc. or custom)
5. Generate a new SSH key
6. Configure SSH settings
7. Display the public key for manual addition
8. Offer to copy the public key to clipboard (macOS feature)

### Example Session

```bash
$ ./setup-ssh.sh

================================
  SSH Setup Automation Script
================================

[INFO] macOS version detected: 13.2.1
[WARNING] Homebrew not found. It's recommended for managing packages on macOS.
Would you like to install Homebrew? (y/N):
N

Enter the account name/alias (e.g., github-personal, gitlab-work):
github-personal

Enter the email associated with this account:
user@example.com

[INFO] Selecting SSH key type...

Select SSH key type:
1) RSA 4096-bit (works almost everywhere)
2) Ed25519 (modern, faster, smaller)
Enter choice (1-2): 2

[INFO] Selected: ed25519
[INFO] Selecting SSH server...

Select the SSH server:
1) GitHub (github.com)
2) GitLab (gitlab.com)
3) Bitbucket (bitbucket.org)
4) SourceForge (git.code.sf.net)
5) Gitea (gitea.com)
6) Gogs (gogs.io)
7) Other server (custom)
Enter choice (1-7): 1

[INFO] Selected: github.com (user: git)
[INFO] Creating SSH directory...
[INFO] Backing up existing SSH config to /Users/user/.ssh/config.backup.20231201_143022
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

ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIE8rmvW0PTSF1yJL4ekV0VfihoNSm5lLWYIMSc9hXAuS user@example.com

================================
Setup complete!
Next steps:
1. Copy the public key above
2. Go to your account settings (GitHub/GitLab/etc.)
3. Add the SSH key to your account
4. Test the connection: ssh -T github-personal

Would you like to copy the public key to clipboard? (y/N):
y
[INFO] Public key copied to clipboard!
```

## Features

- **Interactive Setup**: Guided prompts for account information
- **SSH Key Type Selection**: Choose between RSA 4096-bit and Ed25519 keys
- **Interactive Host Selection**: Choose from popular SSH servers or add custom servers
- **Input Validation**: Validates email format and account names
- **Automatic Backup**: Backs up existing SSH config before modifications
- **SSH Agent Integration**: Automatically starts and configures SSH agent
- **Permission Management**: Sets proper file permissions for security
- **Error Handling**: Graceful error handling with informative messages
- **macOS Integration**: Clipboard support for easy key copying
- **Homebrew Detection**: Offers Homebrew installation if not found
- **Shell Profile Integration**: Automatically configures SSH agent persistence

## Account Name Examples

- `github-personal` - Personal GitHub account
- `github-work` - Work GitHub account
- `gitlab-company` - Company GitLab account
- `bitbucket-project` - Project-specific Bitbucket account
- `custom-server` - Custom SSH server

## Generated Files

The script creates the following files based on your key type selection:

**For RSA keys:**
- `~/.ssh/id_rsa_[account-name]` - Private SSH key
- `~/.ssh/id_rsa_[account-name].pub` - Public SSH key

**For Ed25519 keys:**
- `~/.ssh/id_ed25519_[account-name]` - Private SSH key
- `~/.ssh/id_ed25519_[account-name].pub` - Public SSH key

**Common:**
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

## Practical Usage Examples

### Git Operations with SSH Aliases

**Clone repositories using aliases:**
```bash
# Instead of: git clone git@github.com:username/repo.git
git clone git@github-personal:username/repo.git

# Instead of: git clone git@gitlab.com:company/project.git
git clone git@gitlab-company:company/project.git
```

**Add remote repositories:**
```bash
# Add GitHub personal remote
git remote add origin git@github-personal:username/repo.git

# Add GitLab work remote
git remote add work git@gitlab-company:company/project.git
```

**Push to different accounts:**
```bash
# Push to personal GitHub (uses github-personal key automatically)
git push origin main

# Push to work GitLab (uses gitlab-company key automatically)
git push work main
```

### Complete Workflow Example

```bash
# 1. Set up SSH keys for different accounts
./setup-ssh.sh  # Creates github-personal
./setup-ssh.sh  # Creates gitlab-work

# 2. Clone repositories
git clone git@github-personal:username/personal-project.git
git clone git@gitlab-company:company/work-project.git

# 3. Work on personal project
cd personal-project
git remote -v  # Shows: origin git@github-personal:username/personal-project.git
git push origin main  # Uses github-personal key automatically

# 4. Work on work project
cd ../work-project
git remote -v  # Shows: origin git@gitlab-company:company/work-project.git
git push origin main  # Uses gitlab-company key automatically
```

### Verifying Key Usage

```bash
# Check which keys are loaded in SSH agent
ssh-add -l

# Test with verbose SSH to see key selection
ssh -vT github-personal

# Test specific key directly
ssh -i ~/.ssh/id_rsa_github-personal -T git@github.com
```

## macOS-Specific Features

### Clipboard Integration
The script offers to copy the public key to the macOS clipboard using `pbcopy`, making it easy to paste into web forms.

### Shell Profile Detection
The script automatically detects and configures the appropriate shell profile:
- `.zshrc` (default on macOS Catalina+)
- `.bash_profile` (traditional macOS bash)
- `.bashrc` (fallback)

### Homebrew Integration
The script detects if Homebrew is installed and offers to install it if not found, providing easy package management.

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

5. **SSH Not Found**:
   ```bash
   # Install Xcode Command Line Tools
   xcode-select --install
   
   # Or install via Homebrew
   brew install openssh
   ```

### macOS Version Compatibility

- **macOS 10.14 (Mojave)**: Full support
- **macOS 10.15 (Catalina)**: Full support
- **macOS 11 (Big Sur)**: Full support
- **macOS 12 (Monterey)**: Full support
- **macOS 13 (Ventura)**: Full support
- **macOS 14 (Sonoma)**: Full support

### Shell Compatibility

- **zsh** (default since macOS Catalina): Full support
- **bash**: Full support
- **fish**: May require manual SSH agent configuration

## Security Notes

- SSH keys are generated with RSA 4096-bit encryption
- Private keys are protected with 600 permissions
- Public keys are set to 644 permissions
- SSH config is protected with 600 permissions
- The script creates automatic backups before modifications
- Clipboard content is automatically cleared after use

## Advanced Usage

### Using with Different Shells

If you're using a different shell (like fish), you may need to manually configure SSH agent persistence:

```bash
# For fish shell
echo 'eval (ssh-agent -c)' >> ~/.config/fish/config.fish
```

### Custom SSH Config Location

The script uses the standard SSH config location. If you need a custom location, modify the script or use symbolic links.

### Integration with Keychain

macOS Keychain can be used to store SSH key passphrases:

```bash
# Add to ~/.ssh/config
Host *
    AddKeysToAgent yes
    UseKeychain yes
    IdentityFile ~/.ssh/id_rsa_[account-name]
```

## Getting Help

If you encounter issues:
1. Check that OpenSSH is properly installed: `ssh-keygen -V`
2. Verify you have write permissions to `~/.ssh/`
3. Ensure the SSH agent is running: `ssh-add -l`
4. Check the SSH config syntax: `ssh -T [account-name]`
5. Review macOS Console for SSH-related errors 