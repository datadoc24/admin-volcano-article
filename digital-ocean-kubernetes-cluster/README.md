# Creating a Kubernetes cluster on Digital Ocean
## 1. Install local tools
On your local workstation, install [OpenTofu](https://opentofu.org/docs/intro/install/deb/) (the open-source fork of Terraform), [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) (the command-line tool for interacting with a Kubernetes cluster via its API server) and [Helm](https://helm.sh/docs/intro/install/) (a tool for easily installing applications by means of 'charts').
```
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method deb

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```
## 2. Use OpenTofu to create a Kubernetes cluster (with optional GPU nodes) on Digital Ocean

Sign into your Digital Ocean control panel and create a custom Personal Access Token under the 'API' menu with all five 'Kubernetes' scopes selected.

In your workstation's terminal, export the Digital Ocean PAT as DO_PAT
```
export DO_PAT="v1_do_xxxxxx"
```
Edit dok8s.tf to customize the cluster name, Digital Ocean region, and Kubernetes version, if desired. Digital Ocean frequently updates its list of supported Kubernetes versions, and you have to choose one of the currently available options, otherwise the creation script will fail. Check this list [https://slugs.do-api.dev/](https://slugs.do-api.dev/) to see current valid choices for region, Kubernetes version and droplet (worker node) size.
You can change the node_pool size and node_count values to suit your own purposes, however, the scheduling lock examples are geared around a cluster with 2 worker nodes each of 4 cpu and 8GB.
Uncomment the gpu-pool section if you want GPU hosts. The H100 hosts are only available in the tor1 and nyc2 regions and need to be enabled on your Digital Ocean account and cost about $4/hr each.

Run the create script (use *source* to ensure that the relevant output values are exported to your shell):
```
source ./create-do-k8s.sh
```
When the script is complete, run *kubectl get po -A* to confirm that your cluster is accessible and working.

## 3. Install the Helm charts for Minio and Volcano, and the rbac needed for Apache Spark on Kubernetes

Install Minio for Apache Spark's object storage
```
helm -n minio install objectstore oci://registry-1.docker.io/bitnamicharts/minio --create-namespace
```
The helm output tells you how to find out the admin password of the new deployment. Edit the service in the  minio namespace to expose ports 9000 and 9001 via a load balancer or nodeport. In the case of Digital Ocean, all you need to do is change the service type from *ClusterIP* to *LoadBalancer*. Digital Ocean's control plane automatically detects this and, within 5 minutes or so, creates a load balancer on a public IP address to make these services accessible for you. Or, use kubectl port forwarding to save a few cents.

## 4. Destroy the cluster when done.
When done with the other examples, run the 'destroy' script to delete the cluster and all its resources from your Digital Ocean account. If you installed Minio, you need to manually delete its persistent volume from your Digitial Ocean control panel. If you exposed the Minio service via LoadBalancer, you need to delete the LoadBalancer from the control panel, too.
