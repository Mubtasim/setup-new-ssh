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