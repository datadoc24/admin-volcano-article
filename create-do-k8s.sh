#!/bin/bash
tofu init
tofu plan
tofu apply -auto-approve
tofu output -raw kubeconfig > ~/.kube/dok8s-config
export APISERVER=$(tofu output -raw apiserver)
export KUBECONFIG="/home/abe/.kube/dok8s-config"
