# Laravel Directory Permissions

A bash script to automatically fix and audit Laravel directory permissions for production deployments.

## 🚀 Quick Install

Run this script directly in your Laravel root directory:

```bash
sudo bash -c "$(curl -sSL https://raw.githubusercontent.com/max1v/laravel-directory-permissions/main/run.sh)"
```

## 📋 What It Does

This script performs two main operations:

### 1. Fix Permissions (`fix-perms`)
- **Ownership**: Sets correct owner (`$USER:www-data`)
- **Base Permissions**: Files to `644`, directories to `755`
- **Laravel Storage**: Sets `storage/` and `bootstrap/cache/` to writable permissions (`664/775`)
- **SetGID Bit**: Ensures proper group inheritance in storage directories
- **Security**: Locks down `.env` file to `640` permissions
- **Artisan**: Makes the `artisan` file executable
- **Performance**: Excludes `.git/` directory for faster execution

### 2. Audit Permissions (`laravel_audit`)
- **Directory Check**: Validates `storage/` and `bootstrap/cache/` permissions
- **Group Ownership**: Ensures `www-data` group ownership
- **Security Scan**: Detects insecure `777` permissions
- **Sensitive Files**: Checks `.env` file security
- **Color-coded Output**: Clear visual feedback with status indicators

## 🛡️ Security Features

- **Never uses `777` permissions** - they're inherently insecure
- **Proper `.env` protection** with `640` permissions (user read/write, group read, others no access)
- **Secure defaults** following Laravel security best practices
- **SetGID implementation** for proper group inheritance

## 📁 Requirements

- **Laravel Project**: Must be run from a Laravel root directory (contains `artisan` and `storage/`)
- **Linux/Unix**: Uses standard Unix tools (`find`, `chmod`, `chown`, `stat`)
- **Sudo Access**: Required for changing file ownership and permissions
- **Bash 4.0+**: For modern bash features and syntax

## 🔧 Manual Usage

```bash
# Make script executable
chmod +x run.sh

# Run directly
./run.sh

# Source to use individual functions
source run.sh
fix-perms          # Fix permissions only
laravel_audit     # Audit permissions only
laravel_audit /path/to/laravel   # Audit specific directory
```

## 📊 Permission Reference

| File/Directory | Recommended | Purpose |
|----------------|-------------|---------|
| Regular Files | `644` | User read/write, group/others read-only |
| Directories | `755` | User full access, group/others read/execute |
| Storage Files | `664` | User/group write, others read-only |
| Storage Dirs | `775` | User/group full access, others read/execute |
| Storage Dirs | `2775` | Same as `775` + SetGID for group inheritance |
| `.env` File | `640` | User read/write, group read, others no access |
| `artisan` | `755` | Executable script permissions |

## ⚠️ Important Notes

- **Backup First**: Always backup your project before running permission changes
- **Test Environment**: Test in staging before production use
- **Web Server**: Assumes `www-data` as the web server group (adjust if needed)
- **Git Safe**: Automatically disables git filemode tracking to prevent permission changes in commits

## 🐛 Troubleshooting

### "Not a Laravel root directory"
Ensure you're running the script from your Laravel project root (same directory containing `artisan` and `storage/` folders).

### Permission Denied
Make sure you have `sudo` privileges for changing file ownership and permissions.

### Web Server Issues
If your web server uses a different group than `www-data`, you may need to manually adjust the group ownership.

## 🤝 Contributing

1. Fork this repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## 📄 License

This project is open-source and available under the [MIT License](LICENSE).

## 🔗 Related Resources

- [Laravel Deployment Documentation](https://laravel.com/docs/deployment)
- [Linux File Permissions Guide](https://www.linux.com/training-tutorials/linux-file-permissions-explained/)
- [Web Server Security Best Practices](https://owasp.org/www-project-web-security-testing-guide/)