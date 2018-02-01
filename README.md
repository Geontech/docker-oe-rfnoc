# docker-oe-rfnoc
A containerized build process for the REDHAWK RF-NoC assets

# Build Docker Image
To build the OpenEmbedded environment necessary to generate an RFNoC Enabled REDHAWK E310 image, run the following:

    docker build --rm -t oe-rfnoc .

# Run Containerized Build
To build the RFNoC Enabled REDHAWK E310 image, run the following:

    docker run --rm -it <-v /path/to/build:/opt/oe-project/build> oe-rfnoc

# Create SD Card
To create an SD Card which the E310 can boot, run the following:

    dd if=/path/to/build/images/ettus-e3xx-sg1/sdimage-redhawk-usrp-uhd-rfnoc-image.direct of=/dev/sdcarddev bs=1M

# Run RF-NoC Image
Once the dd command above finishes, there are two options for networking:

    1. Mount the second partition and configure a static IP. Then unmount and insert the SD card into the E310
    2. Insert the SD card and allow the IP address to be configured via DHCP. You may need to run the nmap command
       to find the IP address, e.g. nmap -sP 192.168.1.*

Now ssh into the E310, where the username is root and by default there is no password. Configure the name and event
service to point to your domain by editing /etc/omniORB.cfg and replacing both instances of "127.0.0.1" with the 
external IP address of your domain.

To test that this is working, run the following command on the E310:

    nameclt list

If your domain is at least running the omniNames and omniEvents services, you should see the EventChannelFactory listed.

Troubleshooting:

If you see a TRANSIENT error, there are several potential causes:

    1. omniNames is not running on your domain computer. Try running '$OSSIEHOME/bin/cleanomni' on the domain, then re-running
       'nameclt list' on the E310
    2. If the naming service is running on your domain, the E310 may be blocked by iptables. Try adding the IP address of the
       E310 to your domain's iptables with the following command:

        iptables -I INPUT -s <E310 IP address> -j ACCEPT

       Now run 'nameclt list' on the E310. If this works, consider saving this rule, creating a more restrictive rule based
       on the E310 MAC address, or turning off iptables, whichever is most consistent with your current security rules
    3. If your domain has multiple active network interfaces, try turning off all but the one necessary to communicate with
       the E310, then running '$OSSIEHOME/bin/cleanomni' on your domain and 'nameclt list' on the E310. If this works, see
       the REDHAWK documentation for configuring omni to listen on a specific end point

# Configure Device Manager
To configure a default Device Manager profile, run the following:

    $SDRROOT/dev/devices/RFNoC_ProgrammableDevice/nodeconfig.py --noinplace --domainname <YOUR_DOMAIN_NAME> --usrptype e3x0

This will create a Device Manager profile located at $SDRROOT/dev/nodes/DevMgr-RFNoC_<hostname>/DeviceManager.dcd.xml.
While this DeviceManager is sufficient to run the RFNoC_ProgrammableDevice, there will be no functionality until a Persona
Device is also running. Following the comment block at the bottom of the file will help to add one or more Personas. While this
block is written toward the RFNoC_DefaultPersona, other Persona Devices can be added in a similar way.

Also, the profile is generated to connect the REDHAWK_DEV domain by default. Change this as necessary.

# Run Device Manager
To run the Device Manager, run the following:

    nodeBooter -d $SDRROOT/dev/nodes/DevMgr-RFNoC_<hostname>/DeviceManager.dcd.xml
