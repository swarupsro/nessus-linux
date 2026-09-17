# Nessus Complete Crack Script

This is a Shell script used to bypass Nessus online authentication and obtain full scanning functionality. The script automatically downloads the latest plugin package, configures the required files, and starts the Nessus service.

## Features

- Automatically download the latest Nessus plugin package
- Bypass Nessus online authentication restrictions
- Configure the plugin_feed_info.inc file
- Automatically install and update plugins
- Provide detailed log output and debugging information
- Support silent mode and debug mode

## System Requirements

- Linux operating system
- Nessus scanner installed
- sudo privileges (if not root)
- curl, systemctl and other basic commands installed

## Usage

### Basic Usage

```bash
# Make the script executable
chmod +x nessus_crack_complete.sh

# Run the script
sudo ./nessus_crack_complete.sh
```

### Command-Line Options

```bash
# Show help message
./nessus_crack_complete.sh -h or ./nessus_crack_complete.sh --help

# Silent mode (automatically downloads the plugin package and runs updates without user interaction)
./nessus_crack_complete.sh -s or ./nessus_crack_complete.sh --silent

# Force-download the plugin package (even if the file exists and is not expired)
./nessus_crack_complete.sh -f or ./nessus_crack_complete.sh --force

# Enable debug mode (output detailed debugging information)
./nessus_crack_complete.sh -d or ./nessus_crack_complete.sh --debug

# Combine multiple options
./nessus_crack_complete.sh -s -d  # Silent mode + debug mode
```

## Script Execution Flow

1. **Environment Check**: Check whether Nessus is installed; install it and configure a username/password yourself. Registration is not required.
2. **Create Config File**: Check and create the built-in plugin_feed_info.inc file
3. **Plugin Version Check**: Check the current plugin version
4. **File Check**: Check whether the required crack files exist
5. **Stop Service**: Stop the Nessus service
6. **Directory Cleanup**: Clean and recreate the plugin directory (original files are not backed up)
7. **Plugin Update**: Download and update the plugin package, running the nessuscli update command
8. **Permission Setting**: Set plugin files read-only
9. **Config File**: Configure the plugin_feed_info.inc file (directly replace the original file)
10. **Start Service**: Start the Nessus service

## Important Notes

### About File Backup

- **Original system files are not backed up**: The script directly deletes the original plugin_feed_info.inc file and plugins directory without any backup
- **Plugin Upgrade Command**: The script runs `/opt/nessus/sbin/nessuscli update "$PLUGINS_FILE"` to upgrade plugins

### Logging and Debugging

- The script generates detailed logs, including the execution time of each step
- Use `-d` or `--debug` to enable debug mode and get more detailed execution information
- Log files are saved in the script's execution directory for easier troubleshooting

### Cautions

1. **Permission Requirements**: The script needs root or sudo privileges to modify Nessus system files
2. **Service Interruption**: The Nessus service will be stopped and restarted during execution; run the script at an appropriate time
3. **Plugin Update**: The plugin update may take a long time; please be patient. If the update fails, the link may be invalid — update the download link in the curl section of the script yourself, or download the file and place it in the directory yourself.
4. **Network Connection**: A stable network connection is required to download the plugin package


## FAQ

### Q: What should I do if the script fails?

A: Check the following:
- Make sure Nessus is installed
- Make sure you have sufficient privileges (use sudo)
- Check whether the network connection is working
- Use the `-d` option to enable debug mode and view detailed error information

### Q: What should I do if the plugin update fails?

A: Possible causes and solutions:
- Check whether the plugin package file was fully downloaded
- Try using the `-f` option to force re-download of the plugin package
- Manually run `/opt/nessus/sbin/nessuscli update "plugin package path"`

### Q: How do I verify the crack was successful?

A: After a successful crack, you should be able to:
- Use all of Nessus's scanning features without logging in
- See that plugins are updated to the latest version
- See the "ProfessionalFeed (Direct)" plugin feed in the Nessus Web interface

## File Structure

```
nessus_crack_complete.sh    # Main script file
plugin_feed_info.inc        # Plugin config file (created automatically by the script)
```

## Changelog

- v1.0: Initial version with basic crack functionality
- v2.0: Added safe file operations and detailed logging
- v3.0: Added debug mode and plugin upgrade command; original system files are no longer backed up

## Disclaimer

This script is for learning and research purposes only. Users must comply with local laws and regulations and must not use this script for any illegal purpose. The author is not responsible for any consequences arising from the use of this script.

## License

MIT License
