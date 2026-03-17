#!/bin/bash

# ============================================================
# STARTUP SCRIPT - MAIL SERVER (192.168.0.4)
#
# Configures network interface then launches
# both Postfix (SMTP) and Dovecot (IMAP/POP3).
#
# Why different from other containers?
# Most containers run ONE service.
# The mail server runs TWO — Postfix AND Dovecot.
# They work together:
#   Postfix  → receives/sends emails between servers (SMTP)
#   Dovecot  → lets email clients read the mailbox (IMAP)
# We can't use exec here because exec replaces the process —
# we'd only be able to start one service that way.
# Instead we start both in background then use
# tail -f /dev/null to keep the container alive.
# ============================================================

# ============================================================
# STEP 1 - Bring the interface up
# ============================================================
ip link set eth0 up

# ============================================================
# STEP 2 - Assign static IP
# 192.168.0.4 → Mail server IP in the DMZ network
# /24         → subnet 255.255.255.0
# ============================================================
ip addr add 192.168.0.4/24 dev eth0

# ============================================================
# STEP 3 - Set default gateway
# pfSense ETH1 is the DMZ gateway at 192.168.0.1
# ============================================================
ip route add default via 192.168.0.1

# ============================================================
# STEP 4 - Start Postfix
# service postfix start → starts the SMTP server
# Postfix handles sending and receiving emails
# between mail servers on port 25.
# ============================================================
service postfix start

# ============================================================
# STEP 5 - Start Dovecot
# service dovecot start → starts the IMAP/POP3 server
# Dovecot handles connections from email clients
# on port 143 (IMAP) and 110 (POP3).
# ============================================================
service dovecot start

# ============================================================
# STEP 6 - Keep container alive
# Since both services run in the background,
# there is no foreground process to keep Docker alive.
# tail -f /dev/null follows an empty file forever —
# it never exits so the container stays running.
# This is the standard Docker trick for multi-service containers.
# ============================================================
tail -f /dev/null