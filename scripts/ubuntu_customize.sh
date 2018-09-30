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

# TODO: configure and pull down stuff from gitlab.umbctraining.co

# echo "Pulling down Mind Maps repo..."
# git clone git@github.com:brandonlichtenwalner/maps.git

# add etcher repo
echo "deb https://dl.bintray.com/resin-io/debian stable etcher" | tee /etc/apt/sources.list.d/etcher.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61

echo "Update repos, run an apt full-upgrade, and clean up..."
sudo apt -y update
sudo apt -y full-upgrade

# install additional commonly used desktop packages
echo "Installing the usual packages..."
sudo apt -y install etcher-electron exfat-utils filezilla freeplane git meld p7zip-full virtualbox-ext-pack virtualbox-guest-additions-iso

echo "Installing TLP and related packages..."
sudo apt -y install --no-install-recommends tlp smartmontools
sudo apt -y install tlp-rdw linux-tools-generic

echo "Would you like to install qemu-kvm and virt-manager? [Y/n]"
read add_packages
if [ "${add_packages,,}" != "n" ] && [ "${add_packages,,}" != "no" ]; then
	sudo apt -y install bridge-utils qemu-kvm virt-manager
fi

echo "I hope to be using Firefox as a daily driver, but it's always good to have a couple of browsers, so..."
echo "Would you like to install Google Chrome? [Y/n]"
read add_packages
if [ "${add_packages,,}" != "n" ] && [ "${add_packages,,}" != "no" ]; then
	echo "Downloading latest Google Chrome package..."
	wget https://dl.google.com/linux/direct/google-chrome-stable_current_amd64.deb
	echo "Using dpkg to install Google Chrome..."
	sudo dpkg -i google-chrome-stable_current_amd64.deb
	echo "Fixing Google Chrome install via apt..."
	sudo apt -yf install
	rm -f google-chrome-stable_current_amd64.deb
fi

echo "Answer 'no' if connected to Training Centers Corporate network. Need to fix support.umbctraining.com from inside."
echo "Would you like to install SimpleHelp? [Y/n]"
read add_packages
if [ "${add_packages,,}" != "n" ] && [ "${add_packages,,}" != "no" ]; then
	echo "Downloading and extracing SimpleHelp archive..."
	wget -O SimpleHelpTechnician.tar "http://support.umbctraining.com/technician/SimpleHelp%20Technician-linux64-online.tar?language=en&hostname=http%3A%2F%2Fsupport.umbctraining.com&ie=ie.exe"
	tar -xvf SimpleHelpTechnician.tar
	echo "Running SimpleHelp installer..."
	~/SimpleHelp\ Technician-linux64-online
	rm -f SimpleHelpTechnician.tar
fi

# This is at the end because I *think* it needs to be installed after Chrome
echo "Downloading LastPass binary..."
wget "https://download.cloud.lastpass.com/linux/lplinux.tar.bz2"
echo "Confirming checksum..."
CHECKSUM=$(sha256sum lplinux.tar.bz2) 
if [ "$CHECKSUM" -eq "905474aceb9998ba25118c572f727336d239a146aad705207f78cacf9052ea29" ]; then
	tar xjvf lplinux.tar.bz2
	cd lplinux && ./install_lastpass.sh
	cd .. && rm lplinux.tar.bz2 && rm -rf lplinux
else
	echo "LastPass checksum does not match last known value! Binary not installed."
fi

echo "Cleaning up..."
sudo apt -y autoremove
sudo apt -y clean
echo "Done."
