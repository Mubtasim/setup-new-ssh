#!/bin/bash

# SSH Setup Automation Script for macOS
# This script helps set up SSH keys for different accounts

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_header() {
    echo -e "${BLUE}================================${NC}"
    echo -e "${BLUE}  SSH Setup Automation Script${NC}"
    echo -e "${BLUE}================================${NC}"
}

# Function to validate email format
validate_email() {
    local email=$1
    if [[ $email =~ ^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to validate account name
validate_account_name() {
    local account_name=$1
    if [[ $account_name =~ ^[a-zA-Z0-9_-]+$ ]]; then
        return 0
    else
        return 1
    fi
}

# Function to check if SSH key already exists
check_existing_key() {
    local key_file="$HOME/.ssh/id_rsa_$1"
    if [[ -f "$key_file" ]]; then
        return 0
    else
        return 1
    fi
}

# Function to create SSH directory if it doesn't exist
create_ssh_directory() {
    if [[ ! -d "$HOME/.ssh" ]]; then
        print_status "Creating SSH directory..."
        mkdir -p "$HOME/.ssh"
        chmod 700 "$HOME/.ssh"
    fi
}

# Function to backup existing config
backup_config() {
    local config_file="$HOME/.ssh/config"
    if [[ -f "$config_file" ]]; then
        local backup_file="$config_file.backup.$(date +%Y%m%d_%H%M%S)"
        print_status "Backing up existing SSH config to $backup_file"
        cp "$config_file" "$backup_file"
    fi
}

# Function to add SSH config entry
add_ssh_config() {
    local account_name=$1
    local config_file="$HOME/.ssh/config"
    
    # Create config file if it doesn't exist
    if [[ ! -f "$config_file" ]]; then
        touch "$config_file"
        chmod 600 "$config_file"
    fi
    
    # Determine hostname based on account name
    local hostname="github.com"
    if [[ $account_name == *"gitlab"* ]]; then
        hostname="gitlab.com"
    elif [[ $account_name == *"bitbucket"* ]]; then
        hostname="bitbucket.org"
    fi
    
    # Add config entry
    print_status "Adding SSH config entry for $account_name..."
    cat >> "$config_file" << EOF

Host $account_name
    HostName $hostname
    User git
    IdentityFile ~/.ssh/id_rsa_$account_name
    IdentitiesOnly yes
EOF
    
    print_status "SSH config entry added successfully"
}

# Function to start SSH agent and add key (macOS specific)
setup_ssh_agent() {
    local account_name=$1
    local key_file="$HOME/.ssh/id_rsa_$account_name"
    
    print_status "Setting up SSH agent..."
    
    # Check if SSH agent is running
    if [[ -z "$SSH_AUTH_SOCK" ]]; then
        print_status "Starting SSH agent..."
        eval "$(ssh-agent -s)"
        
        # Add to shell profile for persistence (macOS specific)
        local profile_file=""
        if [[ -f "$HOME/.zshrc" ]]; then
            profile_file="$HOME/.zshrc"
        elif [[ -f "$HOME/.bash_profile" ]]; then
            profile_file="$HOME/.bash_profile"
        elif [[ -f "$HOME/.bashrc" ]]; then
            profile_file="$HOME/.bashrc"
        fi
        
        if [[ -n "$profile_file" ]]; then
            if ! grep -q "ssh-agent" "$profile_file"; then
                echo 'eval "$(ssh-agent -s)"' >> "$profile_file"
            fi
        fi
    fi
    
    # Add key to SSH agent
    print_status "Adding SSH key to agent..."
    ssh-add "$key_file"
    
    print_status "SSH agent setup complete"
}

# Function to display public key
display_public_key() {
    local account_name=$1
    local pub_key_file="$HOME/.ssh/id_rsa_$account_name.pub"
    
    if [[ -f "$pub_key_file" ]]; then
        echo -e "\n${BLUE}================================${NC}"
        echo -e "${BLUE}  Your Public SSH Key${NC}"
        echo -e "${BLUE}================================${NC}"
        echo -e "${YELLOW}Copy the following public key and add it to your account:${NC}\n"
        cat "$pub_key_file"
        echo -e "\n${BLUE}================================${NC}"
        echo -e "${GREEN}Setup complete!${NC}"
        echo -e "${YELLOW}Next steps:${NC}"
        echo -e "1. Copy the public key above"
        echo -e "2. Go to your account settings (GitHub/GitLab/etc.)"
        echo -e "3. Add the SSH key to your account"
        echo -e "4. Test the connection: ssh -T $account_name"
        
        # macOS specific: offer to copy to clipboard
        if command -v pbcopy &> /dev/null; then
            echo -e "\n${YELLOW}Would you like to copy the public key to clipboard? (y/N):${NC}"
            read -r copy_to_clipboard
            if [[ $copy_to_clipboard =~ ^[Yy]$ ]]; then
                cat "$pub_key_file" | pbcopy
                print_status "Public key copied to clipboard!"
            fi
        fi
    else
        print_error "Public key file not found: $pub_key_file"
        exit 1
    fi
}

# Function to check macOS version and SSH availability
check_macos_ssh() {
    # Check if SSH is available
    if ! command -v ssh-keygen &> /dev/null; then
        print_error "SSH is not installed. Please install OpenSSH first."
        echo -e "${YELLOW}You can install it using Homebrew:${NC}"
        echo -e "brew install openssh"
        echo -e "\n${YELLOW}Or install Xcode Command Line Tools:${NC}"
        echo -e "xcode-select --install"
        exit 1
    fi
    
    # Check macOS version for compatibility
    local macos_version=$(sw_vers -productVersion)
    print_status "macOS version detected: $macos_version"
}

# Function to check for Homebrew and offer installation
check_homebrew() {
    if ! command -v brew &> /dev/null; then
        print_warning "Homebrew not found. It's recommended for managing packages on macOS."
        echo -e "${YELLOW}Would you like to install Homebrew? (y/N):${NC}"
        read -r install_homebrew
        if [[ $install_homebrew =~ ^[Yy]$ ]]; then
            print_status "Installing Homebrew..."
            /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
            print_status "Homebrew installed successfully!"
        fi
    fi
}

# Main script execution
main() {
    print_header
    
    # Check macOS SSH availability
    check_macos_ssh
    
    # Check for Homebrew (optional)
    check_homebrew
    
    # Get account name
    echo -e "\n${YELLOW}Enter the account name/alias (e.g., github-personal, gitlab-work):${NC}"
    read -r account_name
    
    # Validate account name
    if ! validate_account_name "$account_name"; then
        print_error "Invalid account name. Use only letters, numbers, hyphens, and underscores."
        exit 1
    fi
    
    # Check if key already exists
    if check_existing_key "$account_name"; then
        print_warning "SSH key for '$account_name' already exists."
        echo -e "${YELLOW}Do you want to overwrite it? (y/N):${NC}"
        read -r overwrite
        if [[ ! $overwrite =~ ^[Yy]$ ]]; then
            print_status "Setup cancelled."
            exit 0
        fi
    fi
    
    # Get email
    echo -e "\n${YELLOW}Enter the email associated with this account:${NC}"
    read -r email
    
    # Validate email
    if ! validate_email "$email"; then
        print_error "Invalid email format."
        exit 1
    fi
    
    # Create SSH directory
    create_ssh_directory
    
    # Backup existing config
    backup_config
    
    # Generate SSH key
    local key_file="$HOME/.ssh/id_rsa_$account_name"
    print_status "Generating SSH key for $account_name..."
    ssh-keygen -t rsa -b 4096 -C "$email" -f "$key_file" -N ""
    
    # Set proper permissions
    chmod 600 "$key_file"
    chmod 644 "$key_file.pub"
    
    # Add SSH config entry
    add_ssh_config "$account_name"
    
    # Setup SSH agent
    setup_ssh_agent "$account_name"
    
    # Display public key
    display_public_key "$account_name"
}

# Run main function
main "$@" 