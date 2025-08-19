# SSH Configuration Guide

This guide explains the SSH configuration concepts used in the SSH setup automation scripts. It's designed for users who want to understand how SSH works and how the automation scripts configure SSH for multiple accounts.

## Table of Contents

1. [What is SSH?](#what-is-ssh)
2. [SSH Key Authentication](#ssh-key-authentication)
3. [SSH Configuration Files](#ssh-configuration-files)
4. [Understanding SSH Config Entries](#understanding-ssh-config-entries)
5. [How Multiple SSH Keys Work](#how-multiple-ssh-keys-work)
6. [SSH Agent and Key Management](#ssh-agent-and-key-management)
7. [Security Best Practices](#security-best-practices)
8. [Troubleshooting SSH Config](#troubleshooting-ssh-config)

## What is SSH?

**SSH (Secure Shell)** is a cryptographic network protocol for secure communication between computers. It's commonly used for:

- **Secure remote access** to servers
- **Git operations** (clone, push, pull)
- **File transfers** (SCP, SFTP)
- **Tunneling** and port forwarding

### SSH vs HTTPS for Git

| Method | Pros | Cons |
|--------|------|------|
| **SSH** | ✅ No password prompts<br>✅ More secure<br>✅ Works with multiple accounts | ❌ Requires key setup<br>❌ More complex initial setup |
| **HTTPS** | ✅ Simple setup<br>✅ Works everywhere | ❌ Requires password/token<br>❌ Less secure<br>❌ Harder with multiple accounts |

## SSH Key Authentication

### How SSH Keys Work

1. **Key Pair Generation**: You create a public/private key pair
2. **Public Key**: Uploaded to the service (GitHub, GitLab, etc.)
3. **Private Key**: Stays on your computer (never shared)
4. **Authentication**: Service verifies your identity using the key pair

### Key Types and Security

```bash
# RSA (what our scripts use)
ssh-keygen -t rsa -b 4096 -C "your-email@example.com"

# Ed25519 (more modern, recommended)
ssh-keygen -t ed25519 -C "your-email@example.com"

# ECDSA
ssh-keygen -t ecdsa -b 521 -C "your-email@example.com"
```

**Security Levels:**
- **RSA 2048**: Minimum (deprecated)
- **RSA 4096**: Good (what our scripts use)
- **Ed25519**: Best (modern, secure, fast)

## SSH Configuration Files

### Main SSH Config File

**Location**: `~/.ssh/config` (Linux/macOS) or `%USERPROFILE%\.ssh\config` (Windows)

**Purpose**: Defines SSH connection settings, aliases, and key mappings

### Config File Structure

```bash
# Global settings (apply to all hosts)
Host *
    AddKeysToAgent yes
    UseKeychain yes

# Specific host configuration
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github-personal
    IdentitiesOnly yes
```

## Understanding SSH Config Entries

Let's break down a typical SSH config entry:

```bash
Host github-personal-ubuntu
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github-personal-ubuntu
    IdentitiesOnly yes
```

### Line-by-Line Explanation

#### 1. `Host github-personal-ubuntu`
- **Purpose**: Defines an SSH alias/hostname
- **What it does**: Creates a custom name for this configuration
- **Usage**: Use `github-personal-ubuntu` in SSH commands
- **Example**: `ssh -T github-personal-ubuntu`

#### 2. `HostName github.com`
- **Purpose**: Specifies the actual server address
- **What it does**: Tells SSH where to connect
- **Real connection**: `github-personal-ubuntu` → `github.com`
- **Why needed**: Alias is just a nickname; this is the real destination

#### 3. `User git`
- **Purpose**: Specifies the SSH username
- **What it does**: Connects as the `git` user
- **Why git**: Standard for Git hosting services
- **Alternative**: Could be different for custom servers

#### 4. `IdentityFile ~/.ssh/id_rsa_github-personal-ubuntu`
- **Purpose**: Specifies which private key to use
- **What it does**: Tells SSH which key file to use
- **Path meaning**: `~/.ssh/` = SSH directory, `id_rsa_github-personal-ubuntu` = specific key
- **Why specific**: Ensures correct key usage

#### 5. `IdentitiesOnly yes`
- **Purpose**: Forces SSH to only use the specified key
- **What it does**: Prevents SSH from trying other keys
- **Security benefit**: Ensures intended key usage
- **Why important**: Prevents key confusion

### How It Works in Practice

When you run:
```bash
ssh -T github-personal-ubuntu
```

SSH will:
1. **Recognize** `github-personal-ubuntu` as a defined Host
2. **Connect** to `github.com` (HostName)
3. **Use** the `git` user (User)
4. **Authenticate** with the specified key (IdentityFile)
5. **Only try** that specific key (IdentitiesOnly yes)

## How Multiple SSH Keys Work

### The Problem

Without SSH config, you'd need to specify keys manually:
```bash
# Tedious and error-prone
git clone -i ~/.ssh/id_rsa_github-personal git@github.com:user/repo.git
git clone -i ~/.ssh/id_rsa_gitlab-work git@gitlab.com:company/project.git
```

### The Solution

With SSH config, you use aliases:
```bash
# Clean and automatic
git clone git@github-personal:user/repo.git
git clone git@gitlab-work:company/project.git
```

### Multiple Account Setup

```bash
# SSH Config for multiple accounts
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github-personal
    IdentitiesOnly yes

Host github-work
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github-work
    IdentitiesOnly yes

Host gitlab-company
    HostName gitlab.com
    User git
    IdentityFile ~/.ssh/id_rsa_gitlab-company
    IdentitiesOnly yes
```

### Key Naming Convention

Our scripts use this naming pattern:
```
id_rsa_[account-name]
```

Examples:
- `id_rsa_github-personal`
- `id_rsa_github-work`
- `id_rsa_gitlab-company`
- `id_rsa_bitbucket-project`

## SSH Agent and Key Management

### What is SSH Agent?

SSH Agent is a background program that holds your private keys in memory, so you don't need to enter passphrases repeatedly.

### Starting SSH Agent

```bash
# Start SSH agent
eval "$(ssh-agent -s)"

# Check if running
echo $SSH_AUTH_SOCK
```

### Adding Keys to Agent

```bash
# Add specific key
ssh-add ~/.ssh/id_rsa_github-personal

# List loaded keys
ssh-add -l

# Remove specific key
ssh-add -d ~/.ssh/id_rsa_github-personal

# Remove all keys
ssh-add -D
```

### Persistent SSH Agent

For automatic startup, add to your shell profile:

**Linux/macOS (.bashrc, .zshrc):**
```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_rsa_github-personal
ssh-add ~/.ssh/id_rsa_gitlab-work
```

**Windows (PowerShell profile):**
```powershell
Start-Service ssh-agent
ssh-add $env:USERPROFILE\.ssh\id_rsa_github-personal
```

## Security Best Practices

### File Permissions

```bash
# SSH directory
chmod 700 ~/.ssh

# Private keys
chmod 600 ~/.ssh/id_rsa_*

# Public keys
chmod 644 ~/.ssh/id_rsa_*.pub

# SSH config
chmod 600 ~/.ssh/config
```

### Key Security

1. **Never share private keys**
2. **Use strong passphrases** (optional but recommended)
3. **Rotate keys regularly**
4. **Use different keys for different services**
5. **Backup keys securely**

### SSH Config Security

```bash
# Good: Specific key for each host
Host github-personal
    IdentityFile ~/.ssh/id_rsa_github-personal
    IdentitiesOnly yes

# Bad: Using default key for everything
Host *
    IdentityFile ~/.ssh/id_rsa
```

## Troubleshooting SSH Config

### Common Issues

#### 1. Permission Denied
```bash
# Check file permissions
ls -la ~/.ssh/

# Fix permissions
chmod 700 ~/.ssh
chmod 600 ~/.ssh/config
chmod 600 ~/.ssh/id_rsa_*
```

#### 2. Key Not Found
```bash
# Check if key exists
ls -la ~/.ssh/id_rsa_github-personal

# Check SSH agent
ssh-add -l

# Add key to agent
ssh-add ~/.ssh/id_rsa_github-personal
```

#### 3. Wrong Key Being Used
```bash
# Test with verbose output
ssh -vT github-personal

# Check SSH config syntax
ssh -T github-personal

# Verify config entry
cat ~/.ssh/config
```

#### 4. SSH Agent Not Running
```bash
# Check if agent is running
echo $SSH_AUTH_SOCK

# Start agent
eval "$(ssh-agent -s)"

# Add keys
ssh-add ~/.ssh/id_rsa_*
```

### Debugging Commands

```bash
# Test SSH connection with verbose output
ssh -vT github-personal

# Check SSH config syntax
ssh -T github-personal

# List loaded keys
ssh-add -l

# Test specific key
ssh -i ~/.ssh/id_rsa_github-personal -T git@github.com

# Check SSH version
ssh -V
```

### SSH Config Validation

```bash
# Check config syntax
ssh -T github-personal

# Test specific host
ssh -T git@github.com

# Compare with and without config
ssh -i ~/.ssh/id_rsa_github-personal -T git@github.com
ssh -T github-personal
```

## Advanced SSH Config Options

### Additional SSH Config Parameters

```bash
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github-personal
    IdentitiesOnly yes
    Port 22                    # SSH port (default: 22)
    Compression yes            # Enable compression
    ServerAliveInterval 60     # Keep connection alive
    ServerAliveCountMax 3      # Max keep-alive attempts
    StrictHostKeyChecking no   # Skip host key verification (use with caution)
```

### Global SSH Settings

```bash
# Apply to all hosts
Host *
    AddKeysToAgent yes         # Add keys to agent automatically
    UseKeychain yes            # Use macOS keychain (macOS only)
    ServerAliveInterval 60     # Keep connections alive
    ServerAliveCountMax 3      # Max keep-alive attempts
    Compression yes            # Enable compression
    ForwardAgent no            # Don't forward SSH agent
```

### Proxy and Tunneling

```bash
# SSH through proxy
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github-personal
    ProxyCommand ssh proxy-server nc %h %p

# Local port forwarding
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github-personal
    LocalForward 8080 localhost:80
```

## Integration with Git

### Git SSH Configuration

Git automatically uses SSH when you use `git@` URLs:

```bash
# SSH URL (uses SSH config)
git clone git@github-personal:username/repo.git

# HTTPS URL (doesn't use SSH config)
git clone https://github.com/username/repo.git
```

### Git Remote Management

```bash
# Add remote using SSH alias
git remote add origin git@github-personal:username/repo.git

# Check remote URL
git remote -v

# Change remote URL
git remote set-url origin git@github-personal:username/repo.git
```

### Multiple Remotes Example

```bash
# Add multiple remotes
git remote add origin git@github-personal:username/repo.git
git remote add work git@gitlab-work:company/project.git

# Push to different remotes
git push origin main      # Uses github-personal key
git push work main        # Uses gitlab-work key
```

## Conclusion

Understanding SSH configuration is key to effectively managing multiple SSH keys and accounts. The automation scripts in this project handle the complexity for you, but knowing how it works helps with troubleshooting and customization.

### Key Takeaways

1. **SSH config** makes multiple keys manageable
2. **Host aliases** provide clean, readable commands
3. **IdentitiesOnly yes** prevents key confusion
4. **SSH agent** keeps keys in memory for convenience
5. **Proper permissions** are essential for security
6. **Testing** helps verify configuration is correct

### Next Steps

1. **Run the setup script** for your operating system
2. **Test your connections** with `ssh -T [alias]`
3. **Start using aliases** in Git commands
4. **Customize** your SSH config as needed
5. **Learn more** about SSH and Git integration

For more information, see the main README and OS-specific documentation in this project. 