repo_root=on-prem-or-cloud-agnostic-kubernetes
cd ~/${repo_root}/scripts && sudo sh install-kubernetes.sh >/tmp/kube_install.log 2>&1 
sh ~/${repo_root}/scripts/kubernetes_master_postinstall.sh

