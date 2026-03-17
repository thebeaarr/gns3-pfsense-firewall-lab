#!/bin/bash

# ============================================================
# STARTUP SCRIPT - SUPERVISION MACHINE (192.168.1.3)
#
# Configures network interface then keeps container alive.
# The supervision machine sits in the ADMIN network
# alongside the admin machine (192.168.1.0/24).
#
# Unlike other containers, supervision has NO main service
# to run in foreground — it's a monitoring workstation.
# We just configure the network and keep it alive,
# ready for the admin to run monitoring scripts manually.
# ============================================================

# ============================================================
# STEP 1 - Bring the interface up
# ============================================================
ip link set eth0 up

# ============================================================
# STEP 2 - Assign static IP
# 192.168.1.3 → Supervision machine IP in ADMIN network
# /24         → subnet 255.255.255.0
# ============================================================
ip addr add 192.168.1.3/24 dev eth0

# ============================================================
# STEP 3 - Set default gateway
# pfSense ETH2 is the ADMIN network gateway at 192.168.1.1
# Same gateway as the admin machine.
# ============================================================
ip route add default via 192.168.1.1

# ============================================================
# STEP 4 - Keep container alive
# No foreground service to run here.
# tail -f /dev/null keeps the container running forever
# so we can exec into it and run monitoring scripts
# manually whenever needed.
#
# To run the monitoring script from GNS3 console:
#   /monitoring/check_services.sh
# ============================================================
tail -f /dev/null