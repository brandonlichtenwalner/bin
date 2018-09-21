#!/bin/sh

# LXD / ZFS Server Configuration
# e.g. like
# https://bayton.org/docs/linux/lxd/lxd-zfs-and-bridged-networking-on-ubuntu-16-04-lts/

# I'm going to assume a dual nic setup: one bridged to LAN,
# the other to DMZ/WAN for internet facing containers

# Ubuntu Server 16.04.3 as of initial commit
# Installation notes (mostly stuck to defaults unless noted):
#  - configured 1st NIC as primary (e.g. enp0s3)
#  - used full disk with LVM (assuming using a separate disk for root)
#  - set to install security updates automatically
#  - added "OpenSSH Server" & "Samba File Server" during package selection

# Make sure the script has been executed as root
if [ "$USER" != 'root' ]; then
	echo "This script must be run with root privileges."
	echo "Try using: sudo $0 $@"
	exit 2
fi

# update repos and run system upgrade
apt update
apt -y full-upgrade

# install additional packages
apt -y install bridge-utils fail2ban zfsutils-linux

# post install cleanup
apt -y autoremove
apt -y clean

# Make sure auto upgrades are turned on
# (already done during install, if following above instructions)
cat <<'EOF' >/etc/apt/apt.conf.d/20auto-upgrades
APT::Periodic::Update-Package-Lists "1";
APT::Periodic::Unattended-Upgrade "1";
EOF

# Unattended Upgrades Configuration
cat <<'EOF' >/etc/apt/apt.conf.d/50unattended-upgrades
// Automatically upgrade packages from these (origin:archive) pairs
Unattended-Upgrade::Allowed-Origins {
	"${distro_id}:${distro_codename}";
	"${distro_id}:${distro_codename}-security";
	// Extended Security Maintenance; doesn't necessarily exist for
	// every release and this system may not have it installed, but if
	// available, the policy for updates is such that unattended-upgrades
	// should also install from here by default.
	"${distro_id}ESM:${distro_codename}";
  "${distro_id}:${distro_codename}-updates";
//	"${distro_id}:${distro_codename}-proposed";
  "${distro_id}:${distro_codename}-backports";
};

// List of packages to not update (regexp are supported)
Unattended-Upgrade::Package-Blacklist {
};

// Send email to this address for problems or packages upgrades
// If empty or unset then no email is sent, make sure that you
// have a working mail setup on your system. A package that provides
// 'mailx' must be installed. E.g. "user@example.com"
//Unattended-Upgrade::Mail "root";

// Set this value to "true" to get emails only on errors. Default
// is to always send a mail if Unattended-Upgrade::Mail is set
//Unattended-Upgrade::MailOnlyOnError "true";

// Do automatic removal of new unused dependencies after the upgrade
// (equivalent to apt-get autoremove)
Unattended-Upgrade::Remove-Unused-Dependencies "true";

// Automatically reboot *WITHOUT CONFIRMATION*
//  if the file /var/run/reboot-required is found after the upgrade 
Unattended-Upgrade::Automatic-Reboot "true";

// If automatic reboot is enabled and needed, reboot at the specific
// time instead of immediately
//  Default: "now"
Unattended-Upgrade::Automatic-Reboot-Time "03:00";
EOF

### TODO: Gather and/or prompt for primary interface name

# Network Configuration with LXD Bridge
cat <<'EOF' >/etc/network/interfaces
# This file describes the network interfaces available on your system
# and how to activate them. For more information, see interfaces(5).

source /etc/network/interfaces.d/*

# The loopback network interface
auto lo
iface lo inet loopback

# bridge setup for LXD containers
auto br-lxd 
iface br-lxd inet dhcp
	bridge_ports enp0s25

iface enp0s25 inet manual
EOF
