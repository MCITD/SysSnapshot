<div align="center">
  
# 🐧 Linux System Monitoring & Backup Utility

[![Stars](https://img.shields.io/github/stars/MCITD/SysSnapshot?style=for-the-badge)](https://github.com/MCITD/SysSnapshot)
[![License](https://img.shields.io/badge/license-MIT-blue.svg?style=for-the-badge)](LICENSE)
[![Bash](https://img.shields.io/badge/bash-5.0+-green.svg?style=for-the-badge)](https://www.gnu.org/software/bash/)

**A comprehensive, production-ready bash utility for system monitoring, user activity tracking, and incremental backups** 

[Features](#features) • [Installation](#installation) • [Usage](#usage) • [Documentation](#documentation) • [Contributing](#contributing)

</div>

---

## ✨ Features

- 🔍 **Real-time System Monitoring** - Track CPU, memory, and disk usage with threshold alerts
- 👥 **User Activity Tracking** - Monitor logged-in users and session management
- 💾 **Incremental Backups** - Efficient backup system that only copies changed files
- ✅ **Backup Verification** - Automated integrity checks for peace of mind
- 📊 **Filesystem Reports** - Detailed analysis of disk usage and file distribution
- ⚡ **Process Analysis** - Identify resource-hungry processes and long-running tasks

## 🚀 Quick Start
```bash
# Clone the repository
git clone https://github.com/MCITD/SysSnapshot.git

# Navigate to directory
cd SysSnapshot

# Make executable
chmod +x monitor.sh

# Run
./monitor.sh
```

## 📦 Installation

### Requirements
- Bash 4.0 or higher
- Standard Linux utilities: `awk`, `df`, `free`, `ps`, `uptime`
- Root access recommended for full functionality

### Method 1: Direct Download
```bash
wget https://raw.githubusercontent.com/MCITD/SysSnapshot/main/monitor.sh
chmod +x monitor.sh
```

### Method 2: Package Manager
```bash
# Coming soon to major package managers
```

## 📖 Usage

### Interactive Menu
Simply run the script to access the interactive menu:
```bash
./monitor.sh
```

### Command Examples

**Check System Resources:**
```bash
# Option 1 from menu - Monitors CPU, memory, and disk
# Alerts when thresholds exceeded (CPU: 80%, Memory: 85%, Disk: 59%)
```

**Create Incremental Backup:**
```bash
# Option 3 from menu
# Enter source: /home/user/documents
```

**Verify Backup Integrity:**
```bash
# Option 4 from menu - Compares file counts and checks recent files
```

## 🎯 Key Functionality

### 1. System Health Monitoring
Provides real-time metrics for critical system resources with configurable thresholds.

### 2. User Activity Tracking
- Lists all logged-in users
- Displays session details and duration
- Identifies users with multiple active sessions
- Shows recent login history

### 3. Backup Management
- **Incremental backups** save time and storage
- Timestamp-based organization (YYYYMMDD_HHMMSS)
- Tracks last backup time automatically
- Preserves file attributes and permissions

### 4. Reporting & Analysis
- Top 10 largest directories
- Filesystem usage by type
- Process memory consumption
- Long-running process identification

## ⚙️ Configuration

Edit these variables in config/settings.conf:
```bash
CPU_THRESHOLD=80          # CPU load threshold
MEMORY_THRESHOLD=85       # Memory usage threshold %
DISK_THRESHOLD=59         # Disk usage threshold %
```

## 🛠️ Advanced Usage

### Automated Backups with Cron
```bash
# Add to crontab for daily backups at 2 AM
0 2 * * * /path/to/monitor.sh <<EOF
3
/home/user/data
/path/to/backup
EOF
```

### Generate Reports via Script
```bash
# Non-interactive report generation
echo "5" | ./monitor.sh > ./reports/filesystem_report.txt
```

## 📊 Output Examples

**System Resources:**
```
═══════════════════════════════════════════════════════
SYSTEM RESOURCES MONITORING
═══════════════════════════════════════════════════════

[CPU LOAD AVERAGE]
  1-minute:  1.23
  5-minute:  0.98
  15-minute: 0.75

[MEMORY USAGE]
  Total Memory:  16384 MB
  Used Memory:   8192 MB
  Free Memory:   8192 MB
  Usage:         50.00%
```

## 🤝 Contributing

We welcome contributions! Here's how:

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit changes (`git commit -m 'Add AmazingFeature'`)
4. Push to branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🌟 Acknowledgments

- Built with ❤️ by [Andrew Davidson](https://github.com/Hantasmagoria)
- Inspired by the Linux system administration community
- Special thanks to all contributors

## 📞 Support

- 📫 Issues: [GitHub Issues](https://github.com/MCITD/SysSnapshot/issues)
- 💬 Discussions: [GitHub Discussions](https://github.com/MCITD/SysSnapshot/discussions)
- 📖 Wiki: [Documentation](https://github.com/MCITD/SysSnapshot/wiki)

## 🔒 Security

For security concerns, please email minecraftitdepartment@gmail.com

---

<div align="center">

**If this project helped you, please consider giving it a ⭐️!**

Made with 💻 and ☕

</div>
