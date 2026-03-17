# ============================================================
# BASE IMAGE
# Same Debian base as all our other containers.
# ============================================================
FROM debian:latest

# ============================================================
# INSTALL PACKAGES
#
#   vsftpd (Very Secure FTP Daemon)
#     → The FTP server software.
#       It listens on port 21 for incoming FTP connections.
#       "Very Secure" because it was designed with security
#       in mind — runs in a chroot jail by default, separating
#       users from the rest of the filesystem.
#       It supports:
#         - Anonymous FTP (no login required)
#         - Local user authentication
#         - Passive mode (important for firewalled environments)
#
#   ftp
#     → A simple FTP client tool.
#       Lets you TEST the FTP server from inside the container
#       or from another container in GNS3.
#       Example: ftp 192.168.0.2
#
#   iputils-ping → ping for connectivity testing
#   net-tools    → ifconfig, netstat
#   iproute2     → ip addr, ip route
#   nano         → text editor
# ============================================================
RUN apt update && apt install -y \
    vsftpd \
    ftp \
    iputils-ping \
    net-tools \
    iproute2 \
    nano \
    && apt clean

# ============================================================
# CREATE FTP DIRECTORY STRUCTURE
#
# /var/ftp/pub → the public directory where files are stored
#                This is what FTP users see when they connect.
#
# We create a test file inside it so we can verify
# file downloads are working when we test from GNS3.
# ============================================================
RUN mkdir -p /var/ftp/pub && \
    echo "Welcome to the FTP server - DMZ" > /var/ftp/pub/readme.txt

# ============================================================
# CREATE A LOCAL FTP USER
#
# FTP clients need credentials to log in.
# We create a system user called "ftpuser" with password "ftppass".
#
# useradd flags:
#   -m → create a home directory at /home/ftpuser
#   -s /bin/bash → give the user a bash shell
#
# chpasswd → sets the password from stdin
#   format: "username:password"
#
# In production you would use stronger passwords and
# possibly SSH keys — but for a lab this is fine.
# ============================================================
RUN useradd -m -s /bin/bash ftpuser && \
    echo "ftpuser:ftppass" | chpasswd

# ============================================================
# COPY VSFTPD CONFIGURATION
#
# vsftpd.conf is the main config file for the FTP server.
# We replace the default config with our custom one.
# The custom config enables local user login and
# sets up passive mode for use inside GNS3.
# ============================================================

COPY vsftpd.conf /etc/vsftpd.conf

# ============================================================
# EXPOSE PORTS
#
# Port 21  → FTP control port
#            This is where the client connects first.
#            Used for sending commands (LIST, RETR, STOR...)
#
# Port 20  → FTP data port (active mode)
#            Used for actual file transfers in active mode.
#
# Ports 21100-21110 → Passive mode data ports
#            In passive mode the SERVER opens these ports
#            and tells the client to connect to them.
#            Important in firewalled/NAT environments like GNS3.
# ============================================================
EXPOSE 20
EXPOSE 21
EXPOSE 21100-21110

# ============================================================
# STARTUP COMMAND
#
# We run vsftpd in the foreground with our config file.
# -obackground=NO → disables background/daemon mode
#                   keeps vsftpd as the main foreground process
#                   so Docker keeps the container alive.
# ============================================================
# CMD ["vsftpd", "/etc/vsftpd.conf"]
# ============================================================
# COPY STARTUP SCRIPT
# Configures network interface then launches vsftpd.
# ============================================================
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh
CMD ["/startup.sh"]