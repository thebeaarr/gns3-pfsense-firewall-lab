#!/bin/bash

# ============================================================
# STARTUP SCRIPT - ADMIN MACHINE (192.168.1.2)
#
# Configures network interface then launches SSH server.
# The admin machine sits in the ADMIN network (192.168.1.0/24)
# NOT in the DMZ — so different IP range and gateway.
# ============================================================

# ============================================================
# STEP 1 - Bring the interface up
# ============================================================
ip link set eth0 up

# ============================================================
# STEP 2 - Assign static IP
# 192.168.1.2 → Admin machine IP in the ADMIN network
# /24         → subnet 255.255.255.0
#
# Note: different subnet from DMZ servers (192.168.0.x)
# The admin network is 192.168.1.0/24
# ============================================================
ip addr add 192.168.1.2/24 dev eth0

# ============================================================
# STEP 3 - Set default gateway
# pfSense ETH2 is the ADMIN network gateway at 192.168.1.1
# Different from DMZ gateway (192.168.0.1)
# ============================================================
ip route add default via 192.168.1.1

# ============================================================
# STEP 4 - Start SSH server
# /usr/sbin/sshd → the SSH daemon
# -D → run in foreground (keeps container alive)
# -e → log errors to stderr so we can see them
#      in docker logs output
# exec replaces bash with sshd as PID 1
# ============================================================
exec /usr/sbin/sshd -D -e