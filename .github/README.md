# MiniPwner [![CI](https://github.com/nicholasadamou/minipwner/actions/workflows/ci.yaml/badge.svg)](https://github.com/nicholasadamou/minipwner/actions/workflows/ci.yaml)

![banner](/banner.png)

A script to configure a *TP-Link MR3040* running *OpenWRT* into a simple, yet powerful penetration-testing "drop box".

What is the "MiniPwner"?
-------

**The MiniPwner is a penetration testing "drop box".**

It is designed as a small, simple but powerful device that can be inconspicuously plugged into a network and provide the penetration tester remote access to that network.

It's made up of a portable *TP-Link MR3040* running *OpenWRT*.

Features
-------

* **Integrated Wired and Wireless connections**

    Once plugged into a target network, the Mini-Pwner can establish an SSH tunnel through the target network, or can be accessed by wifi. In addition, the MiniPwner can be configured as a wifi sniffer and logger - war walking in your pocket.

* **Low power consumption, can be run off battery.**

    With a 2000 mAh built-in battery, the Mini-Pwner will run for over five hours of active wired and wireless activity. No need to find a power outlet during the pen test.

* **Multiple Pen Testing Tools included**

    aircrack-ng, elinks, ettercap-ng, karma, kismet, nbtscan, netcat, nmap, openvpn, perl 5, samba client, snort, tar, tcpdump, tmux, yafc, and wget all come pre-installed.

* **Flexible and Expandable**

    The MiniPwner runs on the open source OpenWrt operating system. You can easily add or change the installed packages.

* **Small size**

    The MiniPwner can be easily carried in a pocket, hidden behind a telephone, or hang from a jack by a short ethernet cable (included).

Specifications
-------

The MiniPwner is a *TP-Link MR3040* router with a *16GB flash drive* to expand its storage capability.

Includes *802.11n Wireless N* WiFi and an *Ethernet port*.

Operating System is *OpenWrt Barrier Breaker*.

What can you do with it?
-------

* **Pen Testing Drop Box**

    In this mode, the MiniPwner used to establish rogue access to a target network during a penetration test. The penetration tester uses stealth or social engineering techniques to plug the MiniPwner into an available network port. (common locations include conference rooms, unoccupied workstations, the back of IP Telephones, etc.)

    Once it is plugged in, the penetration tester can log into the MiniPwner and begin scanning and attacking the network. The MiniPwner can simultaneously establish SSH tunnels through the target network, and also allow the penetration tester to connect to the MiniPwner via WiFi.

    The MiniPwner can run some software directly from the box, such as nmap to map the target network or the samba client to connect to windows shares. Other tools, such as Metasploit or Nessus can be run through the box using a VPN tunnel.

* **Wireless war-walking**

    The battery-powered MiniPwner is small enough to fit in your jeans pocket and can run for hours. In wireless war-walking mode you start kismet or aircrack-ng on the MiniPwner and record details about all of the wireless networks detected by the device.

* **Captive WiFi Portal or Rogue Access Point**

    Use the Karma application to discover clients and their preferred/trusted networks by passively listening for 802.11 Probe Request frames. From there, individual clients can be targetted by creating a Rogue AP for one of their probed networks (which they may join automatically) or using a custom driver that responds to probes and association requests for any SSID. Higher-level fake services can then capture credentials or exploit client-side vulnerabilities on the host.

*There are many other creative ways to use the MiniPwner.*

Here is a list of *some* of the software that comes pre-installed:

* `Aircrack` Wireless network analysis
* `elinks` Text Based Web Browser
* `ettercap-ng` Man-in-the-middle attack tool
* `kismet` Wireless network analysis
* `nbtscan` NetBIOS Network Scanner
* `Netcat` Hacker’s swiss army knife
* `Nmap` network scanner
* `openssh-sftp-client` Secure File Transfer Client
* `openvpn` VPN Client and Server
* `perl 5` Perl Scripting Language
* `samba2-client` Windows File Sharing Client
* `snort` Sniffer, Packet Logger, Intrusion Detection System
* `tar` File archiving
* `Tcpdump` sniffer
* `yafc` FTP Client

Install
-------

**Note**: *Please see the [Wiki/Configuring-a-TP-Link-MR3040-into-a-MiniPwner](https://github.com/nicholasadamou/minipwner/wiki/Configuring-a-TP-Link-MR3040-into-a-MiniPwner) for instructions on configuring the MiniPwner*.

There are *two methods* provided for installing and configure the *TP-Link MR3040* router into a *MiniPwner*. Please review and choose one below.

Review, then execute the below script on the *TP-Link MR3040* running *OpenWRT*:

**Method One**:
```
wget -O /tmp/minipwner.zip https://github.com/nicholasadamou/minipwner/archive/master.zip && \
    unzip /tmp/minipwner.zip && \
    cd /tmp/minipwner && \
    bash src/setup.sh
```

**Method Two**:
```
wget -O /tmp/minipwner-overlay_2.0.0.tar https://raw.githubusercontent.com/nicholasadamou/minipwner/master/OVERLAY/minipwner-overlay_2.0.0.tar && \
    mkdir /tmp/minipwner-overlay_2.0.0 && \
    tar -C /tmp/minipwner-overlay_2.0.0 -xvf /tmp/minipwner-overlay_2.0.0.tar && \
    cd /tmp/minipwner-overlay_2.0.0 && \
    sh src/setup.sh
```

License
-------

MiniPwner is © Nicholas Adamou, Michael Vieau.

It is free software, and may be redistributed under the terms specified in the [LICENSE] file.

[LICENSE]: /LICENSE
