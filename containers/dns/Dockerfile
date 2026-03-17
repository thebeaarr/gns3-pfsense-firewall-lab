# ============================================================
# BASE IMAGE
# Same Debian base as the web container.
# Every server container in our lab starts from here.
# ============================================================
FROM debian:latest

# ============================================================
# INSTALL PACKAGES
#
#   bind9
#     → The most widely used DNS server software in the world.
#       It listens on port 53 and answers DNS queries.
#       When a machine asks "what is the IP of web.dmz.local?"
#       BIND9 looks up its zone files and responds.
#
#   bind9utils
#     → Utility tools that come with BIND9:
#         named-checkconf → checks your config file for errors
#         named-checkzone → checks your zone files for errors
#       Essential for debugging DNS configuration.
#
#   bind9-doc
#     → Documentation files for BIND9.
#       Useful reference when configuring zones.
#
#   dnsutils
#     → Provides DNS testing tools:
#         dig    → performs DNS lookups, shows full response
#                  Example: dig @192.168.0.5 web.dmz.local
#         nslookup → simpler DNS lookup tool
#                  Example: nslookup web.dmz.local 192.168.0.5
#       These are the main tools to TEST if DNS is working.
#
#   iputils-ping → ping command for connectivity testing
#   net-tools    → ifconfig, netstat
#   iproute2     → ip addr, ip route
#   nano         → text editor for editing config files
# ============================================================
RUN apt update && apt install -y \
    bind9 \
    bind9utils \
    bind9-doc \
    dnsutils \
    iputils-ping \
    net-tools \
    iproute2 \
    nano \
    && apt clean

# ============================================================
# COPY DNS CONFIGURATION
# We copy our custom BIND9 config files into the container.
# These files define:
#   - Which zones this DNS server is authoritative for
#   - The actual DNS records (A, CNAME, MX, PTR...)
#
# named.conf.options → global settings (forwarders, recursion...)
# named.conf.local   → declares our custom zones
# db.dmz.local       → zone file with our DNS records
#
# We create these files next to the Dockerfile on the host
# and Docker copies them in during build.
# ============================================================
COPY named.conf.options /etc/bind/named.conf.options
COPY named.conf.local   /etc/bind/named.conf.local
COPY db.dmz.local       /etc/bind/db.dmz.local

# ============================================================
# EXPOSE PORT
# Port 53 is the standard DNS port.
# DNS uses both UDP (for queries) and TCP (for zone transfers).
# ============================================================
EXPOSE 53/udp
EXPOSE 53/tcp

# ============================================================
# STARTUP COMMAND
# We start BIND9 (named) in foreground mode.
# -g flag → run in foreground and log to stderr
#            keeps the container alive (same concept as nginx)
# -u bind → run as the 'bind' user (not root) for security
# ============================================================
# CMD ["named", "-g", "-u", "bind"]
# ============================================================
# COPY STARTUP SCRIPT
# Configures network interface then launches BIND9.
# ============================================================
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh
CMD ["/startup.sh"]