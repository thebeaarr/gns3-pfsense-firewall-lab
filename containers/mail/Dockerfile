# ============================================================
# BASE IMAGE
# ============================================================
FROM debian:latest


# ============================================================
# INSTALL PACKAGES
#
#   postfix
#     → The main Mail Transfer Agent (MTA).
#       It handles SENDING and RECEIVING emails between servers.
#       It listens on port 25 (SMTP) for incoming mail
#       and relays outgoing mail to other mail servers.
#       Postfix is the most widely used MTA in production Linux.
#
#   dovecot-core
#     → The IMAP/POP3 server.
#       While Postfix handles sending/receiving between servers,
#       Dovecot handles the connection between the mail server
#       and the EMAIL CLIENT (like Thunderbird, Outlook).
#         IMAP (port 143) → client reads mail while it stays on server
#         POP3 (port 110) → client downloads mail and deletes from server
#       We use IMAP in our lab — better for testing.
#
#   dovecot-imapd
#     → The IMAP daemon specifically.
#       This is the actual IMAP service that Dovecot runs.
#       Separate from dovecot-core so you can install
#       only what you need.
#
#   mailutils
#     → Provides the `mail` command line tool.
#       Lets you send and read emails from the terminal.
#       Essential for testing the mail server from inside GNS3.
#       Example: echo "Test" | mail -s "Subject" user@dmz.local
#
#   iputils-ping → ping for connectivity testing
#   net-tools    → ifconfig, netstat
#   iproute2     → ip addr, ip route
#   nano         → text editor
# ============================================================
RUN apt update && apt install -y \
    postfix \
    dovecot-core \
    dovecot-imapd \
    mailutils \
    iputils-ping \
    net-tools \
    iproute2 \
    nano \
    && apt clean

# ============================================================
# CREATE MAIL USER
#
# We create a local user called "mailuser" to send/receive mail.
# This is the account we'll use to test the mail server.
#
# useradd flags:
#   -m → create home directory at /home/mailuser
#   -s /bin/bash → give bash shell access
#
# chpasswd → sets password from stdin
# ============================================================

RUN useradd -m -s /bin/bash mailuser && \
    echo "mailuser:mailpass" | chpasswd

# ============================================================
# COPY CONFIGURATION FILES
#
# main.cf   → Postfix main configuration
#             Defines the mail domain, hostname,
#             which networks can relay mail, etc.
#
# dovecot.conf → Dovecot configuration
#                Defines IMAP settings and authentication.
# ============================================================

COPY main.cf /etc/postfix/main.cf
COPY dovecot.conf /etc/dovecot/dovecot.conf

# ============================================================
# EXPOSE PORTS
#
# 25  → SMTP  — server to server mail transfer (Postfix)
# 110 → POP3  — client downloads mail (Dovecot)
# 143 → IMAP  — client reads mail on server (Dovecot)
# ============================================================
EXPOSE 25
EXPOSE 110
EXPOSE 143


# ============================================================
# COPY STARTUP SCRIPT
# Configures network interface then launches
# both Postfix and Dovecot.
# Replaces the old start.sh.
# ============================================================
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh
CMD ["/startup.sh"]