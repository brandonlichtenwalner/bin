#!/bin/bash

### Get a system up and running with the stuff I typically use for my work machine
### Trying to keep it fairly generic for different flavors of Ubuntu
### Updated for Ubuntu 18.04

## This script should be run with my main user account, which is assumed to have sudo privileges.

# TODO: Outside of script, add config files to git

# TODO: git configuration, git pull for mind maps and config files, SSH setup

# add etcher repo
echo "deb https://dl.bintray.com/resin-io/debian stable etcher" | tee /etc/apt/sources.list.d/etcher.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61

echo "Update repos, run an apt full-upgrade, and clean up..."
sudo apt -y update
sudo apt -y full-upgrade

# install additional commonly used desktop packages
sudo apt -y install etcher-electron exfat-utils filezilla freeplane git meld p7zip-full

echo "Would you like to install VirtualBox (and extensions)? [Y/n]"
read add_packages
if [ "${add_packages,,}" != "n" ] && [ "${add_packages,,}" != "no" ]; then
	sudo apt -y install virtualbox-ext-pack virtualbox-guest-additions-iso
fi

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

echo "Would you like to install TLP for laptop power management? [Y/n]"
read add_packages
if [ "${add_packages,,}" != "n" ] && [ "${add_packages,,}" != "no" ]; then
	echo "Installing TLP and related packages..."
	sudo apt -y install --no-install-recommends tlp smartmontools
	sudo apt -y install tlp-rdw linux-tools-generic
fi

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

echo "Cleaning up..."
sudo apt -y autoremove
sudo apt -y clean
echo "Done."
