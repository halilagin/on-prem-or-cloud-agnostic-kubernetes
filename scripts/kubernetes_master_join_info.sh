join_token=`kubeadm token list |grep authentication,signing |head -1|cut -d\  -f1`
join_cert_hash=`openssl x509 -in /etc/kubernetes/pki/ca.crt -pubkey -noout | openssl pkey -pubin -outform DER | openssl dgst -sha256|cut -d= -f2 |xargs echo -n`

cat <<EOF
{
"token":"${join_token}",
"cert_hash":"${join_cert_hash}"
}
EOF
