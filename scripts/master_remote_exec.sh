repo_root=on-prem-or-cloud-agnostic-kubernetes
#sudo bash -c "echo ${self.private_ip} kubemaster >>/etc/hosts" 
echo ${self.private_ip} >~/private_ip.txt
cd ~/${repo_root}/scripts && sudo sh install-kubernetes.sh >/tmp/kube_install.log 2>&1 
sh ~/${repo_root}/scripts/kubernetes_master_postinstall.sh

