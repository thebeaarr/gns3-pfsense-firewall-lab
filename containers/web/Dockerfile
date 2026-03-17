# ============================================================
# FROM — BASE IMAGE
# ============================================================
# Every Dockerfile must start with FROM.
# It defines the starting point of your container — like
# choosing which OS to install on a fresh bare-metal machine.
#
# "debian:latest" means:
#   - debian → the official Debian Linux distribution image
#   - latest → the most recent stable version available
#             on Docker Hub (hub.docker.com)
#
# When you run "docker build", Docker will:
#   1. Check if debian:latest exists locally
#   2. If not → download it from Docker Hub automatically
#   3. Use it as the base layer to build everything on top
#
# Why Debian specifically?
#   - Lightweight (no GUI, no unnecessary services)
#   - Stable and well supported
#   - Uses apt package manager (same as your Kali host)
#   - Perfect for server containers
#
# Think of it like this:
#   FROM = installing a fresh OS on a virtual machine
#   Everything after FROM = what you do after the OS is installed
# ============================================================
FROM debian:latest


# ============================================================
# RUN — INSTALL PACKAGES
# ============================================================
# RUN executes a shell command DURING THE BUILD PHASE only.
# It runs once when you do "docker build" and never again.
# The result gets saved as a new layer in the image.
#
# HOW DOCKER LAYERS WORK:
# Docker builds images in layers — like a stack of pancakes.
# Each instruction (FROM, RUN, COPY...) creates a new layer.
# Layers are cached — if nothing changed in a layer,
# Docker reuses the cached version instead of rebuilding it.
# This makes rebuilds much faster.
#
# WHY WE CHAIN COMMANDS WITH &&:
# We could write multiple RUN instructions:
#   RUN apt update
#   RUN apt install nginx
#   RUN apt clean
# But that creates 3 separate layers = bigger image size.
# Chaining with && keeps everything in ONE layer = smaller image.
#
# The \ at the end of lines is just line continuation —
# it's the same as writing everything on one long line,
# just formatted nicely for readability.
#
# WHAT EACH PACKAGE DOES:
#
#   nginx
#     → The web server. It listens on port 80 and serves
#       HTML files to anyone who connects to this container.
#       Nginx is faster and uses less memory than Apache.
#       It's widely used in production environments.
#
#   curl
#     → A command line tool to make HTTP requests.
#       Example: curl http://192.168.0.3
#       Useful to test if the web server is responding
#       from inside another container in GNS3.
#
#   iputils-ping
#     → Provides the `ping` command.
#       Essential for testing connectivity between nodes
#       in your GNS3 topology.
#       Example: ping 192.168.0.1 (to reach pfSense)
#
#   net-tools
#     → Provides classic networking commands:
#         ifconfig  → shows network interfaces and IPs
#         netstat   → shows open ports and connections
#       Older tools but still very useful for debugging.
#
#   iproute2
#     → Provides modern networking commands:
#         ip addr   → shows network interfaces (modern ifconfig)
#         ip route  → shows routing table
#         ip link   → shows link state of interfaces
#       This is the modern replacement for net-tools.
#       We install both because some guides use one or the other.
#
#   nano
#     → A simple terminal text editor.
#       If you need to edit a config file INSIDE a running
#       container, nano lets you do that easily.
#       Example: nano /etc/nginx/nginx.conf
#
# "apt clean" at the end:
#     After installing packages, apt keeps downloaded .deb files
#     in /var/cache/apt/archives/ as a local cache.
#     We don't need them anymore after installation.
#     Cleaning them reduces the final image size significantly.
# ============================================================
RUN apt update && apt install -y \
    nginx \
    curl \
    iputils-ping \
    net-tools \
    iproute2 \
    nano \
    && apt clean


# ============================================================
# RUN — CREATE THE TEST WEB PAGE
# ============================================================
# This second RUN creates a simple HTML file that nginx
# will serve when someone visits this server.
#
# WHY DO WE NEED THIS?
# Nginx comes with a default page but it just says
# "Welcome to nginx" — not very useful in a lab.
# We replace it with our own page that shows:
#   - The server's role (Web Server)
#   - Which network it's in (DMZ)
#   - Its IP address (192.168.0.3)
# This makes it easy to confirm which server responded
# when you test from another machine in your topology.
#
# HOW IT WORKS:
#   echo "..." → generates the HTML text
#   >           → redirects that text INTO a file
#                 (overwrites the file if it already exists)
#   /var/www/html/index.html → nginx's default web root
#                              This is where nginx looks
#                              for files to serve by default.
#
# When another machine in GNS3 does:
#   curl http://192.168.0.3
# Nginx reads this file and sends it back as the response.
# ============================================================
RUN echo "<html><body><h1>Web Server - DMZ</h1><p>IP: 192.168.0.3</p></body></html>" \
    > /var/www/html/index.html


# ============================================================
# EXPOSE — DOCUMENT THE PORT
# ============================================================
# EXPOSE tells Docker that this container intends to
# listen on port 80 (the standard HTTP port).
#
# IMPORTANT — what EXPOSE does NOT do:
#   - It does NOT actually open the port
#   - It does NOT make the port accessible automatically
#   - It is NOT a firewall rule
#
# What EXPOSE actually does:
#   - Documents which port the service uses
#   - Acts as communication between the person who built
#     the image and the person who runs it
#   - GNS3 reads this to know which ports to work with
#
# In GNS3 specifically, the actual port connectivity is
# handled by the virtual network cables you draw between
# nodes — not by this EXPOSE instruction.
# ============================================================
EXPOSE 80


# ============================================================
# CMD — STARTUP COMMAND
# ============================================================
# CMD defines what command runs when the container STARTS.
# Unlike RUN (which runs at build time), CMD runs at
# runtime — every time someone does "docker run" or
# GNS3 starts this container node.
#
# Only ONE CMD is allowed per Dockerfile.
# If you write multiple, only the last one takes effect.
#
# WHY "daemon off"?
# By default nginx starts as a background daemon:
#   - It launches, then immediately goes to the background
#   - The foreground process exits
#   - Docker sees no foreground process → thinks container is done
#   - Docker STOPS the container immediately
#
# "daemon off" forces nginx to stay in the FOREGROUND:
#   - Nginx stays as the main running process
#   - Docker sees it running → keeps the container alive
#   - Container stays up as long as nginx is running
#
# The array format ["nginx", "-g", "daemon off;"] is called
# EXEC FORM — it runs the command directly without a shell.
# This is preferred over shell form because:
#   - Signals (like stop/restart) go directly to nginx
#   - No extra shell process consuming memory
# ============================================================
# CMD ["nginx", "-g", "daemon off;"] ( old one )

# ============================================================
# COPY STARTUP SCRIPT
# Copy the startup.sh from the host into the container.
# This script configures the network interface (IP, gateway)
# then launches nginx.
# ============================================================
COPY startup.sh /startup.sh

# ============================================================
# MAKE IT EXECUTABLE
# Files copied with COPY lose their executable permission.
# chmod +x adds the execute permission so we can run it.
# Without this the container will error: permission denied
# ============================================================
RUN chmod +x /startup.sh

# NEW CMD — runs the startup script instead of nginx directly
CMD ["/startup.sh"]