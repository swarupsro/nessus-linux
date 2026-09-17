#!/bin/bash

# Nessus Complete Crack Script
# This script performs offline registration, plugin updates and configuration changes to bypass authentication and obtain full scanning functionality

# Check if running as root
if [ "$(id -u)" -ne 0 ]; then
    echo "Error: Please run this script as root"
    exit 1
fi

# Define color variables
RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

# Define file path variables
PLUGINS_FILE="./all-2.0.tar.gz"
PLUGIN_FEED_FILE="./plugin_feed_info.inc"

# Silent mode flag
SILENT_MODE=false
# Force download flag
FORCE_DOWNLOAD=false

# Record script start time
SCRIPT_START_TIME=$(date +%s)

# Timing function
log_step_time() {
    local step_name="$1"
    local step_start_time="$2"
    local current_time=$(date +%s)
    local step_duration=$((current_time - step_start_time))
    local total_duration=$((current_time - SCRIPT_START_TIME))
    
    echo -e "${BLUE}[Timing] $step_name: ${step_duration}s (Total: ${total_duration}s)${RESET}"
}

# Print welcome message
print_welcome() {
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${GREEN}"
        echo "=================================================="
        echo "|                                                |"
        echo "|            Nessus Complete Crack Script         |"
        echo "|       Bypass online authentication to get      |"
        echo "|              full scanning functionality        |"
        echo "=================================================="
        echo -e "${RESET}"
    else
        echo -e "${GREEN}Silent mode: Nessus Complete Crack Script${RESET}"
    fi
}

# Check if Nessus is installed
check_nessus_installed() {
    if [ ! -d "/opt/nessus" ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${RED}Error: Nessus installation not detected. Please install Nessus first.${RESET}"
        else
            echo -e "${RED}Silent mode: Error: Nessus installation not detected. Please install Nessus first.${RESET}"
        fi
        exit 1
    fi
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${GREEN}✓ Nessus installation detected${RESET}"
    else
        echo -e "${GREEN}Silent mode: Nessus installation detected${RESET}"
    fi
}

# Check required files
check_required_files() {
    local step_start_time=$(date +%s)
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}Checking required crack files...${RESET}"
    fi
    
    # Check plugin package file
    if [ ! -f "$PLUGINS_FILE" ] || [ "$FORCE_DOWNLOAD" = true ]; then
        if [ "$FORCE_DOWNLOAD" = true ] && [ -f "$PLUGINS_FILE" ]; then
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${YELLOW}Force mode: Re-downloading plugin package file...${RESET}"
            else
                echo -e "${BLUE}Silent mode: Force re-downloading plugin package file...${RESET}"
            fi
        elif [ ! -f "$PLUGINS_FILE" ]; then
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${YELLOW}Warning: Plugin package file does not exist: $PLUGINS_FILE${RESET}"
                echo -e "${YELLOW}Do you want to download the plugin package file? (y/n)${RESET}"
                read -r download_choice
            else
                echo -e "${BLUE}Silent mode: Automatically downloading plugin package file...${RESET}"
                download_choice="y"
            fi
        fi
        
        if [[ "$download_choice" =~ ^[Yy]$ ]] || [ "$FORCE_DOWNLOAD" = true ]; then
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${BLUE}Downloading plugin package file...${RESET}"
            else
                echo -e "${BLUE}Silent mode: Downloading plugin package file...${RESET}"
            fi
            curl -A Mozilla -o "$PLUGINS_FILE" --url "https://plugins.nessus.org/v2/nessus.php?f=all-2.0.tar.gz&u=56b33ade57c60a01058b1506999a2431&p=1ee9c89d5379a119a56498f2d5dff674"
            if [ $? -eq 0 ]; then
                if [ "$SILENT_MODE" = false ]; then
                    echo -e "${GREEN}✓ Plugin package file downloaded successfully${RESET}"
                else
                    echo -e "${GREEN}Silent mode: Plugin package file downloaded successfully${RESET}"
                fi
            else
                if [ "$SILENT_MODE" = false ]; then
                    echo -e "${RED}Error: Plugin package file download failed${RESET}"
                else
                    echo -e "${RED}Silent mode: Plugin package file download failed, exiting${RESET}"
                fi
                exit 1
            fi
        else
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${RED}Error: Missing required files, cannot continue${RESET}"
            fi
            exit 1
        fi
    else
        # Check file date
        file_date=$(stat -c %Y "$PLUGINS_FILE" 2>/dev/null)
        current_date=$(date +%s)
        days_diff=$(( (current_date - file_date) / 86400 ))
        
        if [ $days_diff -gt 15 ]; then
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${YELLOW}Warning: Plugin package file exists but is over 15 days old (${days_diff} days)${RESET}"
                echo -e "${YELLOW}Do you want to re-download the plugin package file? (y/n)${RESET}"
                read -r redownload_choice
            else
                echo -e "${BLUE}Silent mode: Plugin package file is over 15 days old, automatically re-downloading...${RESET}"
                redownload_choice="y"
            fi
            
            if [[ "$redownload_choice" =~ ^[Yy]$ ]]; then
                if [ "$SILENT_MODE" = false ]; then
                    echo -e "${BLUE}Re-downloading plugin package file...${RESET}"
                else
                    echo -e "${BLUE}Silent mode: Re-downloading plugin package file...${RESET}"
                fi
                curl -A Mozilla -o "$PLUGINS_FILE" --url "https://plugins.nessus.org/v2/nessus.php?f=all-2.0.tar.gz&u=29fc85234e4cd7e636ae8e9232c55313&p=33e0396a01619108b7be1bb78954c458"
                if [ $? -eq 0 ]; then
                    if [ "$SILENT_MODE" = false ]; then
                        echo -e "${GREEN}✓ Plugin package file re-downloaded successfully${RESET}"
                    else
                        echo -e "${GREEN}Silent mode: Plugin package file re-downloaded successfully${RESET}"
                    fi
                else
                    if [ "$SILENT_MODE" = false ]; then
                        echo -e "${RED}Error: Plugin package file re-download failed, using existing file${RESET}"
                    else
                        echo -e "${YELLOW}Silent mode: Plugin package file re-download failed, using existing file${RESET}"
                    fi
                fi
            fi
        else
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${GREEN}✓ Plugin package file check passed (created ${days_diff} days ago)${RESET}"
            else
                echo -e "${GREEN}Silent mode: Plugin package file check passed (created ${days_diff} days ago)${RESET}"
            fi
        fi
    fi
    
    # Check plugin_feed_info.inc file
    if [ ! -f "$PLUGIN_FEED_FILE" ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${RED}Error: plugin_feed_info.inc file does not exist: $PLUGIN_FEED_FILE${RESET}"
            echo -e "${YELLOW}Please make sure plugin_feed_info.inc is in the current directory${RESET}"
        else
            echo -e "${RED}Silent mode: Error: plugin_feed_info.inc file does not exist: $PLUGIN_FEED_FILE${RESET}"
        fi
        exit 1
    fi
    
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${GREEN}✓ All required files check passed${RESET}"
        echo -e "${BLUE}Using plugin package: $PLUGINS_FILE${RESET}"
        echo -e "${BLUE}Using config file: $PLUGIN_FEED_FILE${RESET}"
    else
        echo -e "${GREEN}Silent mode: All required files check passed${RESET}"
    fi
    
    log_step_time "Checking required files" "$step_start_time"
}

# Stop Nessus service
stop_nessus_service() {
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}Stopping Nessus service...${RESET}"
    else
        echo -e "${BLUE}Silent mode: Stopping Nessus service...${RESET}"
    fi
    systemctl stop nessusd.service > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${GREEN}✓ Nessus service stopped${RESET}"
        else
            echo -e "${GREEN}Silent mode: Nessus service stopped${RESET}"
        fi
    else
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${YELLOW}Warning: Cannot stop Nessus service, it may already be stopped${RESET}"
        else
            echo -e "${YELLOW}Silent mode: Cannot stop Nessus service, it may already be stopped${RESET}"
        fi
    fi
}



# Clean existing plugin directory
clean_plugin_directory() {
    local step_start_time=$(date +%s)
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}Cleaning existing plugin directory...${RESET}"
    else
        echo -e "${BLUE}Silent mode: Cleaning existing plugin directory...${RESET}"
    fi
    
    # Stop Nessus service (ensure no process is using plugins)
    systemctl stop nessusd.service > /dev/null 2>&1
      
    # Remove immutable attribute from directory and its contents (if present)
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${YELLOW}Cleaning current plugin directory...${RESET}"
    fi
    find /opt/nessus/lib/nessus/plugins/ -type f -exec chattr -i {} \; > /dev/null 2>&1
    chattr -i /opt/nessus/lib/nessus/plugins > /dev/null 2>&1
    
    # Remove the entire plugin directory
    rm -rf /opt/nessus/lib/nessus/plugins > /dev/null 2>&1
    if [ $? -eq 0 ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${GREEN}✓ Plugin directory removed successfully${RESET}"
        else
            echo -e "${GREEN}Silent mode: Plugin directory removed successfully${RESET}"
        fi
    else
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${YELLOW}Warning: Plugin directory removal may be incomplete, trying forced removal...${RESET}"
        else
            echo -e "${YELLOW}Silent mode: Plugin directory removal may be incomplete, trying forced removal...${RESET}"
        fi
        # Try forced removal using find command
        find /opt/nessus/lib/nessus/ -name "plugins" -type d -exec rm -rf {} \; > /dev/null 2>&1
    fi
    
    # Recreate plugin directory
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${YELLOW}Recreating plugin directory...${RESET}"
    fi
    mkdir -p /opt/nessus/lib/nessus/plugins
    
    # Set correct directory permissions
    chown -R nessus:nessus /opt/nessus/lib/nessus/plugins > /dev/null 2>&1
    chmod 755 /opt/nessus/lib/nessus/plugins > /dev/null 2>&1
    
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${GREEN}✓ Plugin directory recreated${RESET}"
    else
        echo -e "${GREEN}Silent mode: Plugin directory recreated${RESET}"
    fi
    
    log_step_time "Cleaning plugin directory" "$step_start_time"
}

# Offline plugin update
update_plugins() {
    local step_start_time=$(date +%s)
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}Updating plugins...${RESET}"
        echo -e "${YELLOW}Note: This process may take a while, please be patient...${RESET}"
    else
        echo -e "${BLUE}Silent mode: Updating plugins...${RESET}"
    fi
    /opt/nessus/sbin/nessuscli update "$PLUGINS_FILE"
    if [ $? -eq 0 ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${GREEN}✓ Plugin update succeeded${RESET}"
        else
            echo -e "${GREEN}Silent mode: Plugin update succeeded${RESET}"
        fi
    else
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${RED}Error: Plugin update failed${RESET}"
        else
            echo -e "${RED}Silent mode: Plugin update failed${RESET}"
        fi
        exit 1
    fi
    
    log_step_time "Updating plugins" "$step_start_time"
}

# Set plugin files to read-only
set_plugins_readonly() {
    local step_start_time=$(date +%s)
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}Setting plugin files to read-only...${RESET}"
        echo -e "${YELLOW}Note: This process may take a while because there are over 150,000 plugins...${RESET}"
    else
        echo -e "${BLUE}Silent mode: Setting plugin files to read-only...${RESET}"
    fi
    find /opt/nessus/lib/nessus/plugins/ -name "*.*" | xargs -i chattr +i {}
    if [ $? -eq 0 ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${GREEN}✓ Plugin files set to read-only${RESET}"
        else
            echo -e "${GREEN}Silent mode: Plugin files set to read-only${RESET}"
        fi
    else
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${RED}Error: Failed to set plugin files read-only${RESET}"
        else
            echo -e "${RED}Silent mode: Failed to set plugin files read-only${RESET}"
        fi
        exit 1
    fi
    
    log_step_time "Setting plugin files read-only" "$step_start_time"
}

# Remove read-only attribute from plugin_feed_info.inc
unset_plugin_feed_readonly() {
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}Removing read-only attribute from plugin_feed_info.inc...${RESET}"
    else
        echo -e "${BLUE}Silent mode: Removing read-only attribute from plugin_feed_info.inc...${RESET}"
    fi
    # Check if file exists
    if [ -f "/opt/nessus/lib/nessus/plugins/plugin_feed_info.inc" ]; then
        chattr -i /opt/nessus/lib/nessus/plugins/plugin_feed_info.inc  > /dev/null 2>&1
		rm -f /opt/nessus/lib/nessus/plugins/plugin_feed_info.inc  > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${GREEN}✓ Read-only attribute removed from plugin_feed_info.inc${RESET}"
            else
                echo -e "${GREEN}Silent mode: Read-only attribute removed from plugin_feed_info.inc${RESET}"
            fi
        else
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${YELLOW}Warning: Cannot remove read-only attribute from plugin_feed_info.inc${RESET}"
            else
                echo -e "${YELLOW}Silent mode: Cannot remove read-only attribute from plugin_feed_info.inc${RESET}"
            fi
        fi
    else
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${YELLOW}Note: plugin_feed_info.inc does not exist, skipping read-only removal${RESET}"
        else
            echo -e "${YELLOW}Silent mode: plugin_feed_info.inc does not exist, skipping read-only removal${RESET}"
        fi
    fi
}

# Get PLUGIN_SET value
get_plugin_set() {
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}Getting PLUGIN_SET from plugin_feed_info.inc in the current directory...${RESET}"
    else
        echo -e "${BLUE}Silent mode: Getting PLUGIN_SET from plugin_feed_info.inc in the current directory...${RESET}"
    fi
    if [ -f "$PLUGIN_FEED_FILE" ]; then
        PLUGIN_SET=$(grep "PLUGIN_SET" "$PLUGIN_FEED_FILE" | sed 's/PLUGIN_SET = "\(.*\)";/\1/')
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${GREEN}✓ Got PLUGIN_SET: $PLUGIN_SET${RESET}"
        else
            echo -e "${GREEN}Silent mode: Got PLUGIN_SET: $PLUGIN_SET${RESET}"
        fi
    else
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${RED}Error: Cannot find plugin_feed_info.inc in the current directory${RESET}"
        else
            echo -e "${RED}Silent mode: Error: Cannot find plugin_feed_info.inc in the current directory${RESET}"
        fi
        exit 1
    fi
}

# Configure plugin_feed_info.inc file
configure_plugin_feed_files() {
    local step_start_time=$(date +%s)
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}Configuring plugin_feed_info.inc file...${RESET}"
    else
        echo -e "${BLUE}Silent mode: Configuring plugin_feed_info.inc file...${RESET}"
    fi
    
    # Ensure directories exist and set correct permissions
    mkdir -p /opt/nessus/lib/nessus/plugins
    mkdir -p /opt/nessus/var/nessus/plugins
	chattr -i /opt/nessus/lib/nessus/plugins/plugin_feed_info.inc
	chattr -i /opt/nessus/var/nessus/plugin_feed_info.inc
 	rm -f /opt/nessus/lib/nessus/plugins/plugin_feed_info.inc
	rm -f /opt/nessus/var/nessus/plugin_feed_info.inc   
    # Copy plugin_feed_info.inc from current directory to system location
    cp "$PLUGIN_FEED_FILE" /opt/nessus/lib/nessus/plugins/plugin_feed_info.inc  > /dev/null 2>&1
    if [ $? -ne 0 ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${RED}Error: Cannot copy file to /opt/nessus/lib/nessus/plugins/, retrying after fixing permissions${RESET}"
        else
            echo -e "${RED}Silent mode: Cannot copy file to /opt/nessus/lib/nessus/plugins/, retrying after fixing permissions${RESET}"
        fi
        chmod 755 /opt/nessus/lib/nessus/plugins
        cp "$PLUGIN_FEED_FILE" /opt/nessus/lib/nessus/plugins/plugin_feed_info.inc  > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${RED}Error: Still cannot copy file, please check permissions${RESET}"
            else
                echo -e "${RED}Silent mode: Still cannot copy file, please check permissions${RESET}"
            fi
            exit 1
        fi
    fi
    
    # Try copying to /var/nessus directory
    cp "$PLUGIN_FEED_FILE" /opt/nessus/var/nessus/plugin_feed_info.inc
    if [ $? -ne 0 ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${YELLOW}Warning: Cannot copy file to /opt/nessus/var/nessus/, retrying after fixing permissions${RESET}"
        else
            echo -e "${YELLOW}Silent mode: Cannot copy file to /opt/nessus/var/nessus/, retrying after fixing permissions${RESET}"
        fi
        chmod 755 /opt/nessus/var/nessus
        cp "$PLUGIN_FEED_FILE" /opt/nessus/var/nessus/plugin_feed_info.inc > /dev/null 2>&1
        if [ $? -ne 0 ]; then
            if [ "$SILENT_MODE" = false ]; then
                echo -e "${YELLOW}Warning: Still cannot copy file to /var/nessus, but continuing${RESET}"
            else
                echo -e "${YELLOW}Silent mode: Still cannot copy file to /var/nessus, but continuing${RESET}"
            fi
        fi
    fi
    
    # Set the file read-only (if copy succeeded)
    if [ -f "/opt/nessus/var/nessus/plugin_feed_info.inc" ]; then
        chattr +i /opt/nessus/var/nessus/plugin_feed_info.inc  > /dev/null 2>&1
    fi
    
    # Create plugins directory and copy file
    cd /opt/nessus/var/nessus/
    mkdir -p plugins
    cp plugin_feed_info.inc plugins/ 2>/dev/null
    
    # Set correct file ownership
    chown -R nessus:nessus /opt/nessus/lib/nessus/plugins > /dev/null 2>&1
    chown -R nessus:nessus /opt/nessus/var/nessus > /dev/null 2>&1
    
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${GREEN}✓ Config file modification complete${RESET}"
    else
        echo -e "${GREEN}Silent mode: Config file modification complete${RESET}"
    fi
    
    log_step_time "Configuring plugin_feed_info.inc file" "$step_start_time"
}

# Start Nessus service
start_nessus_service() {
    if [ "$SILENT_MODE" = false ]; then
        echo -e "${BLUE}Starting Nessus service...${RESET}"
    else
        echo -e "${BLUE}Silent mode: Starting Nessus service...${RESET}"
    fi
    systemctl start nessusd.service
    if [ $? -eq 0 ]; then
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${GREEN}✓ Nessus service started${RESET}"
        else
            echo -e "${GREEN}Silent mode: Nessus service started${RESET}"
        fi
    else
        if [ "$SILENT_MODE" = false ]; then
            echo -e "${RED}Error: Cannot start Nessus service${RESET}"
            echo -e "${YELLOW}Try starting Nessus service manually: systemctl start nessusd${RESET}"
        else
            echo -e "${RED}Silent mode: Cannot start Nessus service${RESET}"
        fi
    fi
}

# Show completion info
show_completion_info() {
    local step_start_time=$(date +%s)
    local total_duration=$((step_start_time - SCRIPT_START_TIME))
    local minutes=$((total_duration / 60))
    local seconds=$((total_duration % 60))
    
    if [ "$SILENT_MODE" = false ]; then
        echo -e "\n${GREEN}==================================================${RESET}"
        echo -e "${GREEN}Nessus crack completed!${RESET}"
        echo -e "${YELLOW}Note: Please wait a few minutes for Nessus to fully load all plugins.${RESET}"
        
        # Get local IP address
        LOCAL_IP=$(ip route get 1 | awk '{print $7}' | head -1)
        if [ -z "$LOCAL_IP" ]; then
            # If the above fails, try another method
            LOCAL_IP=$(hostname -I | awk '{print $1}')
        fi
        if [ -z "$LOCAL_IP" ]; then
            # If still unavailable, use localhost
            LOCAL_IP="localhost"
        fi
        
        echo -e "${BLUE}Visit ${RED}https://$LOCAL_IP:8834 ${BLUE}to log in to the Nessus Web interface${RESET}"
        
        # Show total execution time
        echo -e "\n${BLUE}==================== Execution Time Statistics ====================${RESET}"
        echo -e "${GREEN}Total execution time: ${minutes}m${seconds}s (${total_duration}s)${RESET}"
        echo -e "${GREEN}==================================================${RESET}\n"
    else
        echo -e "\n${GREEN}Silent mode: Nessus crack completed!${RESET}"
        echo -e "${BLUE}Silent mode: Total execution time: ${minutes}m${seconds}s (${total_duration}s)${RESET}"
    fi
}

# Show help info
show_help() {
    echo -e "${BLUE}Nessus Offline Crack Script${RESET}"
    echo -e "${BLUE}===================${RESET}"
    echo ""
    echo -e "${YELLOW}Usage: $0 [options]${RESET}"
    echo ""
    echo -e "${YELLOW}Options:${RESET}"
    echo -e "  -h, --help    Show this help message"
    echo -e "  -s, --silent  Silent mode, automatically download plugin package and run updates"
    echo -e "  -f, --force   Force download plugin package even if the file exists and is not expired"
    echo ""
    echo -e "${YELLOW}Features:${RESET}"
    echo "  - Automatically check and download plugin package file (if missing or over 15 days old)"
    echo "  - Clean and recreate plugin directory"
    echo "  - Update plugins"
    echo "  - Set plugin files read-only"
    echo "  - Configure plugin_feed_info.inc file"
    echo "  - Automatically manage Nessus service"
    echo ""
    echo -e "${YELLOW}Required files:${RESET}"
    echo "  - plugin_feed_info.inc (Nessus config file)"
    echo "  - all-2.0.tar.gz (plugin package file; prompts to download if missing)"
    echo ""
    echo -e "${YELLOW}Notes:${RESET}"
    echo "  - The script skips the offline registration step; make sure Nessus is properly registered"
    echo "  - For manual registration, use: /opt/nessus/sbin/nessuscli fetch --register <license file>"
    echo "  - Make sure plugin_feed_info.inc exists in the script's directory"
    echo "  - If the plugin package file is missing or over 15 days old, the script will prompt whether to download it"
    echo "  - In silent mode, the script automatically downloads the plugin package and runs all update steps"
    echo "  - Silent mode is suitable for automated deployment scenarios"
    echo "  - Force download mode ignores file existence and time checks and re-downloads directly"
    echo ""
    echo -e "${YELLOW}Examples:${RESET}"
    echo "  $0                    # Run the full flow"
    echo "  $0 --help             # Show this help message"
    echo "  $0 --silent           # Run in silent mode"
    echo "  $0 --silent --force   # Silent mode with forced plugin package download"
}

# Parse command-line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_help
                exit 0
                ;;
            -s|--silent)
                SILENT_MODE=true
                shift
                ;;
            -f|--force)
                FORCE_DOWNLOAD=true
                shift
                ;;
            *)
                echo -e "${RED}Unknown argument: $1${RESET}"
                show_help
                exit 1
                ;;
        esac
    done
}

# Main function
main() {
    print_welcome
    parse_args "$@"
    check_nessus_installed
    check_required_files
    stop_nessus_service
    clean_plugin_directory
    update_plugins
    set_plugins_readonly
    unset_plugin_feed_readonly
    get_plugin_set
    configure_plugin_feed_files
    start_nessus_service
    show_completion_info
}

# Execute main function
main "$@"
