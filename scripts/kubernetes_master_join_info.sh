join_token=`kubeadm token list |grep authentication,signing |head -1|cut -d\  -f1`
join_cert_hash=`openssl x509 -in /etc/kubernetes/pki/ca.crt -pubkey -noout | openssl pkey -pubin -outform DER | openssl dgst -sha256`

cat <<EOF
{
"token":"${join_token}",
"cert_hash":"${cert_hash}"
}
EOF
