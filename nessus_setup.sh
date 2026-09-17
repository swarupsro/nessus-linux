#!/bin/bash

# Nessus Install / Uninstall Script
# Installs Nessus from an official Tenable package (.deb/.rpm) and removes it cleanly.
#
# Requires a valid Tenable license. Nessus Essentials is free (limited to 16 IPs)
# and does NOT require this script to bypass anything.
#
# Download the package from https://www.tenable.com/downloads/nessus (login required),
# then run:
#   sudo ./nessus_setup.sh install ./Nessus-<version>-<distro>_<arch>.deb
#   sudo ./nessus_setup.sh uninstall

set -u

RED="\033[31m"
GREEN="\033[32m"
YELLOW="\033[33m"
BLUE="\033[34m"
RESET="\033[0m"

PACKAGE_NAME="Nessus"
SERVICE_NAME="nessusd.service"

error() { echo -e "${RED}[ERROR]${RESET} $*" >&2; }
info()  { echo -e "${BLUE}[INFO]${RESET} $*"; }
ok()    { echo -e "${GREEN}[OK]${RESET} $*"; }
warn()  { echo -e "${YELLOW}[WARN]${RESET} $*"; }

require_root() {
    if [ "$(id -u)" -ne 0 ]; then
        error "Run this script as root (sudo)."
        exit 1
    fi
}

detect_distro() {
    DISTRO_ID=""
    DISTRO_LIKE=""
    if [ -f /etc/os-release ]; then
        # shellcheck disable=SC1091
        . /etc/os-release
        DISTRO_ID="${ID:-}"
        DISTRO_LIKE="${ID_LIKE:-}"
    fi
}

is_debian_family() {
    case "$DISTRO_ID $DISTRO_LIKE" in
        *debian*|*ubuntu*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

is_rhel_family() {
    case "$DISTRO_ID $DISTRO_LIKE" in
        *rhel*|*centos*|*fedora*|*rocky*|*alma*)
            return 0
            ;;
        *)
            return 1
            ;;
    esac
}

is_installed() {
    if command -v dpkg >/dev/null 2>&1; then
        dpkg -s "$PACKAGE_NAME" >/dev/null 2>&1
    elif command -v rpm >/dev/null 2>&1; then
        rpm -q "$PACKAGE_NAME" >/dev/null 2>&1
    else
        return 1
    fi
}

find_local_package() {
    local count
    count=$(ls -1 Nessus-*.deb Nessus-*.rpm 2>/dev/null | wc -l)

    if [ "$count" -eq 0 ]; then
        error "No Nessus package found in the current directory."
        error "Download it from https://www.tenable.com/downloads/nessus and pass the path:"
        error "  $0 install ./Nessus-<version>-<distro>_<arch>.deb"
        exit 1
    fi

    if [ "$count" -gt 1 ]; then
        error "Multiple Nessus packages found. Specify one explicitly:"
        ls -1 Nessus-*.deb Nessus-*.rpm 2>/dev/null
        exit 1
    fi

    ls -1 Nessus-*.deb Nessus-*.rpm 2>/dev/null
}

open_firewall() {
    if command -v ufw >/dev/null 2>&1 && ufw status >/dev/null 2>&1; then
        info "Opening port 8834/tcp via ufw..."
        ufw allow 8834/tcp >/dev/null 2>&1 && ok "Firewall rule added (ufw)."
    elif command -v firewall-cmd >/dev/null 2>&1 && firewall-cmd --state >/dev/null 2>&1; then
        info "Opening port 8834/tcp via firewalld..."
        firewall-cmd --permanent --add-port=8834/tcp >/dev/null 2>&1
        firewall-cmd --reload >/dev/null 2>&1
        ok "Firewall rule added (firewalld)."
    else
        info "No ufw/firewalld detected, skipping firewall configuration."
    fi
}

do_install() {
    require_root
    detect_distro

    local package="${1:-}"
    if [ -z "$package" ]; then
        package=$(find_local_package)
    fi

    if [ ! -f "$package" ]; then
        error "Package not found: $package"
        exit 1
    fi

    if is_installed; then
        warn "Nessus appears to be already installed. Use 'uninstall' first if you want a clean install."
    fi

    case "$package" in
        *.deb)
            if ! command -v dpkg >/dev/null 2>&1; then
                error "dpkg not found. This package requires a Debian/Ubuntu system."
                exit 1
            fi
            info "Installing $package ..."
            dpkg -i "$package"
            ;;
        *.rpm)
            if ! command -v rpm >/dev/null 2>&1; then
                error "rpm not found. This package requires a RHEL/CentOS/Rocky/Alma system."
                exit 1
            fi
            info "Installing $package ..."
            rpm -ivh "$package"
            ;;
        *)
            error "Unsupported package type: $package (expected .deb or .rpm)"
            exit 1
            ;;
    esac

    info "Enabling and starting Nessus service..."
    systemctl enable "$SERVICE_NAME" >/dev/null 2>&1
    systemctl start "$SERVICE_NAME"

    open_firewall

    echo ""
    ok "Nessus installed and started."
    info "Complete the setup in your browser:"
    info "  https://<server-ip>:8834"
    info "Then register with your Tenable license (Nessus Essentials is free)."
}

do_uninstall() {
    require_root
    detect_distro

    local purge_user=false
    if [ "${1:-}" = "--purge" ]; then
        purge_user=true
    fi

    info "Stopping and disabling Nessus service..."
    systemctl stop "$SERVICE_NAME" 2>/dev/null
    systemctl disable "$SERVICE_NAME" 2>/dev/null

    if command -v dpkg >/dev/null 2>&1 && dpkg -s "$PACKAGE_NAME" >/dev/null 2>&1; then
        info "Removing package via dpkg..."
        dpkg -r "$PACKAGE_NAME"
    elif command -v rpm >/dev/null 2>&1 && rpm -q "$PACKAGE_NAME" >/dev/null 2>&1; then
        info "Removing package via rpm..."
        rpm -e "$PACKAGE_NAME"
    else
        warn "Nessus package is not installed, continuing cleanup."
    fi

    if [ -d /opt/nessus ]; then
        info "Removing /opt/nessus ..."
        rm -rf /opt/nessus
        ok "Removed /opt/nessus."
    else
        info "/opt/nessus not present, skipping."
    fi

    if [ "$purge_user" = true ]; then
        if id -u nessus >/dev/null 2>&1; then
            info "Removing 'nessus' user..."
            userdel nessus 2>/dev/null
        fi
        if getent group nessus >/dev/null 2>&1; then
            info "Removing 'nessus' group..."
            groupdel nessus 2>/dev/null
        fi
    fi

    echo ""
    ok "Nessus uninstalled."
    [ "$purge_user" = true ] && info "System user/group were also removed."
}

do_status() {
    detect_distro

    echo -e "${BLUE}Nessus status${RESET}"
    echo "----------------------------------------"

    if is_installed; then
        ok "Package: installed"
    else
        warn "Package: not installed"
    fi

    if systemctl is-active --quiet "$SERVICE_NAME" 2>/dev/null; then
        ok "Service: running"
    else
        warn "Service: not running"
    fi

    systemctl is-enabled --quiet "$SERVICE_NAME" 2>/dev/null \
        && ok "Service: enabled at boot" \
        || warn "Service: not enabled at boot"

    echo "----------------------------------------"
    info "Web interface: https://<server-ip>:8834"
}

show_help() {
    echo -e "${BLUE}Nessus Install / Uninstall Script${RESET}"
    echo ""
    echo "Usage:"
    echo "  $0 install [package]   Install Nessus from a .deb/.rpm package"
    echo "  $0 uninstall [--purge] Uninstall Nessus (--purge also removes the nessus user/group)"
    echo "  $0 status              Show installation and service status"
    echo "  $0 --help              Show this help"
    echo ""
    echo "Examples:"
    echo "  sudo $0 install ./Nessus-10.8.3-debian12_amd64.deb"
    echo "  sudo $0 uninstall"
    echo "  sudo $0 uninstall --purge"
    echo ""
    echo "Note:"
    echo "  Download the official package from https://www.tenable.com/downloads/nessus"
    echo "  (login required). This script does not bypass licensing."
}

main() {
    case "${1:-}" in
        install)
            do_install "${2:-}"
            ;;
        uninstall)
            do_uninstall "${2:-}"
            ;;
        status)
            do_status
            ;;
        -h|--help|help)
            show_help
            ;;
        *)
            show_help
            exit 1
            ;;
    esac
}

main "$@"
