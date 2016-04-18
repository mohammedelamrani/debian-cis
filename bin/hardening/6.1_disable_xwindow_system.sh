#!/bin/bash

#
# CIS Debian 7 Hardening
#

#
# 6.1 Ensure the X Window system is not installed (Scored)
#

set -e # One error, it's over
set -u # One variable unset, it's over

# Based on aptitude search '~Pxserver'
PACKAGES='xserver-xorg-core xserver-xorg-core-dbg xserver-common xserver-xephyr xserver-xfbdev tightvncserver vnc4server fglrx-driver xvfb xserver-xorg-video-nvidia-legacy-173xx xserver-xorg-video-nvidia-legacy-96xx xnest'

# This function will be called if the script status is on enabled / audit mode
audit () {
    for PACKAGE in $PACKAGES; do
        is_pkg_installed $PACKAGE
        if [ $FNRET = 0 ]; then
            crit "$PACKAGE is installed !"
        else
            ok "$PACKAGE is absent"
        fi
    done
}

# This function will be called if the script status is on enabled mode
apply () {
    for PACKAGE in $PACKAGES; do
        is_pkg_installed $PACKAGE
        if [ $FNRET = 0 ]; then
            crit "$PACKAGE is installed, purging it"
            apt-get purge $PACKAGE -y
            apt-get autoremove
        else
            ok "$PACKAGE is absent"
        fi
    done
}

# This function will check config parameters required
check_config() {
    :
}

# Source Root Dir Parameter
if [ ! -r /etc/default/cis-hardening ]; then
    echo "There is no /etc/default/cis-hardening file, cannot source CIS_ROOT_DIR variable, aborting"
    exit 128
else
    . /etc/default/cis-hardening
    if [ -z $CIS_ROOT_DIR ]; then
        echo "No CIS_ROOT_DIR variable, aborting"
    fi
fi 

# Main function, will call the proper functions given the configuration (audit, enabled, disabled)
[ -r $CIS_ROOT_DIR/lib/main.sh ] && . $CIS_ROOT_DIR/lib/main.sh