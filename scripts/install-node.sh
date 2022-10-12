#!/bin/bash
echo "This script has been tested on ubuntu 20.4.3 LTS (focal). If you are using another distribution, you most likely need to edit this script."
sleep 3

echo "installing docker"
apt-get update
apt-get install -y \
    apt-transport-https \
    ca-certificates \
    curl \
    software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | apt-key add -
add-apt-repository --yes \
   "deb https://download.docker.com/linux/$(. /etc/os-release; echo "$ID") \
   $(lsb_release -cs) \
   stable"


#host preparation for kubernetes installation
swapoff -a
rm /swap.img
sed "-i.bak" '/swap.img/d' /etc/fstab


apt-get update && apt-get install docker-ce docker-ce-cli containerd.io -y

echo "installing kubeadm and kubectl"
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
#apt-get install -y kubelet kubeadm kubectl
apt-get install -y kubelet=1.21.14-00 kubeadm=1.21.14-00 kubectl=1.21.14-00
apt-mark hold kubeadm kubelet kubectl  

rm /etc/containerd/config.toml
systemctl restart containerd
echo "You can now execute the kubeadm join command (the command is shown during kubeadm init on the master node)"

