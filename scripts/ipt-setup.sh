#!/bin/sh

# IP address of server running iptables
SERVER_IP="0.0.0.0"
# IP address to allow SSH to the server
SSH_IP="0.0.0.0"
# SSH Port
SSH_PORT="22"

# Flush everything to start
iptables -F
iptables -X

# Create chains for TCP and UDP
iptables -N TCP
iptables -N UDP

# Default filter policies
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Allow already established or related connections
iptables -A INPUT -m conntrack --ctstate RELATED,ESTABLISHED -j ACCEPT

# Allow all traffic from loopback interface
iptables -A INPUT -i lo -j ACCEPT

# Drop invalid packets
iptables -A INPUT -m conntrack --ctstate INVALID -j DROP

# Allow ICMP echo reqeusts
iptables -A INPUT -p icmp --icmp-type 8 -m conntrack --ctstate NEW -j ACCEPT

# Attach TCP and UDP chains to INPUT
iptables -A INPUT -p udp -m conntrack --ctstate NEW -j UDP
iptables -A INPUT -p tcp --syn -m conntrack --ctstate NEW -j TCP

# Mimic default Linux behavior for unwanted packets
iptables -A INPUT -p udp -j REJECT --reject-with icmp-port-unreachable
iptables -A INPUT -p tcp -j REJECT --reject-with tcp-rst
iptables -A INPUT -j REJECT --reject-with icmp-proto-unreachable

# Allow SSH Access from specified IP
iptables -A TCP -p tcp -s $SSH_IP -d $SERVER_IP --sport 513:65535 --dport $SSH_PORT -m state --state NEW,ESTABLISHED -j ACCEPT

# Save the generated rules
iptables-save > /etc/iptables/iptables.rules
