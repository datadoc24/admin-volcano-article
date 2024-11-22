#!/bin/bash
#Export your Digital Ocean Personal Access Token (with all scopes enabled) as DO_PAT
#for example
#export DO_PAT=do_v1_xxxxxxx

if [ -z "${DO_PAT}" ]; then
    echo "Please export your Digital Ocean PAT as DO_PAT and retry"
    exit 1
fi

tofu init
tofu plan -var "do_token=${DO_PAT}"
tofu apply -var "do_token=${DO_PAT}" -auto-approve
tofu output -raw kubeconfig > ~/.kube/dok8s-config

export APISERVER=$(tofu output -raw apiserver)
export KUBECONFIG="~/.kube/dok8s-config"
echo -e "API server: $APISERVER\nKUBECONFIG location: $KUBECONFIG"
