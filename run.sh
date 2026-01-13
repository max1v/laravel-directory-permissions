#!/bin/bash

# Laravel Permission Fix Script
# Run this script in your Laravel root directory to audit and fix permissions
# Usage: curl -sSL https://raw.githubusercontent.com/max1v/laravel-directory-permissions/main/run.sh | bash

set -e

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

echo -e "${BLUE}🚀 Laravel Permission Fix Script${NC}"
echo -e "${BLUE}=================================${NC}"

function laravel_audit() {
    local target_dir="${1:-$(pwd)}"
    local web_group="www-data"

    echo -e "${BLUE}=== Starting Laravel Permission Audit ===${NC}"
    echo -e "Target: $target_dir"

    if [[ ! -f "$target_dir/artisan" ]]; then
        echo -e "${RED}[ERROR] Not a Laravel root directory.${NC}"
        return 1
    fi

    # 1. Check Directories (Storage & Cache)
    echo -e "${BLUE}--- Checking Writable Directories ---${NC}"
    local writable_dirs=("$target_dir/storage" "$target_dir/bootstrap/cache")

    for dir in "${writable_dirs[@]}"; do
        if [[ -d "$dir" ]]; then
            local group=$(stat -c "%G" "$dir")
            local perm=$(stat -c "%a" "$dir")

            # Check Group
            if [[ "$group" != "$web_group" ]]; then
                echo -e "${YELLOW}[WARN]  $dir owned by '$group' (Should be '$web_group')${NC}"
            else
                echo -e "${GREEN}[OK]    $dir group is correct${NC}"
            fi

            # Check Perms (Allow 775, 770, OR 2775 for SetGID)
            if [[ "$perm" == "777" ]]; then
                 echo -e "${RED}[FAIL]  $dir is 777 (INSECURE)${NC}"
            elif [[ "$perm" == "775" || "$perm" == "770" || "$perm" == "2775" ]]; then
                 echo -e "${GREEN}[OK]    $dir permissions are $perm${NC}"
            else
                 echo -e "${YELLOW}[WARN]  $dir permissions are $perm (Might not be writable)${NC}"
            fi
        fi
    done

    # 2. Check .env
    echo -e "\n${BLUE}--- Checking Sensitive Files ---${NC}"
    local env_perm=$(stat -c "%a" "$target_dir/.env" 2>/dev/null)
    if [[ -f "$target_dir/.env" ]]; then
        if [[ "$env_perm" == "640" || "$env_perm" == "600" ]]; then
             echo -e "${GREEN}[OK]    .env is $env_perm (Secure)${NC}"
        else
             echo -e "${YELLOW}[WARN]  .env is $env_perm (Recommend 640)${NC}"
        fi
    fi

    # 3. Scan for 777 (Ignoring Symlinks!)
    echo -e "\n${BLUE}--- Scanning for insecure 777 permissions ---${NC}"
    local insecure_finds=$(find "$target_dir" -maxdepth 3 -perm 777 -not -type l -not -path "*/node_modules/*" -not -path "*/vendor/*" -not -path "*/.git/*" | head -n 5)

    if [[ -n "$insecure_finds" ]]; then
        echo -e "${RED}[FAIL] Found REAL 777 permissions:${NC}"
        echo "$insecure_finds"
    else
        echo -e "${GREEN}[OK]    No insecure 777 files found.${NC}"
    fi

    echo -e "\n${BLUE}=== Audit Complete ===${NC}"
}

function fix-perms() {
    # 1. Safety Check: Ensure we are in a Laravel root
    if [ ! -f "artisan" ] || [ ! -d "storage" ]; then
        echo -e "${RED}⚠️  Error: You don't appear to be in a Laravel root directory.${NC}"
        echo -e "${RED}   (Cannot find 'artisan' file or 'storage' folder)${NC}"
        return 1
    fi

    echo -e "${BLUE}🛠️  Fixing Laravel permissions for $(pwd)...${NC}"

    git config core.fileMode false
    # 2. Set Owner (Dynamic User)
    sudo chown -R $USER:www-data .

    # 3. Set Base Permissions (Files 644, Dirs 755)
    # We ignore the .git folder to speed things up significantly
    sudo find . -type f -not -path "./.git/*" -exec chmod 644 {} +
    sudo find . -type d -not -path "./.git/*" -exec chmod 755 {} +

    # 4. Storage & Cache Permissions (Files 664, Dirs 775)
    sudo find storage bootstrap/cache -type f -exec chmod 664 {} +
    sudo find storage bootstrap/cache -type d -exec chmod 775 {} +

    # 5. SetGID (The "Sticky" Bit) for group inheritance
    sudo find storage bootstrap/cache -type d -exec chmod g+s {} +

    # 6. Lock down .env (Security Hardening)
    # 640 = User Read/Write, Group Read, Others No Access
    if [ -f ".env" ]; then
        sudo chmod 640 .env
    fi

    # 7. Make Artisan Executable
    sudo chmod +x artisan

    echo -e "${GREEN}✅ Permissions fixed!${NC}"
}

# Main execution
echo -e "\n${YELLOW}🔧 Step 1: Fixing permissions...${NC}"
fix-perms

echo -e "\n${YELLOW}📋 Step 2: Running permission audit...${NC}"
laravel_audit

echo -e "\n${GREEN}🎉 All done! Your Laravel permissions are now properly configured.${NC}"
echo -e "${BLUE}💡 Tip: Run this script whenever you deploy or notice permission issues.${NC}"