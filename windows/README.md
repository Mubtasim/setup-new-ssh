# Windows SSH Setup Automation

This directory contains the SSH setup automation script for Windows systems using PowerShell.

## Prerequisites

- Windows 10/11 or Windows Server 2019+
- PowerShell 5.1 or PowerShell Core 6+
- OpenSSH client installed
- Write permissions to `%USERPROFILE%\.ssh\` directory

## Installation

### 1. Install OpenSSH Client

**Option A: Windows Settings (Recommended)**
1. Open Windows Settings
2. Go to Apps > Optional features
3. Click "Add a feature"
4. Search for "OpenSSH Client"
5. Select and install it

**Option B: PowerShell (Administrator)**
```powershell
# Add OpenSSH capability
Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
```

**Option C: Chocolatey**
```powershell
choco install openssh
```

### 2. Set Execution Policy

If you encounter execution policy restrictions:
```powershell
# Check current policy
Get-ExecutionPolicy

# Set policy for current process (recommended)
Set-ExecutionPolicy -ExecutionPolicy Unrestricted -Scope Process
```

## Usage

### Basic Usage

Run the script:
```powershell
.\setup-ssh.ps1
```

### Force Overwrite Existing Keys

If you want to overwrite existing keys without prompts:
```powershell
.\setup-ssh.ps1 -Force
```

The script will:
1. Prompt for an account name/alias
2. Ask for the associated email
3. Let you choose SSH key type (RSA 4096-bit or Ed25519)
4. Let you select SSH server (GitHub, GitLab, etc. or custom)
5. Generate a new SSH key
6. Configure SSH settings
7. Display the public key for manual addition

### Example Session

```powershell
PS C:\path\to\windows> .\setup-ssh.ps1

================================
  SSH Setup Automation Script
================================

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
[INFO] Backing up existing SSH config to C:\Users\user\.ssh\config.backup.20231201_143022
[INFO] Generating SSH key for github-personal...
[INFO] Adding SSH config entry for github-personal...
[INFO] SSH config entry added successfully
[INFO] Setting up SSH agent...
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
```

## Features

- **Interactive Setup**: Guided prompts for account information
- **SSH Key Type Selection**: Choose between RSA 4096-bit and Ed25519 keys
- **Interactive Host Selection**: Choose from popular SSH servers or add custom servers
- **Input Validation**: Validates email format and account names
- **Automatic Backup**: Backs up existing SSH config before modifications
- **SSH Agent Integration**: Automatically starts and configures SSH agent
- **Error Handling**: Graceful error handling with informative messages
- **Force Mode**: Option to overwrite existing keys without prompts

## Account Name Examples

- `github-personal` - Personal GitHub account
- `github-work` - Work GitHub account
- `gitlab-company` - Company GitLab account
- `bitbucket-project` - Project-specific Bitbucket account
- `custom-server` - Custom SSH server

## Generated Files

The script creates the following files based on your key type selection:

**For RSA keys:**
- `%USERPROFILE%\.ssh\id_rsa_[account-name]` - Private SSH key
- `%USERPROFILE%\.ssh\id_rsa_[account-name].pub` - Public SSH key

**For Ed25519 keys:**
- `%USERPROFILE%\.ssh\id_ed25519_[account-name]` - Private SSH key
- `%USERPROFILE%\.ssh\id_ed25519_[account-name].pub` - Public SSH key

**Common:**
- `%USERPROFILE%\.ssh\config` - SSH configuration file (updated)

## SSH Config Structure

The script automatically adds entries to `%USERPROFILE%\.ssh\config`:

```
Host github-personal
    HostName github.com
    User git
    IdentityFile ~/.ssh/id_rsa_github-personal
    IdentitiesOnly yes
```

## Testing the Setup

After running the script and adding the public key to your account:

```powershell
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
```powershell
# Instead of: git clone git@github.com:username/repo.git
git clone git@github-personal:username/repo.git

# Instead of: git clone git@gitlab.com:company/project.git
git clone git@gitlab-company:company/project.git
```

**Add remote repositories:**
```powershell
# Add GitHub personal remote
git remote add origin git@github-personal:username/repo.git

# Add GitLab work remote
git remote add work git@gitlab-company:company/project.git
```

**Push to different accounts:**
```powershell
# Push to personal GitHub (uses github-personal key automatically)
git push origin main

# Push to work GitLab (uses gitlab-company key automatically)
git push work main
```

### Complete Workflow Example

```powershell
# 1. Set up SSH keys for different accounts
.\setup-ssh.ps1  # Creates github-personal
.\setup-ssh.ps1  # Creates gitlab-work

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

```powershell
# Check which keys are loaded in SSH agent
ssh-add -l

# Test with verbose SSH to see key selection
ssh -vT github-personal

# Test specific key directly
ssh -i $env:USERPROFILE\.ssh\id_rsa_github-personal -T git@github.com
```

## Troubleshooting

### Common Issues

1. **Execution Policy Error**:
   ```powershell
   Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
   ```

2. **SSH Not Found**:
   - Install OpenSSH from Windows Settings > Apps > Optional features
   - Or run the script as Administrator to attempt automatic installation

3. **Permission Denied**:
   - Ensure you have write permissions to `%USERPROFILE%\.ssh\`
   - Run PowerShell as Administrator if needed

4. **SSH Agent Issues**:
   ```powershell
   # Start SSH agent manually
   Start-Service ssh-agent
   
   # Add key manually
   ssh-add %USERPROFILE%\.ssh\id_rsa_[account-name]
   ```

5. **Key Already Exists**:
   - Use `-Force` parameter to overwrite without prompts
   - Or manually delete existing keys before running

6. **Invalid Account Name**:
   - Use only letters, numbers, hyphens, and underscores
   - Examples: `github-personal`, `gitlab_work`, `bitbucket123`

### PowerShell Version Compatibility

- **PowerShell 5.1**: Full compatibility
- **PowerShell Core 6+**: Full compatibility
- **PowerShell 3.0-4.0**: May require minor modifications

### Windows Version Support

- **Windows 10 (1803+)**: Full support
- **Windows 11**: Full support
- **Windows Server 2019+**: Full support
- **Earlier versions**: May require manual OpenSSH installation

## Security Notes

- SSH keys are generated with RSA 4096-bit encryption
- Private keys are stored in `%USERPROFILE%\.ssh\`
- Public keys are displayed for manual addition to services
- The script creates automatic backups before modifications
- No sensitive information is stored or transmitted

## Advanced Usage

### Running as Administrator

For automatic OpenSSH installation:
```powershell
# Run PowerShell as Administrator
Start-Process powershell -Verb RunAs
cd "path\to\windows"
.\setup-ssh.ps1
```

### Custom SSH Config Location

The script uses the standard SSH config location. If you need a custom location, modify the script or use symbolic links.

### Batch Processing

To set up multiple accounts:
```powershell
# Create a batch script
$accounts = @("github-personal", "gitlab-work", "bitbucket-project")
foreach ($account in $accounts) {
    Write-Host "Setting up $account..."
    # Run the script for each account
}
```

## Getting Help

If you encounter issues:
1. Check that OpenSSH is properly installed
2. Verify PowerShell execution policy settings
3. Ensure you have write permissions to `%USERPROFILE%\.ssh\`
4. Check the SSH config syntax: `ssh -T [account-name]`
5. Review Windows Event Viewer for SSH-related errors 