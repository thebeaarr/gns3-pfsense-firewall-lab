#!/bin/bash

# ============================================================
# STARTUP SCRIPT - FTP SERVER (192.168.0.2)
#
# Configures network interface then launches vsftpd.
# ============================================================

# ============================================================
# STEP 1 - Bring the interface up
# ============================================================
ip link set eth0 up

# ============================================================
# STEP 2 - Assign static IP
# 192.168.0.2 → FTP server IP in the DMZ network
# /24         → subnet 255.255.255.0
# ============================================================
ip addr add 192.168.0.2/24 dev eth0

# ============================================================
# STEP 3 - Set default gateway
# pfSense ETH1 is the DMZ gateway at 192.168.0.1
# ============================================================
ip route add default via 192.168.0.1

# ============================================================
# STEP 4 - Start vsftpd
# We pass our custom config file explicitly.
# exec replaces bash with vsftpd as PID 1.
# ============================================================
exec vsftpd /etc/vsftpd.conf