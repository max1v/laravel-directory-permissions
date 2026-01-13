# AGENTS.md

This file contains guidelines and commands for agentic coding agents working in this Laravel directory permissions repository.

## Repository Overview

This is a shell script repository that provides utilities for managing Laravel directory permissions. The repository contains:
- `run.sh` - Public distribution script that runs fix-perms then laravel_audit sequentially
- The script defines `fix-perms()` and `laravel_audit()` functions

## Build/Test Commands

### Testing the Script
```bash
# Test individual functions from run.sh
source run.sh
fix-perms
laravel_audit
laravel_audit /path/to/laravel/project

# Test the public distribution script
./run.sh

# Test via curl (simulating public usage)
sudo bash -c "$(curl -sSL https://raw.githubusercontent.com/your-repo/laravel-directory-permissions/main/run.sh)"
```

### Manual Testing
```bash
# Create a test Laravel-like structure
mkdir -p test-laravel/storage test-laravel/bootstrap/cache
touch test-laravel/artisan test-laravel/.env

# Test functions on the test directory
cd test-laravel
source ../run.sh
laravel_audit
fix-perms

# Test run.sh in test environment
../run.sh
```

### Single Function Testing
```bash
# Test only fix-perms function
source run.sh && fix-perms

# Test only laravel_audit function  
source run.sh && laravel_audit

# Test run.sh with specific directory
cd /path/to/laravel && /path/to/run.sh
```

## Code Style Guidelines

### Shell Script Conventions
- Use bash functions with descriptive names
- Use snake_case for function names and variable names (e.g., `laravel_audit`, `web_group`)
- Use UPPER_CASE for constants and environment variables (e.g., `RED`, `ORIGINAL_USER`)
- Prefix functions with clear action verbs (fix-, audit-, check-, etc.)
- Use POSIX-compliant bash syntax
- Include shebang `#!/bin/bash` at top of executable scripts
- Use `set -e` for error handling in distribution scripts
- Use `local` for function-local variables to avoid global pollution

### Error Handling
- Always check if required files/directories exist before proceeding
- Use meaningful exit codes (0 for success, 1 for errors)
- Provide clear error messages with context
- Use conditional checks before operations that might fail

### Output Formatting
- Use emoji indicators for visual clarity (🛠️, ✅, ⚠️, etc.)
- Use color codes for terminal output:
  - RED='\033[0;31m' for errors
  - GREEN='\033[0;32m' for success
  - YELLOW='\033[1;33m' for warnings
  - BLUE='\033[0;34m' for info
  - NC='\033[0m' to reset colors
- Use consistent formatting for audit output with [STATUS] prefixes

### Security Best Practices
- Never use 777 permissions - they're insecure
- Use 640 for .env files (user read/write, group read, others no access)
- Use 644 for regular files, 755 for directories
- Use 664/775 for writable storage directories
- Apply SetGID bit (g+s) for group inheritance in storage directories
- Always ignore .git directory in permission operations for performance

### Laravel-Specific Conventions
- Check for `artisan` file and `storage` directory to validate Laravel root
- Use `www-data` as the default web server group
- Target these directories for special permissions:
  - `storage/` - Laravel's storage directory
  - `bootstrap/cache/` - Laravel's cache directory
- Ensure `artisan` file is executable

### Performance Considerations
- Exclude `.git/` directory from find operations for better performance
- Exclude `node_modules/` and `vendor/` from security scans
- Use `-maxdepth` parameter for security scans to limit scope
- Use `find` with `-exec` for batch operations instead of loops
- Disable git filemode tracking (`git config core.fileMode false`) to prevent permission changes in commits

### Function Structure
1. Safety checks first (validate environment, check required files)
2. Declare local variables and constants at function start
3. Main logic operations with clear error handling
4. Clear success/failure feedback with colored output
5. Proper return codes (0 for success, 1 for errors)

### Variable and Import Guidelines
- No external imports - this is a pure bash script
- All variables are local unless explicitly global
- Capture sudo user with `ORIGINAL_USER=${SUDO_USER:-$USER}`
- Use descriptive variable names: `web_group`, `target_dir`, `writable_dirs`
- Constants at top level: colors, default groups, permission numbers

### Script Structure for Distribution Scripts
1. Shebang and error handling (`set -e`)
2. Color definitions at top
3. Function definitions
4. Main execution with clear step numbering
5. Success message and usage tips

### Documentation
- Use inline comments for complex operations
- Number steps in multi-step operations
- Explain permission numbers in comments (e.g., "# 640 = User Read/Write, Group Read, Others No Access")
- Provide usage examples in function headers when needed

## File Structure
- `run.sh` - Public distribution script with sequential execution
- `README.md` - Basic repository description
- `.git/` - Git version control

## Dependencies
- Standard Unix/Linux tools: `find`, `chmod`, `chown`, `stat`, `echo`
- `sudo` access for permission changes
- Bash shell (version 4.0+ recommended)

## Testing Strategy
Since this is a shell script repository, testing involves:
1. Creating test Laravel directory structures
2. Verifying functions detect non-Laravel directories correctly
3. Checking permission changes are applied correctly
4. Validating audit function reports accurate results
5. Testing edge cases (missing files, permission denied, etc.)
6. Testing the public distribution script via curl
7. Verifying sequential execution order (fix-perms then laravel_audit)

Always test in a safe environment before applying to production Laravel applications.

## Public Distribution Guidelines
- The `run.sh` script is designed for public GitHub distribution
- Use curl command for one-line installation: `sudo bash -c "$(curl -sSL <url> | bash)"`
- Script must be self-contained with all functions defined
- Include proper error handling with `set -e`
- Use clear step-by-step output with colored formatting
- Ensure script works when piped to bash from curl