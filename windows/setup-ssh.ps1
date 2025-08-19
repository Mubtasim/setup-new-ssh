# SSH Setup Automation Script for Windows
# This script helps set up SSH keys for different accounts

param(
    [switch]$Force
)

# Set error action preference
$ErrorActionPreference = "Stop"

# Function to write colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

function Write-Header {
    Write-Host "================================" -ForegroundColor Blue
    Write-Host "  SSH Setup Automation Script" -ForegroundColor Blue
    Write-Host "================================" -ForegroundColor Blue
}

# Function to validate email format
function Test-EmailFormat {
    param([string]$Email)
    $emailPattern = '^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$'
    return $Email -match $emailPattern
}

# Function to validate account name
function Test-AccountName {
    param([string]$AccountName)
    $namePattern = '^[a-zA-Z0-9_-]+$'
    return $AccountName -match $namePattern
}

# Function to check if SSH key already exists
function Test-ExistingKey {
    param([string]$AccountName)
    $keyFile = "$env:USERPROFILE\.ssh\id_rsa_$AccountName"
    return Test-Path $keyFile
}

# Function to create SSH directory if it doesn't exist
function New-SshDirectory {
    $sshDir = "$env:USERPROFILE\.ssh"
    if (-not (Test-Path $sshDir)) {
        Write-Status "Creating SSH directory..."
        New-Item -ItemType Directory -Path $sshDir -Force | Out-Null
    }
}

# Function to backup existing config
function Backup-SshConfig {
    $configFile = "$env:USERPROFILE\.ssh\config"
    if (Test-Path $configFile) {
        $timestamp = Get-Date -Format "yyyyMMdd_HHmmss"
        $backupFile = "$configFile.backup.$timestamp"
        Write-Status "Backing up existing SSH config to $backupFile"
        Copy-Item $configFile $backupFile
    }
}

# Function to select host interactively
function Select-Host {
    Write-Host ""
    Write-Host "Select the SSH server:" -ForegroundColor Yellow
    Write-Host "1) GitHub (github.com)"
    Write-Host "2) GitLab (gitlab.com)"
    Write-Host "3) Bitbucket (bitbucket.org)"
    Write-Host "4) SourceForge (git.code.sf.net)"
    Write-Host "5) Gitea (gitea.com)"
    Write-Host "6) Gogs (gogs.io)"
    Write-Host "7) Other server (custom)"
    
    do {
        $choice = Read-Host "Enter choice (1-7)"
        switch ($choice) {
            "1" { return "github.com:git" }
            "2" { return "gitlab.com:git" }
            "3" { return "bitbucket.org:git" }
            "4" { return "git.code.sf.net:git" }
            "5" { return "gitea.com:git" }
            "6" { return "gogs.io:git" }
            "7" { return "custom" }
            default { Write-Host "Invalid choice. Please enter 1-7." -ForegroundColor Red }
        }
    } while ($choice -notmatch '^[1-7]$')
}

# Function to get custom server details
function Get-CustomServer {
    Write-Host ""
    Write-Host "Enter custom server details:" -ForegroundColor Yellow
    
    # Get hostname
    do {
        $hostname = Read-Host "Enter hostname (e.g., my-server.com)"
        if ([string]::IsNullOrWhiteSpace($hostname)) {
            Write-Host "Hostname cannot be empty." -ForegroundColor Red
        }
    } while ([string]::IsNullOrWhiteSpace($hostname))
    
    # Get username (with default)
    $user = Read-Host "Enter SSH user (default: git)"
    if ([string]::IsNullOrWhiteSpace($user)) {
        $user = "git"
    }
    
    return "$hostname`:$user"
}

# Function to select key type
function Select-KeyType {
    Write-Host ""
    Write-Host "Select SSH key type:" -ForegroundColor Yellow
    Write-Host "1) RSA 4096-bit (works almost everywhere)"
    Write-Host "2) Ed25519 (modern, faster, smaller)"
    
    do {
        $choice = Read-Host "Enter choice (1-2)"
        switch ($choice) {
            "1" { return "rsa:4096" }
            "2" { return "ed25519" }
            default { Write-Host "Invalid choice. Please enter 1 or 2." -ForegroundColor Red }
        }
    } while ($choice -notmatch '^[1-2]$')
}

# Function to add SSH config entry
function Add-SshConfigEntry {
    param([string]$AccountName, [string]$Hostname, [string]$User, [string]$KeyType)
    
    $configFile = "$env:USERPROFILE\.ssh\config"
    
    # Create config file if it doesn't exist
    if (-not (Test-Path $configFile)) {
        New-Item -ItemType File -Path $configFile -Force | Out-Null
    }
    
    # Determine identity file based on key type
    $identityFile = if ($KeyType -eq "rsa") { "~/.ssh/id_rsa_$AccountName" } else { "~/.ssh/id_ed25519_$AccountName" }
    
    # Add config entry
    Write-Status "Adding SSH config entry for $AccountName..."
    $configEntry = @"

Host $AccountName
    HostName $Hostname
    User $User
    IdentityFile $identityFile
    IdentitiesOnly yes
"@
    
    Add-Content -Path $configFile -Value $configEntry
    Write-Status "SSH config entry added successfully"
}

# Function to start SSH agent and add key
function Start-SshAgent {
    param([string]$AccountName, [string]$KeyType)
    
    Write-Status "Setting up SSH agent..."
    
    # Check if SSH agent is running
    $agentProcess = Get-Process ssh-agent -ErrorAction SilentlyContinue
    if (-not $agentProcess) {
        Write-Status "Starting SSH agent..."
        Start-Process ssh-agent -WindowStyle Hidden
        Start-Sleep -Seconds 2
    }
    
    # Determine key file based on key type
    $keyFile = if ($KeyType -eq "rsa") { "$env:USERPROFILE\.ssh\id_rsa_$AccountName" } else { "$env:USERPROFILE\.ssh\id_ed25519_$AccountName" }
    
    Write-Status "Adding SSH key to agent..."
    
    try {
        ssh-add $keyFile
        Write-Status "SSH agent setup complete"
    }
    catch {
        Write-Warning "Could not add key to SSH agent automatically. You may need to add it manually:"
        Write-Host "ssh-add $keyFile" -ForegroundColor Yellow
    }
}

# Function to display public key
function Show-PublicKey {
    param([string]$AccountName, [string]$KeyType)
    
    # Determine public key file based on key type
    $pubKeyFile = if ($KeyType -eq "rsa") { "$env:USERPROFILE\.ssh\id_rsa_$AccountName.pub" } else { "$env:USERPROFILE\.ssh\id_ed25519_$AccountName.pub" }
    
    if (Test-Path $pubKeyFile) {
        Write-Host ""
        Write-Host "================================" -ForegroundColor Blue
        Write-Host "  Your Public SSH Key" -ForegroundColor Blue
        Write-Host "================================" -ForegroundColor Blue
        Write-Host "Copy the following public key and add it to your account:" -ForegroundColor Yellow
        Write-Host ""
        Get-Content $pubKeyFile
        Write-Host ""
        Write-Host "================================" -ForegroundColor Blue
        Write-Host "Setup complete!" -ForegroundColor Green
        Write-Host "Next steps:" -ForegroundColor Yellow
        Write-Host "1. Copy the public key above"
        Write-Host "2. Go to your account settings (GitHub/GitLab/etc.)"
        Write-Host "3. Add the SSH key to your account"
        Write-Host "4. Test the connection: ssh -T $AccountName"
    }
    else {
        Write-Error "Public key file not found: $pubKeyFile"
        exit 1
    }
}

# Function to check if SSH is available
function Test-SshAvailable {
    try {
        $null = Get-Command ssh-keygen -ErrorAction Stop
        return $true
    }
    catch {
        return $false
    }
}

# Function to install OpenSSH (Windows 10/11)
function Install-OpenSSH {
    Write-Status "OpenSSH not found. Attempting to install..."
    
    # Check if we're running as administrator
    $isAdmin = ([Security.Principal.WindowsPrincipal] [Security.Principal.WindowsIdentity]::GetCurrent()).IsInRole([Security.Principal.WindowsBuiltInRole] "Administrator")
    
    if (-not $isAdmin) {
        Write-Error "Administrator privileges required to install OpenSSH. Please run PowerShell as Administrator and try again."
        exit 1
    }
    
    try {
        # Add OpenSSH capability
        Add-WindowsCapability -Online -Name OpenSSH.Client~~~~0.0.1.0
        Write-Status "OpenSSH installed successfully. Please restart your terminal and run the script again."
        exit 0
    }
    catch {
        Write-Error "Failed to install OpenSSH. Please install it manually from Windows Settings > Apps > Optional features."
        exit 1
    }
}

# Main script execution
function Main {
    Write-Header
    
    # Check if SSH is available
    if (-not (Test-SshAvailable)) {
        Write-Error "SSH is not installed or not in PATH."
        Write-Host "Please install OpenSSH from Windows Settings > Apps > Optional features" -ForegroundColor Yellow
        Write-Host "Or run this script as Administrator to attempt automatic installation" -ForegroundColor Yellow
        exit 1
    }
    
    # Get account name
    Write-Host ""
    Write-Host "Enter the account name/alias (e.g., github-personal, gitlab-work):" -ForegroundColor Yellow
    $accountName = Read-Host
    
    # Validate account name
    if (-not (Test-AccountName $accountName)) {
        Write-Error "Invalid account name. Use only letters, numbers, hyphens, and underscores."
        exit 1
    }
    
    # Check if key already exists
    if (Test-ExistingKey $accountName) {
        if (-not $Force) {
            Write-Warning "SSH key for '$accountName' already exists."
            $overwrite = Read-Host "Do you want to overwrite it? (y/N)"
            if ($overwrite -notmatch '^[Yy]$') {
                Write-Status "Setup cancelled."
                exit 0
            }
        }
    }
    
    # Get email
    Write-Host ""
    Write-Host "Enter the email associated with this account:" -ForegroundColor Yellow
    $email = Read-Host
    
    # Validate email
    if (-not (Test-EmailFormat $email)) {
        Write-Error "Invalid email format."
        exit 1
    }
    
    # Create SSH directory
    New-SshDirectory
    
    # Backup existing config
    Backup-SshConfig
    
    # Select key type
    Write-Status "Selecting SSH key type..."
    $keySelection = Select-KeyType
    
    # Parse key selection
    if ($keySelection -eq "rsa:4096") {
        $keyType = "rsa"
        $keyBits = "4096"
        $keyFile = "$env:USERPROFILE\.ssh\id_rsa_$accountName"
    }
    else {
        $keyType = "ed25519"
        $keyBits = ""
        $keyFile = "$env:USERPROFILE\.ssh\id_ed25519_$accountName"
    }
    
    Write-Status "Selected: $keyType $keyBits"
    
    # Generate SSH key
    Write-Status "Generating SSH key for $accountName..."
    
    try {
        if ($keyBits) {
            ssh-keygen -t $keyType -b $keyBits -C $email -f $keyFile -N '""'
        }
        else {
            ssh-keygen -t $keyType -C $email -f $keyFile -N '""'
        }
    }
    catch {
        Write-Error "Failed to generate SSH key: $_"
        exit 1
    }
    
    # Select host interactively
    Write-Status "Selecting SSH server..."
    $hostSelection = Select-Host
    
    # Parse host selection
    if ($hostSelection -eq "custom") {
        # Get custom server details
        $serverDetails = Get-CustomServer
        $hostname = $serverDetails.Split(':')[0]
        $user = $serverDetails.Split(':')[1]
    }
    else {
        # Parse predefined server details
        $hostname = $hostSelection.Split(':')[0]
        $user = $hostSelection.Split(':')[1]
    }
    
    Write-Status "Selected: $hostname (user: $user)"
    
    # Add SSH config entry
    Add-SshConfigEntry $accountName $hostname $user $keyType
    
    # Setup SSH agent
    Start-SshAgent $accountName $keyType
    
    # Display public key
    Show-PublicKey $accountName $keyType
}

# Run main function
try {
    Main
}
catch {
    Write-Error "An error occurred: $_"
    exit 1
} 