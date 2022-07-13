#!/bin/bash
#   
#   
#   +++++++++++++++++++++++++     +++++++++++++++++++++++++     +++++++++++++++++++++++++
#   +     Namespace cns1     +     +         Simu5G        +     +     Namespace nns1     +
#   +                       +     +                       +     +                       +
#   +  Client App     [veth-client1]<--->[simveth-client1]   [simveth-nginx1]<--->[veth-nginx1]     Server App  +
#   +            192.168.2.2+     +                       +     +192.168.3.2            +
#   +                       +     +                       +     +                       +
#   +++++++++++++++++++++++++     +++++++++++++++++++++++++     +++++++++++++++++++++++++
#   

# create two namespaces
sudo ip netns add cns1
sudo ip netns add nns1
sudo ip netns add nns2

# create virtual ethernet link: cns1.veth-client1 <--> simveth-client1 , simveth-nginx1 <--> nns1.veth-nginx1 
sudo ip link add veth-client1 netns cns1 type veth peer name simveth-client1
sudo ip link add veth-nginx1 netns nns1 type veth peer name simveth-nginx1
sudo ip link add veth-docker1 netns nns1 type veth peer name brveth-docker1
sudo brctl addif br-b391b7b31fc9 brveth-docker1
sudo ip link add veth-nginx2 netns nns2 type veth peer name simveth-nginx2
sudo ip link add veth-docker2 netns nns2 type veth peer name brveth-docker2
sudo brctl addif br-b391b7b31fc9 brveth-docker2
# Assign the address 192.168.2.2 with netmask 255.255.255.0 to `veth-client1`
sudo ip netns exec cns1 ip addr add 192.168.3.100/24 dev veth-client1
 
# Assign the address 192.168.3.2 with netmask 255.255.255.0 to `veth-nginx1`
sudo ip netns exec nns1 ip addr add 192.168.2.100/24 dev veth-nginx1
sudo ip netns exec nns2 ip addr add 192.168.2.100/24 dev veth-nginx2

sudo ip netns exec nns1 ip addr add 172.18.3.1/24 dev veth-docker1
sudo ip netns exec nns2 ip addr add 172.18.3.1/24 dev veth-docker2

# bring up all interfaces
sudo ip netns exec cns1 ip link set veth-client1 up
sudo ip link set simveth-client1 up
sudo ip netns exec nns1 ip link set veth-nginx1 up
sudo ip netns exec nns1 ip link set veth-docker1 up
sudo ip netns exec nns2 ip link set veth-nginx2 up
sudo ip netns exec nns2 ip link set veth-docker2 up
sudo ip link set brveth-docker1 up
sudo ip link set simveth-nginx1 up
sudo ip link set brveth-docker2 up
sudo ip link set simveth-nginx2 up

# add default IP route within new namespaces 
sudo ip netns exec cns1 route add default dev veth-client1
# sudo ip netns exec nns1 route add -net 192.168.0.0 netmask 255.255.0.0 dev veth-nginx1
sudo ip netns exec nns1 route add default dev veth-nginx1
sudo ip netns exec nns1 route add -net 172.18.0.0 netmask 255.255.0.0 dev veth-docker1
sudo ip netns exec nns2 route add default dev veth-nginx2
sudo ip netns exec nns2 route add -net 172.18.0.0 netmask 255.255.0.0 dev veth-docker2

# disable TCP checksum offloading to make sure that TCP checksum is actually calculated
sudo ip netns exec cns1 ethtool --offload veth-client1 rx off tx off 
sudo ip netns exec nns1 ethtool --offload veth-nginx1 rx off tx off
sudo ip netns exec nns1 ethtool --offload veth-docker1 rx off tx off

sudo ip netns exec nns1 nginx -c ~/go/src/sigs.k8s.io/scheduler-plugins/mynginx1.conf

sudo ip netns exec nns2 ethtool --offload veth-nginx2 rx off tx off
sudo ip netns exec nns2 ethtool --offload veth-docker2 rx off tx off

sudo ip netns exec nns2 nginx -c ~/go/src/sigs.k8s.io/scheduler-plugins/mynginx2.conf
