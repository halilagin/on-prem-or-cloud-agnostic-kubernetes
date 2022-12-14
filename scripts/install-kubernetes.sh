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

apt-get update && apt-get install docker-ce docker-ce-cli containerd.io -y


#host preparation for kubernetes installation
swapoff -a
rm /swap.img
sed "-i.bak" '/swap.img/d' /etc/fstab
#hostnamectl set-hostname kubemaster
#cat <<EOF >>/etc/sysctl.conf
#net.ipv6.conf.all.disable_ipv6=1
#net.ipv6.conf.default.disable_ipv6=1
#net.ipv6.conf.lo.disable_ipv6=1
#EOF
#sysctl -p
#/etc/init.d/procps restart
#echo /etc/init.d/procps restart >> /etc/rec.local
#chmod 755 /etc/rc.local


echo "installing kubernetes"
apt-get update && apt-get install -y apt-transport-https
curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
cat <<EOF >/etc/apt/sources.list.d/kubernetes.list
deb http://apt.kubernetes.io/ kubernetes-xenial main
EOF
apt-get update
#apt-get install -y kubelet kubeadm kubectl
apt-get install -y kubelet=1.21.14-00 kubeadm=1.21.14-00 kubectl=1.21.14-00
apt-mark hold kubeadm kubelet kubectl

# DigitalOcean without firewall (IP-in-IP allowed) - or any other cloud / on-prem that supports IP-in-IP traffic
# echo "deploying kubernetes (with calico)..."
# kubeadm init --pod-network-cidr=192.168.0.0/16 # add --apiserver-advertise-address="ip" if you want to use a different IP address than the main server IP
# export KUBECONFIG=/etc/kubernetes/admin.conf
# kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/rbac-kdd.yaml
# kubectl apply -f https://docs.projectcalico.org/v3.1/getting-started/kubernetes/installation/hosted/kubernetes-datastore/calico-networking/1.7/calico.yaml


#cgroup docker setting
cat <<EOF | sudo tee /etc/docker/daemon.json
{ "exec-opts": ["native.cgroupdriver=systemd"],
"log-driver": "json-file",
"log-opts":
{ "max-size": "100m" },
	"storage-driver": "overlay2"
}
EOF
systemctl restart docker


# kubeadm configuration
echo '# kubeadm-config.yaml
kind: ClusterConfiguration
apiVersion: kubeadm.k8s.io/v1beta2
kubernetesVersion: v1.21.14
#controlPlaneEndpoint: "kubemaster:6443"
networking:
  podSubnet: 192.168.0.0/16
---
kind: KubeletConfiguration
apiVersion: kubelet.config.k8s.io/v1beta1
cgroupDriver: systemd' > kubeadm-config.yaml

# DigitalOcean with firewall (VxLAN with Flannel) - could be resolved in the future by allowing IP-in-IP in the firewall settings
echo "deploying kubernetes (with canal)..."
rm /etc/containerd/config.toml
systemctl restart containerd
kubeadm init --config kubeadm-config.yaml # add --apiserver-advertise-address="ip" if you want to use a different IP address than the main server IP


#export KUBECONFIG=/etc/kubernetes/admin.conf
#curl https://docs.projectcalico.org/manifests/calico.yaml -O
#kubectl apply -f calico.yaml
#curl https://docs.projectcalico.org/manifests/canal.yaml -O
#kubectl apply -f canal.yaml


curl -L https://github.com/kubernetes-sigs/kustomize/releases/download/v3.2.0/kustomize_3.2.0_linux_amd64 -o /usr/local/bin/kustomize
chmod +x /usr/local/bin/kustomize
git clone https://github.com/kubeflow/manifests.git
