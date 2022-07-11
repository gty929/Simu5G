# sudo ip netns add ns1
# sudo ip link add veth1 netns ns1 type veth peer name sim-veth1
# sudo brctl addif br-b391b7b31fc9 sim-veth1
# sudo ip link set sim-veth1 up
# sudo ip netns exec ns1 ip link set veth1 up
# sudo ip netns exec ns1 ip addr add 172.18.3.1/24 dev veth1
# sudo ip netns exec ns1 route add -net 172.18.0.0 netmask 255.255.0.0 dev veth1
# sudo ip netns exec ns1 ping 172.18.0.5


sudo ip link add veth1 type veth peer name sim-veth1
sudo brctl addif br-b391b7b31fc9 sim-veth1
sudo ip link set sim-veth1 up
sudo ip link set veth1 up
sudo ip addr add 172.18.3.1/24 dev veth1
sudo route add -net 172.18.0.0 netmask 255.255.0.0 dev veth1
sudo ping 172.18.0.5