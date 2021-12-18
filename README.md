# Overview
In this repository you will find a man in the middle detection tool for local area networks. 


## What is DAN?

Although Man-in-the-Middle (MitM) attacks on LANs have been known for some time, they are still considered a significant threat. This is because these attacks are relatively easy to achieve, yet challenging to detect. For example, a planted network bridge or compromised switch leaves no forensic evidence.
DAN is a novel plug-and-play MitM detector for local area networks. DAN uses a technique inspired from the domain of acoustic signal processing. Analogous to how echoes in a cave capture the shape and construction of the environment, so to can a short and intense pulse of ICMP echo requests model the link between two network hosts. DAN sends these probes to a target network host and then uses the reflected signal to summarize the channel environment (think sonar). DAN uses machine learning to profile the link with each host, and to detect when the environment changes. Using this technique, DAN can detect MitM attacks with high accuracy, to the extent that it can distinguish between identical networking devices. 



DAN has been evaluated on LANs consisting of video surveillance cameras, servers, and hundreds of PC workstations. The tool also works across multiple network switches and in the presence of traffic. Although DAN is robust against adversarial attacks, the current version of the tool does not implement some of the defensive measures.

## What can DAN Do?

There are many kinds of MitM attacks when it comes to LANs. We categorize the class of a MitM attack based on the MitM topology, and implementation used. The figures below shows the attack topologies, implementations, and notes how well DAN can detect them. 


## How Does DAN Work (brief)
A MitM will always affect packet timings for two reasons:
1. to avoid signal collisions on the media when transmitting crafted/altered packets, and 
2. to capture and alter relevant packets before they reach their intended destination. In the latter case, the MitM must parse every frame in order to determine the frame's relevancy to the attack, and cannot retroactively stop a transmitted frame.

Therefore, the interception process (hardware and/or software) will affect the timing of network traffic. We note that since passive wiretaps only observe traffic, they are not MitM attacks and therefore not in the scope of this paper. However, DAN can detect a MitM which is presently eavesdropping (not currently altering traffic) because a MitM always buffers each packet upon reception. The figure below illustrates the basic packet interception process for all MitM implementations. 

However, measuring timing alone is not enough since two similar devices will have the same timing. Instead DAN tries to fingerprint the devices along the link by modeling the environment's impulse response. 

In networks, there are no reverberations of sound waves. However, switches, network interfaces, and operating systems all affect a packet's travel time across a network. The hardware, buffers, caches, and even the software versions of the devices which interact with the packets, all affect packet timing. When a device processes a burst of packets, the device has dynamic reaction with respect to the packets' sizes. This affects the packets' processing times, which are in turn, then propagated to the next node in the network. This is analogous to how a sound wave is affected as it reverberates off various surfaces.

DAN monitors changes to the 'environment' (link) by sending periodic probes to a target network host. The probe is a special burst of ICMP packets (pings) whose sizes are modulated according to an MLS signal. MLS is used to make the response robust to noise and strong against adversarial attacks (on DAN). The response signal which bounces back to DAN is then used to extract three summary features that measure the impulse response energy, the dominant DC component, and the packet jitter distribution. Using these probes, DAN profiles each link with an anomaly detection algorithm.


## Where is DAN Deployed?

In order to protect the link between hosts A and B, DAN only needs to be running on host A. However, this trust is one-sided since B would be unaware of the state of his link with A. Therefore, to secure all links in a LAN in a fully trusted manner, all hosts in the LAN must be running an instance of DAN. This kind of deployment can be practical in large LANs if DAN is configured to send probes at a low rate or only while communicating with the target end-host.

Another option is to install an instance of DAN on the network gateway (router). Although this does not secure the links between each host of the LAN, it does secure the inbound and outbound traffic. Note that both deployments only protect a host from MitM attacks originating within the same LAN. 


# The DAN Tool

## Implementation Notes: 

* This is a python implementation of DAN which wraps C/C++ code using cython. The C/C++ code is used to perform the ICMP probing quickly and accurately.
* This implementation uses local outlier factor (LOF) for anomaly detection (BlackHat'19) and not autoencoders (NDSS'18).
* The current version of DAN has been tuned to detect all of these cases except IP-DH where the exact same model is being used (i.e., the tool can detect the difference between two different 1Gps switches, but not identical ones). The tuned version will be released at a later date.  
* This tool currently does not currently implement detection of attacks on DAN itself. 
* The source code has been tested with Python 2.7.12 on a Linux 64bit machine (Kali). To port the tool to Windows, some C++ libraries must be changed.
* Python dependencies: prettytable, cython  

To install prettytable and cython, run this in the terminal:
```
pip install prettytable cython
```
 


## Using the Tool
Since the tool uses raw sockets, you **must** run DAN with sudo privileges. For example:
```
$ sudo python DAN.py
```

The first time you run DAN.py, cython will compile the necessary C++ libraries. When launched, DAN will monitor the IPv4 addresses in the local file IPs.csv, unless a target IP address is provided as an argument. A profile is trained for each host and is saved to disk (automatically retrieved each time the tool is started). The configuration of the last run is saved to disk (except the real-time plotting toggle argument). Note, this tool only works when monitoring a link contained within a LAN (switches only). Do not provide external IPs.

For complete instructions on how to use DAN, type into the command line
```
$ python DAN.py -h

usage: DAN.py [-h] [-i [I [I ...]]] [-t T] [-p] [-f F] [-r R] [-w W]
                 [--reset]

optional arguments:
  -h, --help      show this help message and exit
  -i [I [I ...]]  Monitor the given IP address(es) <I> only. If an IP's profile exists on disk, it will be loaded and used.
                  You can also provide the path to a file containing a list of IPs, where each entry is on a separate line.
                  Example: python DAN.py -i 192.168.0.12
                  Example: python DAN.py -i 192.168.0.10 192.168.0.42
                  Example: python DAN.py -i ips.csv
  -t T            set the train size with the given number of probes <T>. If profiles already exist, the training will be shortened or expanded accordingly. a
                  Default is 200.
                  Example: python DAN.py -i 192.168.0.12 -t 400
  -p              Plot anomaly scores in real-time. 
                  Example: python DAN.py -p
  -f F            load/save profiles from the given directory <F>. If is does not exist, it will be created. 
                  Default path is ./DAN_profiles.
  -r R            Sets the wait time <R> between each probe in milliseconds. 
                  Default is 0.
  -w W            Sets the sliding window size <W> used to average the anomaly scores. A larger window will provide fewer false alarms, but it will also increase the detection delay. 
                  Default is 10.
  --reset         Deletes the current configuration and all IP profiles stored on disk before initializing DAN.
```


# TO DO
* Add adversarial detection
* Tune hyperparemeters to differentiate between same model devices
* Port to Windows
* Decrease false alarms by introducing custom thesholds (currently using sklearn's lof built-in threshold)

