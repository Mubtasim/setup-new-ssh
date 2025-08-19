#!/bin/bash

# SSH Alias Usage Demonstration Script
# This script demonstrates how to use SSH aliases after setup

set -e

# Colors for output
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}================================${NC}"
echo -e "${BLUE}  SSH Alias Usage Demonstration${NC}"
echo -e "${BLUE}================================${NC}"

echo -e "\n${YELLOW}This script demonstrates how to use SSH aliases after setup.${NC}"
echo -e "${YELLOW}Make sure you have already run the setup script for your OS.${NC}"

echo -e "\n${GREEN}1. Interactive Host Selection${NC}"
echo -e "When running the setup script, you'll see a menu:"
echo -e "  1) GitHub (github.com)"
echo -e "  2) GitLab (gitlab.com)"
echo -e "  3) Bitbucket (bitbucket.org)"
echo -e "  4) SourceForge (git.code.sf.net)"
echo -e "  5) Gitea (gitea.com)"
echo -e "  6) Gogs (gogs.io)"
echo -e "  7) Other server (custom)"
echo -e ""
echo -e "Select the appropriate service or choose 'Other server' for custom hosts."

echo -e "\n${GREEN}2. Testing SSH Connections${NC}"
echo -e "Test your SSH connections to verify keys are working:"
echo -e "  ssh -T github-personal"
echo -e "  ssh -T gitlab-company"
echo -e "  ssh -T bitbucket-project"

echo -e "\n${GREEN}2. Git Operations with Aliases${NC}"
echo -e "Clone repositories using aliases:"
echo -e "  git clone git@github-personal:username/repo.git"
echo -e "  git clone git@gitlab-company:company/project.git"

echo -e "\n${GREEN}3. Adding Remote Repositories${NC}"
echo -e "Add remotes using aliases:"
echo -e "  git remote add origin git@github-personal:username/repo.git"
echo -e "  git remote add work git@gitlab-company:company/project.git"

echo -e "\n${GREEN}4. Pushing to Different Accounts${NC}"
echo -e "Push to different accounts (keys are automatically selected):"
echo -e "  git push origin main    # Uses github-personal key"
echo -e "  git push work main      # Uses gitlab-company key"

echo -e "\n${GREEN}5. Complete Workflow Example${NC}"
echo -e "Here's a complete workflow:"
echo -e "  # Set up keys (run once per account)"
echo -e "  ./linux/setup-ssh.sh    # or ./windows/setup-ssh.ps1 or ./mac/setup-ssh.sh"
echo -e ""
echo -e "  # Clone repositories"
echo -e "  git clone git@github-personal:username/personal-project.git"
echo -e "  git clone git@gitlab-company:company/work-project.git"
echo -e ""
echo -e "  # Work on personal project"
echo -e "  cd personal-project"
echo -e "  git push origin main    # Uses github-personal key automatically"
echo -e ""
echo -e "  # Work on work project"
echo -e "  cd ../work-project"
echo -e "  git push origin main    # Uses gitlab-company key automatically"

echo -e "\n${GREEN}6. Verifying Key Usage${NC}"
echo -e "Check which keys are loaded:"
echo -e "  ssh-add -l"
echo -e ""
echo -e "Test with verbose SSH to see key selection:"
echo -e "  ssh -vT github-personal"

echo -e "\n${GREEN}7. SSH Config Structure${NC}"
echo -e "Your ~/.ssh/config should contain entries like:"
echo -e "  Host github-personal"
echo -e "      HostName github.com"
echo -e "      User git"
echo -e "      IdentityFile ~/.ssh/id_rsa_github-personal"
echo -e "      IdentitiesOnly yes"

echo -e "\n${BLUE}================================${NC}"
echo -e "${BLUE}  Key Benefits of Using Aliases${NC}"
echo -e "${BLUE}================================${NC}"
echo -e "✅ Automatic key selection based on alias"
echo -e "✅ No need to specify -i flag for different keys"
echo -e "✅ Clean separation between different accounts"
echo -e "✅ Easy to manage multiple SSH keys"
echo -e "✅ Works with all Git operations (clone, push, pull, etc.)"
echo -e "✅ Compatible with SCP, SFTP, and other SSH tools"

echo -e "\n${YELLOW}Ready to use your SSH aliases!${NC}"
echo -e "Start by testing your connections: ssh -T [alias-name]" 