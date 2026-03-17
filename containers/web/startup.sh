#!/bin/bash

# ============================================================
# STARTUP SCRIPT - WEB SERVER (192.168.0.3)
#
# This script runs every time the container starts.
# It configures the network interface BEFORE launching
# the main service (nginx).
#
# Why do we need this?
# Docker containers start with no IP configured by default.
# GNS3 connects the container to the virtual network
# but doesn't assign IPs — we have to do it ourselves.
# ============================================================

# ============================================================
# STEP 1 - Bring the interface up
#
# eth0 is the first network interface inside the container.
# By default it exists but is DOWN (not active).
# We bring it UP so it can send/receive traffic.
# ============================================================
ip link set eth0 up

# ============================================================
# STEP 2 - Assign static IP address
#
# We assign the IP defined in our topology:
#   192.168.0.3  → web server IP
#   /24          → subnet mask 255.255.255.0
#                  means our network is 192.168.0.0/24
# ============================================================
ip addr add 192.168.0.3/24 dev eth0

# ============================================================
# STEP 3 - Set default gateway
#
# The gateway is pfSense ETH1 (DMZ interface).
# Any traffic going OUTSIDE 192.168.0.0/24 gets
# sent to pfSense which decides where to forward it.
# ============================================================
ip route add default via 192.168.0.1

# ============================================================
# STEP 4 - Start nginx
#
# exec replaces this bash process with nginx.
# This is important because Docker tracks the MAIN process.
# Using exec means nginx becomes PID 1 (the main process)
# instead of bash — signals like stop/restart go to nginx.
# ============================================================
exec nginx -g "daemon off;"