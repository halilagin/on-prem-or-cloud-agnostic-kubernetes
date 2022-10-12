#kubectl label --overwrite namespace cert-manager foo=bar
kubectl label --overwrite namespace cert-manager cert-manager.io/disable-validation="true"

