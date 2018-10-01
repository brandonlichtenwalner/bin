#!/bin/bash

### Get a system up and running with the stuff I typically use for my work machine
### Trying to keep it fairly generic for different flavors of Ubuntu
### Updated for Ubuntu 18.04

## This script should be run with my main user account, which is assumed to have sudo privileges.

## Getting started on a new host:
##   restore backup of saved home directory files, most notably .ssh directory
##   git clone git@github.com:brandonlichtenwalner/bin.git
##   cd ~
##   ~/bin/scripts/ubuntu_customize.sh

# TODO: configure and pull down stuff from gitlab.umbctraining.com

echo "Would you like to install qemu-kvm and virt-manager? [Y/n]"
read add_kvm

echo "Would you like to install Google Chrome? [Y/n]"
read add_chrome

echo "Answer 'no' if connected to Training Centers Corporate network. Need to fix support.umbctraining.com from inside."
echo "Would you like to install SimpleHelp? [Y/n]"
read add_simplehelp

# add etcher repo
echo "deb https://dl.bintray.com/resin-io/debian stable etcher" | sudo tee /etc/apt/sources.list.d/etcher.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61

echo "Update repos, run an apt full-upgrade, and clean up..."
sudo apt -y update
sudo apt -y full-upgrade

# install additional commonly used desktop packages
echo "Installing the usual packages..."
sudo apt -y install etcher-electron exfat-utils filezilla freeplane git hyphen-en-us libreoffice-calc libreoffice-gnome libreoffice-impress libreoffice-pdfimport libreoffice-writer meld mythes-en-us p7zip-full remmina-plugin-spice transmission-gtk vim virtualbox-ext-pack virtualbox-guest-additions-iso

echo "Installing TLP and related packages..."
sudo apt -y install --no-install-recommends tlp smartmontools
sudo apt -y install tlp-rdw linux-tools-generic

echo "Pulling down Mind Maps repo..."
git clone git@github.com:brandonlichtenwalner/maps.git

echo "Fixing permissions on copied hidden directories..."
chmod go-rwx .putty
chmod go-rwx .remmina
chmod go-rwx .ssh
chmod go-rwx .tc_config

# Install Qemu/KVM (or not)
if [ "${add_kvm,,}" != "n" ] && [ "${add_kvm,,}" != "no" ]; then
	sudo apt -y install bridge-utils qemu-kvm virt-manager
fi

# Install Google Chrome (or not)
if [ "${add_chrome,,}" != "n" ] && [ "${add_chrome,,}" != "no" ]; then
	echo "Downloading latest Google Chrome package..."
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	echo "Using dpkg to install Google Chrome..."
	sudo dpkg -i google-chrome-stable_current_amd64.deb
	echo "Fixing Google Chrome install via apt..."
	sudo apt -yf install
	rm -f google-chrome-stable_current_amd64.deb
fi

# Install SimpleHelp (or not)
if [ "${add_simplehelp,,}" != "n" ] && [ "${add_simplehelp,,}" != "no" ]; then
	echo "Downloading and extracing SimpleHelp archive..."
	wget -O SimpleHelpTechnician.tar "http://support.umbctraining.com/technician/SimpleHelp%20Technician-linux64-online.tar?language=en&hostname=http%3A%2F%2Fsupport.umbctraining.com&ie=ie.exe"
	tar -xvf SimpleHelpTechnician.tar
	echo "Running SimpleHelp installer..."
	~/SimpleHelp\ Technician-linux64-online
	rm  *SimpleHelp*
fi

# This is last because it needs to be done after Chrome is installed (if selected)
echo "Downloading LastPass binary..."
wget "https://download.cloud.lastpass.com/linux/lplinux.tar.bz2"
echo "Confirming checksum..."
CHECKSUM=$(sha256sum lplinux.tar.bz2 | cut -f 1 -d " ") 
if [ "$CHECKSUM" = "905474aceb9998ba25118c572f727336d239a146aad705207f78cacf9052ea29" ]; then
	tar xjvf lplinux.tar.bz2
	./install_lastpass.sh
	rm lplinux.tar.bz2 && rm *lastpass*
else
	echo "LastPass checksum does not match last known value! Binary not installed."
fi

# TODO: Download and install latest sharp drivers
# http://siica.sharpusa.com/Portals/0/downloads/Drivers/Sharp_1_2_MX_C52_ps.zip

echo "Cleaning up..."
sudo apt -y autoremove
sudo apt -y clean
echo "Done."
