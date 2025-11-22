#!/bin/bash

################################################################################
# Script Name: Linux System Monitoring & Backup Utility
# Description: Comprehensive tool for system monitoring, user activity tracking,
#              incremental backups, and system reporting
# Author: Muhdammad_Farhan_DAUD.from_EUSS@support.gov.sg
# Date: 2025-11-22
# Version: 1.9.240
################################################################################

# config loader with ~sensible~ defaults
config_file="/config/settings.conf"

# Defaults
_default_CPU=80
_default_MEMORY=85
_default_DISK=59   # currently set to 59% to avoid the recent Win11 KB5063878 issue with certain SSDs

# Start with defaults (config file settings will override these)
CPU_THRESHOLD="$_default_CPU"
MEMORY_THRESHOLD="$_default_MEMORY"
DISK_THRESHOLD="$_default_DISK"

# Load config if readable
if [ -r "$config_file" ]; then
    . "$config_file" 2>/dev/null || true
fi

# Normalize: remove percent signs and whitespace
CPU_THRESHOLD="${CPU_THRESHOLD//%/}"
MEMORY_THRESHOLD="${MEMORY_THRESHOLD//%/}"
DISK_THRESHOLD="${DISK_THRESHOLD//%/}"

CPU_THRESHOLD="${CPU_THRESHOLD//[[:space:]]/}"
MEMORY_THRESHOLD="${MEMORY_THRESHOLD//[[:space:]]/}"
DISK_THRESHOLD="${DISK_THRESHOLD//[[:space:]]/}"

# Validate numeric, fall back to defaults on invalid values
case "$CPU_THRESHOLD" in
    ''|*[!0-9]*) CPU_THRESHOLD="$_default_CPU" ;;
esac
case "$MEMORY_THRESHOLD" in
    ''|*[!0-9]*) MEMORY_THRESHOLD="$_default_MEMORY" ;;
esac
case "$DISK_THRESHOLD" in
    ''|*[!0-9]*) DISK_THRESHOLD="$_default_DISK" ;;
esac

export CPU_THRESHOLD MEMORY_THRESHOLD DISK_THRESHOLD

# Color codes for terminal output
RED='\033[0;31m'
GREEN='\033[0;32m'
CYAN='\033[0;36m'
MAGENTA='\033[0;35m'
NC='\033[0m'    # No Color

################################################################################
# Description: Displays the main menu with styled borders and options
################################################################################
display_menu() {
    clear
    echo -e "${MAGENTA}╔════════════════════════════════════════════════════════╗${NC}"
    echo -e "${MAGENTA}║${NC}      ${MAGENTA}LINUX SYSTEM MONITORING &${NC}                         ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}║${NC}              ${MAGENTA}BACKUP UTILITY${NC}                            ${MAGENTA}║${NC}"
    echo -e "${MAGENTA}╚════════════════════════════════════════════════════════╝${NC}"
    echo -e "                ${MAGENTA}Version 1.9.240${NC}"
    echo ""
    echo -e "${CYAN}┌────────────────────────────────────────────────────────┐${NC}"
    echo -e "${CYAN}│${NC}      ${CYAN}SYSTEM HEALTH & USER ACTIVITY${NC}                     ${CYAN}│${NC}"
    echo -e "${CYAN}├────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}1)${NC} Check System Resources                              ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC}    (CPU, Memory, Disk)                                 ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}2)${NC} Track User Activity & Sessions                      ${CYAN}│${NC}"
    echo -e "${CYAN}├────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}              ${CYAN}BACKUP MANAGEMENT${NC}                         ${CYAN}│${NC}"
    echo -e "${CYAN}├────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}3)${NC} Create Incremental Backup                           ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}4)${NC} Verify Backup Integrity                             ${CYAN}│${NC}"
    echo -e "${CYAN}├────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC}            ${CYAN}REPORTING & ANALYSIS${NC}                        ${CYAN}│${NC}"
    echo -e "${CYAN}├────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}5)${NC} Generate Filesystem Usage Report                    ${CYAN}│${NC}"
    echo -e "${CYAN}│${NC} ${GREEN}6)${NC} Analyze Running Processes                           ${CYAN}│${NC}"
    echo -e "${CYAN}├────────────────────────────────────────────────────────┤${NC}"
    echo -e "${CYAN}│${NC} ${RED}0)${NC} Exit                                                ${CYAN}│${NC}"
    echo -e "${CYAN}└────────────────────────────────────────────────────────┘${NC}"
    echo ""
}

################################################################################
# Description: Monitors CPU load average, memory usage, and disk usage
#              Returns 1 if any threshold is exceeded, 0 otherwise
################################################################################
check_system_resources() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}SYSTEM RESOURCES MONITORING${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    
    local threshold_exceeded=0
    
    # CPU Load Average - extract 1, 5, and 15 minute averages from uptime
    echo -e "\n${CYAN}[CPU LOAD AVERAGE]${NC}"
    local load_avg=$(uptime | awk -F'load average:' '{print $2}')
    local load_1min=$(echo $load_avg | awk -F',' '{print $1}' | xargs)
    local load_5min=$(echo $load_avg | awk -F',' '{print $2}' | xargs)
    local load_15min=$(echo $load_avg | awk -F',' '{print $3}' | xargs)
    
    echo "  1-minute:  $load_1min"
    echo "  5-minute:  $load_5min"
    echo "  15-minute: $load_15min"
    
    # Check if 1-minute load exceeds CPU threshold
    local load_check=$(echo "$load_1min > $CPU_THRESHOLD" | bc 2>/dev/null || echo "0")
    if [ "$load_check" -eq 1 ]; then
        echo -e "  ${RED}⚠ WARNING: High CPU load detected!${NC}"
        threshold_exceeded=1
    fi
    
    # Memory Usage - use free command to get memory statistics
    echo -e "\n${CYAN}[MEMORY USAGE]${NC}"
    local mem_total=$(free -m | awk 'NR==2 {print $2}')
    local mem_used=$(free -m | awk 'NR==2 {print $3}')
    local mem_free=$(free -m | awk 'NR==2 {print $4}')
    local mem_percent=$(awk "BEGIN {printf \"%.2f\", ($mem_used/$mem_total)*100}")
    
    echo "  Total Memory:  ${mem_total} MB"
    echo "  Used Memory:   ${mem_used} MB"
    echo "  Free Memory:   ${mem_free} MB"
    echo "  Usage:         ${mem_percent}%"
    
    # Check if memory usage exceeds threshold
    local mem_check=$(echo "$mem_percent > $MEMORY_THRESHOLD" | bc)
    if [ "$mem_check" -eq 1 ]; then
        echo -e "  ${RED}⚠ WARNING: High memory usage detected!${NC}"
        threshold_exceeded=1
    fi
    
    # Disk Usage - check root partition usage
    echo -e "\n${CYAN}[DISK USAGE - ROOT PARTITION]${NC}"
    local disk_info=$(df -h / | awk 'NR==2 {print $2,$3,$4,$5}')
    local disk_total=$(echo $disk_info | awk '{print $1}')
    local disk_used=$(echo $disk_info | awk '{print $2}')
    local disk_free=$(echo $disk_info | awk '{print $3}')
    local disk_percent=$(echo $disk_info | awk '{print $4}' | tr -d '%')
    
    echo "  Total Space:   $disk_total"
    echo "  Used Space:    $disk_used"
    echo "  Free Space:    $disk_free"
    echo "  Usage:         ${disk_percent}%"
    
    # Check if disk usage exceeds threshold
    if [ "$disk_percent" -gt "$DISK_THRESHOLD" ]; then
        echo -e "  ${RED}⚠ WARNING: High disk usage detected!${NC}"
        threshold_exceeded=1
    fi
    
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
    
    # Return status based on threshold checks
    return $threshold_exceeded
}

################################################################################
# Description: Monitors logged-in users, their sessions, and connection details
################################################################################
track_user_activity() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}USER ACTIVITY & SESSIONS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    
    # Get currently logged-in users using who command
    echo -e "\n${CYAN}[CURRENTLY LOGGED-IN USERS]${NC}"
    
    # Array to store unique users
    declare -A user_sessions
    local total_sessions=0
    
    # Parse who command output
    while IFS= read -r line; do
        local username=$(echo $line | awk '{print $1}')
        local terminal=$(echo $line | awk '{print $2}')
        local login_time=$(echo $line | awk '{print $3, $4}')
        
        # Count sessions per user
        if [ -n "${user_sessions[$username]}" ]; then
            user_sessions[$username]=$((${user_sessions[$username]} + 1))
        else
            user_sessions[$username]=1
        fi
        
        total_sessions=$((total_sessions + 1))
        
        # Display user session information
        echo "  User: $username"
        echo "    Terminal:   $terminal"
        echo "    Login Time: $login_time"
        echo ""
    done < <(who)
    
    # Display session summary
    echo -e "${CYAN}[SESSION SUMMARY]${NC}"
    echo "  Total Active Sessions: $total_sessions"
    echo ""
    
    # Identify users with multiple sessions
    echo -e "${CYAN}[USERS WITH MULTIPLE SESSIONS]${NC}"
    local multi_session_found=0
    for user in "${!user_sessions[@]}"; do
        if [ "${user_sessions[$user]}" -gt 1 ]; then
            echo "  $user: ${user_sessions[$user]} sessions"
            multi_session_found=1
        fi
    done
    
    if [ $multi_session_found -eq 0 ]; then
        echo "  No users with multiple sessions"
    fi
    
    # Show recent login history
    echo -e "\n${CYAN}[RECENT LOGIN HISTORY (Last 10)]${NC}"
    last -n 10 | grep -v "^$" | grep -v "wtmp begins" | while read -r line; do
        echo "  $line"
    done
    
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
}

################################################################################
# Description: Creates incremental backups of specified directories
# Parameters: 
#   $1 - source directory
#   $2 - backup destination
################################################################################
create_incremental_backup() {
    # Prompt for source directory
    if [ -z "$1" ]; then
        echo -e "${CYAN}Enter source directory to backup:${NC}"
        read -r source_dir
    else
        source_dir="$1"
    fi
    
    # Validate source directory exists
    if [ ! -d "$source_dir" ]; then
        echo -e "${RED}Error: Source directory does not exist!${NC}"
        return 1
    fi
    
    # Set backup destination to /backups/ in current script directory
    local script_dir="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    backup_dest="${script_dir}/backups"
    
    # Create backup destination if it doesn't exist
    if [ ! -d "$backup_dest" ]; then
        mkdir -p "$backup_dest" 2>/dev/null
        if [ $? -ne 0 ]; then
            echo -e "${RED}Error: Cannot create backup destination!${NC}"
            return 1
        fi
    fi
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}INCREMENTAL BACKUP${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    
    # Create timestamped backup directory in YYYYMMDD_HHMMSS format
    local timestamp=$(date +%Y%m%d_%H%M%S)
    local backup_dir="${backup_dest}/backup_${timestamp}"
    
    # Reference file to track last backup time
    local ref_file="${backup_dest}/.last_backup_timestamp"
    
    echo "  Source:      $source_dir"
    echo "  Destination: $backup_dir"
    echo ""
    
    # Create backup directory
    mkdir -p "$backup_dir"
    
    # Find files to backup (modified since last backup or all if first backup)
    local file_count=0
    local total_size=0
    
    if [ -f "$ref_file" ]; then
        # Incremental backup - only files newer than reference file
        echo -e "${CYAN}[Performing Incremental Backup...]${NC}"
        while IFS= read -r file; do
            # Create directory structure in backup
            local rel_path="${file#$source_dir/}"
            local target_dir="${backup_dir}/$(dirname "$rel_path")"
            mkdir -p "$target_dir"
            
            # Copy file preserving attributes
            cp -p "$file" "${backup_dir}/${rel_path}" 2>/dev/null
            if [ $? -eq 0 ]; then
                file_count=$((file_count + 1))
            fi
        done < <(find "$source_dir" -type f -newer "$ref_file" 2>/dev/null)
    else
        # Full backup - first time
        echo -e "${CYAN}[Performing Full Backup (First Time)...]${NC}"
        cp -r "$source_dir"/* "$backup_dir/" 2>/dev/null
        file_count=$(find "$backup_dir" -type f | wc -l)
    fi
    
    # Calculate backup size
    total_size=$(du -sh "$backup_dir" 2>/dev/null | awk '{print $1}')
    
    # Update reference file timestamp
    touch "$ref_file"
    
    # Display backup summary
    echo -e "\n${CYAN}[BACKUP SUMMARY]${NC}"
    echo "  Files Backed Up: $file_count"
    echo "  Total Size:      $total_size"
    echo "  Backup Location: $backup_dir"
    echo "  Timestamp:       $timestamp"
    
    if [ $file_count -eq 0 ]; then
        echo -e "\n  ${GREEN}✓ No new files to backup${NC}"
    else
        echo -e "\n  ${GREEN}✓ Backup completed successfully${NC}"
    fi
    
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
    return 0
}

################################################################################
# Function: verify_backup_integrity
# Description: Verifies backup completeness and integrity
################################################################################
verify_backup_integrity() {
    # Prompt for source directory
    echo -e "${CYAN}Enter source directory to verify:${NC}"
    read -r source_dir
    
    # Prompt for backup directory
    echo -e "${CYAN}Enter backup directory to verify:${NC}"
    read -r backup_dir
    
    # Validate directories exist
    if [ ! -d "$source_dir" ]; then
        echo -e "${RED}Error: Source directory does not exist!${NC}"
        return 1
    fi
    
    if [ ! -d "$backup_dir" ]; then
        echo -e "${RED}Error: Backup directory does not exist!${NC}"
        return 1
    fi
    
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}BACKUP INTEGRITY VERIFICATION${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    
    echo "  Source:      $source_dir"
    echo "  Backup:      $backup_dir"
    echo ""
    
    local verification_failed=0
    
    # Check backup directory accessibility
    echo -e "${CYAN}[Checking Backup Accessibility]${NC}"
    if [ -r "$backup_dir" ] && [ -x "$backup_dir" ]; then
        echo -e "  ${GREEN}✓ Backup directory is accessible${NC}"
    else
        echo -e "  ${RED}✗ Backup directory is not accessible${NC}"
        verification_failed=1
    fi
    
    # Compare file counts
    echo -e "\n${CYAN}[Comparing File Counts]${NC}"
    local source_count=$(find "$source_dir" -type f 2>/dev/null | wc -l)
    local backup_count=$(find "$backup_dir" -type f 2>/dev/null | wc -l)
    
    echo "  Source Files: $source_count"
    echo "  Backup Files: $backup_count"
    
    if [ $backup_count -ge $source_count ]; then
        echo -e "  ${GREEN}✓ File count verification passed${NC}"
    else
        echo -e "  ${RED}✗ File count mismatch detected${NC}"
        verification_failed=1
    fi
    
    # Verify most recent files exist in backup
    echo -e "\n${CYAN}[Verifying Recent Files]${NC}"
    local recent_files=$(find "$source_dir" -type f -mtime -1 2>/dev/null | head -5)
    local missing_count=0
    
    if [ -z "$recent_files" ]; then
        echo "  No recent files to verify"
    else
        while IFS= read -r file; do
            local rel_path="${file#$source_dir/}"
            if [ -f "${backup_dir}/${rel_path}" ]; then
                echo -e "  ${GREEN}✓${NC} $rel_path"
            else
                echo -e "  ${RED}✗${NC} $rel_path (missing)"
                missing_count=$((missing_count + 1))
                verification_failed=1
            fi
        done <<< "$recent_files"
    fi
    
    # Generate verification report
    echo -e "\n${CYAN}[VERIFICATION REPORT]${NC}"
    if [ $verification_failed -eq 0 ]; then
        echo -e "  Status: ${GREEN}PASS${NC}"
        echo "  All integrity checks passed successfully"
    else
        echo -e "  Status: ${RED}FAIL${NC}"
        echo "  Some integrity checks failed"
        if [ $missing_count -gt 0 ]; then
            echo "  Missing Files: $missing_count"
        fi
    fi
    
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
    return $verification_failed
}

################################################################################
# Function: generate_filesystem_report
# Description: Creates detailed filesystem usage analysis
################################################################################
generate_filesystem_report() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}FILESYSTEM USAGE REPORT${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    
    # Display disk usage by filesystem type
    echo -e "\n${CYAN}[DISK USAGE BY FILESYSTEM TYPE]${NC}"
    df -T | grep -v "tmpfs" | grep -v "Filesystem" | awk '{printf "  %-15s %-10s %8s %8s %8s %5s\n", $1, $2, $3, $4, $5, $6}'
    
    # List top 10 largest directories
    echo -e "\n${CYAN}[TOP 10 LARGEST DIRECTORIES]${NC}"
    echo "  Analyzing directories (this may take a moment)..."
    du -sh /home/* /var/* /usr/* 2>/dev/null | sort -rh | head -10 | awk '{printf "  %8s  %s\n", $1, $2}'
    
    # Identify directories with most files
    echo -e "\n${CYAN}[DIRECTORIES WITH MOST FILES]${NC}"
    echo "  Counting files in directories..."
    for dir in /home /var /usr /tmp /opt; do
        if [ -d "$dir" ]; then
            local file_count=$(find "$dir" -type f 2>/dev/null | wc -l)
            echo "  $dir: $file_count files"
        fi
    done
    
    # Calculate total space used vs available
    echo -e "\n${CYAN}[STORAGE SUMMARY]${NC}"
    local total_space=$(df -h / | awk 'NR==2 {print $2}')
    local used_space=$(df -h / | awk 'NR==2 {print $3}')
    local available_space=$(df -h / | awk 'NR==2 {print $4}')
    local usage_percent=$(df -h / | awk 'NR==2 {print $5}')
    
    echo "  Total Space:     $total_space"
    echo "  Used Space:      $used_space"
    echo "  Available Space: $available_space"
    echo "  Usage:           $usage_percent"
    
    # Additional filesystem statistics
    echo -e "\n${CYAN}[INODE USAGE]${NC}"
    df -i / | awk 'NR==2 {printf "  Total Inodes: %s\n  Used Inodes:  %s\n  Free Inodes:  %s\n  Usage:        %s\n", $2, $3, $4, $5}'
    
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
}

################################################################################
# Function: analyze_running_processes
# Description: Monitors and reports on system processes
################################################################################
analyze_running_processes() {
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${GREEN}RUNNING PROCESSES ANALYSIS${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    
    # List top 10 processes by memory usage
    echo -e "\n${CYAN}[TOP 10 PROCESSES BY MEMORY USAGE]${NC}"
    echo "  USER       PID    %MEM  COMMAND"
    ps aux --sort=-%mem | head -11 | tail -10 | awk '{printf "  %-10s %-6s %5s%%  %s\n", $1, $2, $4, $11}'
    
    # Count total processes by state
    echo -e "\n${CYAN}[PROCESSES BY STATE]${NC}"
    local running=$(ps aux | awk '$8 ~ /R/ {count++} END {print count+0}')
    local sleeping=$(ps aux | awk '$8 ~ /S/ {count++} END {print count+0}')
    local stopped=$(ps aux | awk '$8 ~ /T/ {count++} END {print count+0}')
    local zombie=$(ps aux | awk '$8 ~ /Z/ {count++} END {print count+0}')
    local total=$(ps aux | wc -l)
    total=$((total - 1))  # Subtract header line
    
    echo "  Running:  $running"
    echo "  Sleeping: $sleeping"
    echo "  Stopped:  $stopped"
    echo "  Zombie:   $zombie"
    echo "  Total:    $total"
    
    # Identify processes running longer than 24 hours
    echo -e "\n${CYAN}[LONG-RUNNING PROCESSES (>24 hours)]${NC}"
    local current_time=$(date +%s)
    local day_in_seconds=86400
    local long_running_found=0
    
    # Get process start times and calculate runtime
    ps -eo user,pid,etime,cmd --sort=-etime | tail -n +2 | while read -r line; do
        local user=$(echo $line | awk '{print $1}')
        local pid=$(echo $line | awk '{print $2}')
        local etime=$(echo $line | awk '{print $3}')
        local cmd=$(echo $line | awk '{for(i=4;i<=NF;i++) printf "%s ", $i; print ""}')
        
        # Parse elapsed time (format can be DD-HH:MM:SS or HH:MM:SS or MM:SS)
        if echo "$etime" | grep -q "-"; then
            # Format: DD-HH:MM:SS
            local days=$(echo $etime | cut -d'-' -f1)
            if [ "$days" -ge 1 ]; then
                echo "  User: $user | PID: $pid | Runtime: $etime"
                echo "    Command: $cmd"
                long_running_found=1
            fi
        fi
    done | head -10
    
    if [ $long_running_found -eq 0 ]; then
        echo "  No processes running longer than 24 hours"
    fi
    
    # Display process owner information
    echo -e "\n${CYAN}[PROCESS DISTRIBUTION BY USER]${NC}"
    ps aux | awk 'NR>1 {count[$1]++} END {for (user in count) printf "  %-15s %d processes\n", user, count[user]}' | sort -k2 -rn | head -10
    
    echo -e "\n${CYAN}═══════════════════════════════════════════════════════${NC}"
}

################################################################################
# Main Program Loop
################################################################################
main() {
    # Check if running with appropriate permissions
    if [ $EUID -ne 0 ]; then
        echo -e "${RED}Note: Some features may require root privileges for full functionality${NC}"
        sleep 2
    fi
    
    while true; do
        display_menu
        echo -n "Enter your choice [0-6]: "
        read -r choice
        
        echo ""
        
        case $choice in
            1)
                check_system_resources
                ;;
            2)
                track_user_activity
                ;;
            3)
                create_incremental_backup
                ;;
            4)
                verify_backup_integrity
                ;;
            5)
                generate_filesystem_report
                ;;
            6)
                analyze_running_processes
                ;;
            0)
                echo -e "${GREEN}Thank you for using Linux System Monitoring & Backup Utility!${NC}"
                exit 0
                ;;
            *)
                echo -e "${RED}Invalid option! Please select 0-6.${NC}"
                ;;
        esac
        
        echo ""
        echo -n "Press Enter to continue..."
        read -r
    done
}

# Start the program
main
