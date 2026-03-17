# ============================================================
# BASE IMAGE
# ============================================================
FROM debian:latest

# ============================================================
# INSTALL PACKAGES
#
# The supervision machine is responsible for MONITORING
# the entire network — checking if services are up,
# collecting logs, measuring performance, alerting on issues.
#
# It's different from the admin machine:
#   admin machine  → used to MANAGE and CONFIGURE things
#   supervision    → used to WATCH and MONITOR things
#
#   snmp
#     → Simple Network Management Protocol.
#       Used to query network devices (routers, switches, servers)
#       for their status, interface stats, CPU/memory usage.
#       Example: snmpwalk -v2c -c public 192.168.0.1
#       This queries pfSense for all its SNMP data.
#
#   snmp-mibs-downloader
#     → Downloads MIB files (Management Information Base).
#       MIBs are like dictionaries that translate SNMP
#       numeric codes into human readable names.
#       Without MIBs you see: 1.3.6.1.2.1.1.1.0
#       With MIBs you see: sysDescr.0 = "Linux router"
#
#   nagios-nrpe-plugin
#     → Nagios Remote Plugin Executor.
#       Nagios is the most widely used network monitoring system.
#       This plugin lets you run checks on remote machines.
#       Checks things like: is port 80 open? is disk full?
#       is the service responding? how high is CPU usage?
#
#   fping
#     → Like ping but can ping MULTIPLE hosts simultaneously.
#       Perfect for checking if all your GNS3 nodes are alive.
#       Example: fping 192.168.0.2 192.168.0.3 192.168.0.4 192.168.0.5
#       Output shows which hosts are alive and which are down.
#
#   whois
#     → Queries domain registration information.
#       Useful for investigating external IPs/domains.
#
#   nmap
#     → Network scanner — same as admin machine.
#       Used here for periodic network discovery scans
#       to detect new/unauthorized devices on the network.
#
#   tcpdump
#     → Packet capture — same as admin machine.
#       Used here to capture and analyze suspicious traffic.
#
#   curl
#     → HTTP client — used to check if web services respond.
#       Example: curl -I http://192.168.0.3
#       Returns HTTP headers — tells us if server is up.
#
#   openssh-client
#     → SSH client to connect to other machines for maintenance.
#
#   iputils-ping → ping
#   net-tools    → ifconfig, netstat
#   iproute2     → ip addr, ip route
#   nano         → text editor
# ============================================================
# ============================================================
# ADD NON-FREE REPO AND INSTALL PACKAGES
#
# snmp-mibs-downloader lives in Debian's "non-free" repository
# which is not enabled by default.
#
# We first add non-free to the apt sources list,
# then update and install all packages.
#
# echo "deb ... non-free" → adds the non-free repo
# apt update             → refreshes package lists with new repo
# apt install            → now can find snmp-mibs-downloader
# ============================================================
RUN echo "deb http://deb.debian.org/debian trixie main non-free non-free-firmware" \
    > /etc/apt/sources.list && \
    apt update && apt install -y \
    snmp \
    snmp-mibs-downloader \
    nagios-nrpe-plugin \
    fping \
    whois \
    nmap \
    tcpdump \
    curl \
    wget \
    openssh-client \
    procps \
    iputils-ping \
    net-tools \
    iproute2 \
    nano \
    && apt clean

# ============================================================
# CONFIGURE SNMP
#
# The default snmp.conf has a line that disables MIB loading.
# We comment it out so our downloaded MIBs are actually used.
#
# mibs : → this line tells snmp to load no MIBs
# #mibs : → commenting it out enables all MIB loading
#
# This makes snmp output human readable instead of
# showing raw numeric OID codes.
# ============================================================
RUN sed -i 's/^mibs :/#mibs :/' /etc/snmp/snmp.conf

# ===================================================

# ============================================================
# COPY STARTUP SCRIPT
# Configures network interface then launches SSH server.
# ============================================================
COPY startup.sh /startup.sh
RUN chmod +x /startup.sh
CMD ["/startup.sh"]