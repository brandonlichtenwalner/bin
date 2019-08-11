#!/bin/bash

### Get a system up and running with the stuff I typically use on any machine
### Trying to keep it fairly generic for different flavors of Ubuntu
### Updated for Ubuntu 18.04

## This script should be run with my main user account, which is assumed to have sudo privileges.

## Getting started on a new host:
##   restore backup of saved home directory files, most notably .ssh directory
##   git clone git@github.com:brandonlichtenwalner/bin.git
##   cd ~
##   ~/bin/scripts/ubuntu_customize.sh

echo "Would you like to install TLP for automatic laptop power savings? [Y/n]"
read add_tlp

echo "Would you like to install qemu-kvm and virt-manager? [Y/n]"
read add_kvm

echo "Would you like to install VirtualBox and extensions? [Y/n]"
read add_vbox

echo "Would you like to install Google Chrome? [Y/n]"
read add_chrome

# add etcher repo
echo "deb https://deb.etcher.io stable etcher" | sudo tee /etc/apt/sources.list.d/balena-etcher.list
sudo apt-key adv --keyserver keyserver.ubuntu.com --recv-keys 379CE192D401AB61

echo "Update repos, run an apt full-upgrade, and clean up..."
sudo apt -y update
sudo apt -y full-upgrade

# install additional commonly used desktop packages
echo "Installing the usual packages via apt..."
sudo apt -y install balena-etcher-electron exfat-utils freeplane git hyphen-en-us libreoffice-calc libreoffice-impress libreoffice-pdfimport libreoffice-writer meld mpv mythes-en-us p7zip-full remmina-plugin-spice screen transmission-gtk vim

echo "Installing packages via snap..."
sudo snap install syncthing

# TODO: automatic syncthing configuration?

#echo "Fixing permissions on copied hidden directories..."
#chmod go-rwx .putty
#chmod go-rwx .remmina
#chmod go-rwx .ssh

echo 'alias llblk="lsblk --output NAME,SIZE,TYPE,FSTYPE,MOUNTPOINT,SERIAL,UUID"' >> ~/.bash_aliases

# Install TLP (or not)
if [ "${add_tlp,,}" != "n" ] && [ "${add_tlp,,}" != "no" ]; then
    echo "Installing TLP and related packages..."
    sudo apt -y install --no-install-recommends tlp smartmontools
    sudo apt -y install tlp-rdw linux-tools-generic
fi

# Install Qemu/KVM (or not)
if [ "${add_kvm,,}" != "n" ] && [ "${add_kvm,,}" != "no" ]; then
    sudo apt -y install bridge-utils qemu-kvm virt-manager
fi

# Install VirtualBox (or not)
if [ "${add_vbox,,}" != "n" ] && [ "${add_vbox,,}" != "no" ]; then
    #sudo apt -y install virtualbox-ext-pack virtualbox-guest-additions-iso
    echo 'deb https://download.virtualbox.org/virtualbox/debian bionic contrib' | sudo tee /etc/apt/sources.list.d/vbox.list
    wget -q https://www.virtualbox.org/download/oracle_vbox_2016.asc -O- | sudo apt-key add -
    sudo apt -y install virtualbox-6.0-ext-pack virtualbox-6.0-guest-additions-iso
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

echo "Cleaning up..."
sudo apt -y autoremove
sudo apt -y clean
echo "Done."
