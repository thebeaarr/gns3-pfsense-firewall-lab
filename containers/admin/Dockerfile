# ============================================================
# BASE IMAGE
# ============================================================
FROM debian:latest

# ============================================================
# INSTALL PACKAGES
#
# The admin machine is different from the servers —
# it's not running a SERVICE that listens for connections.
# Instead it's a WORKSTATION used by the security admin
# to monitor, manage and interact with the whole network.
#
# So we install TOOLS instead of services:
#
#   ssh
#     → Secure Shell client AND server.
#       Client → lets the admin SSH into other machines
#                Example: ssh root@192.168.0.3 (connect to web server)
#       Server → lets other admins SSH INTO this machine remotely
#
#   nmap
#     → Network scanner and port mapper.
#       The most important tool for a security admin.
#       Examples:
#         nmap 192.168.0.0/24     → scan entire DMZ network
#         nmap -sV 192.168.0.3    → detect services/versions on web server
#         nmap -sS 192.168.0.3    → stealth SYN scan
#       Used to discover hosts, open ports, running services.
#
#   tcpdump
#     → Command line packet sniffer.
#       Captures and analyzes network traffic in real time.
#       Essential for debugging network issues in GNS3.
#       Examples:
#         tcpdump -i eth0              → capture all traffic on eth0
#         tcpdump -i eth0 port 80      → capture only HTTP traffic
#         tcpdump -i eth0 host 192.168.0.3 → capture traffic to/from web server
#
#   curl
#     → HTTP client tool.
#       Used to test web servers from the admin machine.
#       Example: curl http://192.168.0.3
#
#   wget
#     → File downloader.
#       Downloads files over HTTP/HTTPS/FTP.
#       Example: wget http://192.168.0.3/index.html
#
#   traceroute
#     → Shows the path packets take through the network.
#       Each hop is a router/firewall the packet passes through.
#       Essential for debugging routing issues.
#       Example: traceroute 192.168.0.3
#       Output shows: admin → pfSense → web server
#
#   netcat (nc)
#     → The "Swiss army knife" of networking.
#       Can open raw TCP/UDP connections to any port.
#       Used to test if ports are open/closed.
#       Examples:
#         nc -zv 192.168.0.3 80    → test if port 80 is open
#         nc -l 4444               → listen on port 4444
#
#   iputils-ping → ping
#   net-tools    → ifconfig, netstat
#   iproute2     → ip addr, ip route
#   nano         → text editor
# ============================================================
RUN apt update && apt install -y \
    openssh-server \
    openssh-client \
    nmap \
    tcpdump \
    curl \
    wget \
    traceroute \
    netcat-openbsd \
    iputils-ping \
    net-tools \
    iproute2 \
    procps \
    nano \
    && apt clean

# ============================================================
# CONFIGURE SSH SERVER
#
# By default SSH doesn't allow root login with a password.
# We enable it here for lab purposes so we can SSH into
# this container from other machines in GNS3.
#
# sed -i → edit the file in place
# We replace the default PermitRootLogin line with "yes".
#
# mkdir /run/sshd → SSH needs this directory to store
#                   its runtime PID file. Without it,
#                   sshd refuses to start.
# ============================================================
RUN sed -i 's/#PermitRootLogin prohibit-password/PermitRootLogin yes/' \
    /etc/ssh/sshd_config && \
    mkdir -p /run/sshd

# ============================================================
# SET ROOT PASSWORD
#
# We set a password for the root user so we can log in
# via SSH from other containers.
# Format: "username:password"
#
# In production NEVER use simple passwords or allow
# root SSH login — use SSH keys instead.
# This is only acceptable in a lab environment.
# ============================================================
RUN echo "root:adminpass" | chpasswd

# ============================================================
# EXPOSE PORT
#
# Port 22 → SSH port
#            Other machines connect here to get a remote shell.
# ============================================================
EXPOSE 22

# ============================================================
# STARTUP COMMAND
#
# Start the SSH server in foreground mode.
# -D flag → run in foreground (don't daemonize)
#           keeps the container alive
# -e flag → log to stderr instead of syslog
#           so we can see logs in docker logs output
# ============================================================
# CMD ["/usr/sbin/sshd", "-D", "-e"]
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh
CMD ["/startup.sh"]