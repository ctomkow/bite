#!/bin/sh
# Get and parse CDP info

# Clear old files
# net.info holds the cdp or lldp packet as an output string from tcpdump
rm net.info
rm netApp.info

# Get only one cdp or lldp packet from interface and write it to file
tcpdump -nn -vvv -i 1 -s 1500 -c 1 -A -e '(ether[12:2]=0x88cc or ether[20:2]=0x2000)' > net.info

# Pull info for either cdp or lldp. If cdp (searching for 0x2000 in header info of -e tcpdump flag)
# then grep the appropriate info (relying on tcpdump reformatting cdp packet)
if grep -q 0x2000 net.info; then
	grep Device-ID net.info > netApp.info       # Device-ID
	grep Address net.info >> netApp.info         # IP Address
	grep Port-ID net.info >> netApp.info         # Interface
	grep 0x0a net.info >> netApp.info            # VLAN ID (issue with this as tcpdump doesn't format the entire cdp packet)
else # lldp packet, just output last 4 lines (ASCII version of the packet thanks to tcpdump -A flag)
	tail -n 4 net.info > netApp.info
fi
