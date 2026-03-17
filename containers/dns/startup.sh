#!/bin/bash

# ============================================================
# STARTUP SCRIPT - DNS SERVER (192.168.0.5)
#
# Configures network interface then launches BIND9.
# ============================================================

# ============================================================
# STEP 1 - Bring the interface up
# eth0 starts as DOWN — we activate it first.
# ============================================================
ip link set eth0 up

# ============================================================
# STEP 2 - Assign static IP
# 192.168.0.5 → DNS server IP in the DMZ network
# /24         → subnet 255.255.255.0
# ============================================================
ip addr add 192.168.0.5/24 dev eth0

# ============================================================
# STEP 3 - Set default gateway
# pfSense ETH1 is the DMZ gateway at 192.168.0.1
# ============================================================
ip route add default via 192.168.0.1

# ============================================================
# STEP 4 - Start BIND9
# named → the actual BIND9 DNS daemon
# -g    → run in foreground (keeps container alive)
# -u bind → run as bind user (not root) for security
# exec replaces bash with named as the main process (PID 1)
# ============================================================
exec named -g -u bind