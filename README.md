# Admin Magazine article about Volcano scheduling on Kubernetes

Install OpenTofu (the open-source fork of Terraform) on your workstation, along with Kubectl (the command-line tool for interacting with a Kubernetes cluster via its API server) and Helm (a tool for easily installing applications by means of 'charts').
```
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method deb
```
Clone this repo to a local directory on your workstation
Create an all-access Personal Access Token in your Digital Ocean account
Refer to https://slugs.do-api.dev/ to determine the APU slugs for the various Digital Ocean locations, server flavors and Kubernetes versions
Edit the Tofu scripts to set your desired choices for these values

Source the script. If you just execute it, like a normal bash script, it won't update the new APISERVER and KUBECONFIG envs in your shell

Check that all the pods are in running state: kubectl get po -A

Install the Helm chart for the Kubernetes Dashboard. This gives us a nice graphical view of the cluster's capacity. The alternative is simply to run kubectl top nodes

Add kubernetes-dashboard repository
```
helm repo add kubernetes-dashboard https://kubernetes.github.io/dashboard/
```
Deploy a Helm Release named "kubernetes-dashboard" using the kubernetes-dashboard chart
```
helm upgrade --install kubernetes-dashboard kubernetes-dashboard/kubernetes-dashboard --create-namespace --namespace kubernetes-dashboard
```
 

 
