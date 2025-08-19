# SSH Setup Automation

This project provides automated SSH key setup scripts for multiple operating systems, allowing you to easily manage SSH keys for different accounts (GitHub, GitLab, etc.).

## Overview

The automation scripts help you:
- Generate SSH keys for different accounts
- Configure SSH config file with proper aliases
- Start SSH agent and add keys
- Display public keys for manual addition to services

## Supported Operating Systems

- **Linux**: Bash script (`linux/setup-ssh.sh`)
- **Windows**: PowerShell script (`windows/setup-ssh.ps1`)
- **macOS**: Bash script (`mac/setup-ssh.sh`)

## Quick Start

1. Navigate to your operating system's folder
2. Follow the instructions in the respective README
3. Run the script and follow the prompts
4. After setup, run `./demo-usage.sh` to see usage examples

## Learning Resources

- **SSH-CONFIG-GUIDE.md**: Comprehensive guide explaining SSH configuration concepts, how SSH works, and the underlying technology used by the automation scripts
- **demo-usage.sh**: Interactive demonstration of how to use SSH aliases after setup

## Features

- Interactive account setup
- Automatic SSH config management
- SSH agent integration
- Cross-platform compatibility
- Input validation and error handling

## Project Structure

```
setup-new-ssh/
├── linux/          # Linux automation scripts
├── windows/        # Windows automation scripts  
├── mac/           # macOS automation scripts
├── demo-usage.sh   # Usage demonstration script
├── SSH-CONFIG-GUIDE.md  # SSH configuration concepts guide
└── README.md      # This file
```

## Usage Examples

### Account Aliases
- `github-personal` - Personal GitHub account
- `github-work` - Work GitHub account
- `gitlab-company` - Company GitLab account
- `bitbucket-project` - Project-specific Bitbucket account

### SSH Config Output
The scripts automatically create SSH config entries like:
```
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github-personal
    IdentitiesOnly yes
```

### Using SSH Aliases

Once you've set up your SSH keys, you can use the aliases in various ways:

#### 1. **Git Operations with Aliases**

**Clone repositories:**
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

# Add Bitbucket project remote
git remote add project git@bitbucket-project:team/project.git
```

**Push to different accounts:**
```bash
# Push to personal GitHub
git push origin main

# Push to work GitLab
git push work main

# Push to project Bitbucket
git push project main
```

#### 2. **SSH Connection Testing**

Test your SSH connections:
```bash
# Test GitHub personal account
ssh -T github-personal
# Expected output: "Hi username! You've successfully authenticated..."

# Test GitLab work account
ssh -T gitlab-company
# Expected output: "Welcome to GitLab, @username!"

# Test Bitbucket project account
ssh -T bitbucket-project
# Expected output: "logged in as username."
```

#### 3. **SCP/SFTP with Aliases**

Transfer files using your aliases:
```bash
# Copy file to GitHub personal server
scp file.txt github-personal:/path/to/destination/

# Copy from GitLab work server
scp gitlab-company:/path/to/file.txt ./

# SFTP to Bitbucket project server
sftp bitbucket-project
```

#### 4. **Multiple Account Workflow Example**

Here's a complete workflow example:

```bash
# 1. Set up keys for different accounts
./linux/setup-ssh.sh  # Creates github-personal
./linux/setup-ssh.sh  # Creates gitlab-work

# 2. Clone repositories using aliases
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

#### 5. **Verifying Key Usage**

Check which key is being used:
```bash
# Test with verbose SSH to see key selection
ssh -vT github-personal

# Check loaded keys in SSH agent
ssh-add -l

# Test specific key
ssh -i ~/.ssh/id_rsa_github-personal -T git@github.com
```

## Security Notes

- SSH keys are generated with secure defaults
- Private keys are protected with appropriate permissions
- Public keys are displayed for manual addition to services
- No sensitive information is stored or transmitted

## Troubleshooting

If you encounter issues:
1. Check that SSH is properly installed on your system
2. Ensure you have write permissions to `~/.ssh/`
3. Verify that the SSH agent is running
4. Check the specific OS README for troubleshooting steps 