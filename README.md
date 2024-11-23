# Volcano gang-scheduling on Kubernetes - accompaniment to article in Admin Magazine
This repo and Readme contain everything needed to replicate the setup described in the article, starting with creating a Kubernetes cluster on Digial Ocean using OpenTofu. If you already have a Kubernetest cluster, skip ahead to section 3.

## 1. Install local tools
On your local Linux workstation: Install [OpenTofu](https://opentofu.org/docs/intro/install/deb/) (the open-source fork of Terraform), [Kubectl](https://kubernetes.io/docs/tasks/tools/install-kubectl-linux/) (the command-line tool for interacting with a Kubernetes cluster via its API server) and [Helm](https://helm.sh/docs/intro/install/) (a tool for easily installing applications by means of 'charts').

```
curl --proto '=https' --tlsv1.2 -fsSL https://get.opentofu.org/install-opentofu.sh -o install-opentofu.sh
chmod +x install-opentofu.sh
./install-opentofu.sh --install-method deb

curl -LO "https://dl.k8s.io/release/$(curl -L -s https://dl.k8s.io/release/stable.txt)/bin/linux/amd64/kubectl"

curl -fsSL -o get_helm.sh https://raw.githubusercontent.com/helm/helm/main/scripts/get-helm-3
chmod 700 get_helm.sh
./get_helm.sh
```
## 2. Use OpenTofu to create a Kubernetes cluster on Digital Ocean

Clone this repo to a local directory on your workstation

Sign into the web console of your Digital Ocean account and create an all-access Personal Access Token under the 'API' menu.

In your workstation's terminal, export the Digital Ocean PAT as DO_PAT

Edit dok8s.tf to customize the cluster name, Digital Ocean region, and Kubernetes version, if desired (Digital Ocean frequently updates its list of supported Kubernetes versions, and you have to choose one of the currently available options, otherwise the creation script will fail. Check this list [https://slugs.do-api.dev/](https://slugs.do-api.dev/) to see current valid choices for region, Kubernetes version and droplet (worker node) size. Feel free to change the node_pool size and node_count values to suit your own purposes, however, the commands used in the article to induce scheduling lock are geared around a cluster with 2 worker nodes each of 4 cpu and 8GB. If you have a larger-capacity cluster, you won't get scheduling lock with the examples given!

Run the script (use source to ensure that the relevant output values are exported to your shell)
```
source ./create-do-k8s.sh
```

Check that all the pods are in running state: kubectl get po -A

## 3. Install the Helm charts for Minio and Volcano, and the rbac needed for Apache Spark on Kubernetes

Install Minio for Apache Spark's object storage
```
helm -n minio install objectstore oci://registry-1.docker.io/bitnamicharts/minio --create-namespace
```
The helm output tells you how to find out the admin password of the new deployment. Edit the service in the  minio namespace to expose ports 9000 and 9001 via a load balancer or nodeport. In the case of Digital Ocean, all you need to do is change the service type from ClusterIP to LoadBalancer. Digital Ocean's control plane picks this up and, within 5 minutes or so, creates a load balancer on a public IP address to make these services accessible for you. Or, use kubectl port forwarding to save a few cents.

## 4. The single-pod wordcount job

This example is to demonstrate how kube-scheduler copes just fine when a batch job executes in just a single pod. Even if the cluster only has enough resources to schedule one of the specified pods at once, we can still schedule as many as we like simultaneously. kube-scheduler will schedule them one by one until they are all done. Volcano is not required in this use case.

## 5. Building Apache Spark to work with Kubernetes and Volcano

For the example Spark workload:
2 - Create the spark rbac
3 - Build a version of Spark that supports Volcano on Kubernetes:
Install Java, Python, R and make
Download Spark source code
export MAVEN_OPTS="-Xss64m -Xmx2g -XX:ReservedCodeCacheSize=1g"
./dev/make-distribution.sh --name custom-spark --pip --r --tgz -Psparkr -Phive -Phive-thriftserver -Pkubernetes -Pvolcano
Extract the resulting tgz output to another directory of your choice and set the SPARK_HOME env to that new directory
Build a Spark container image containing the S3 jars as well. S3 connectivity is very helpful when running Spark in hybrid (and ephemeral)
Tag and push the image
Run a test spark job. The K8S cluster in the TF script (1 master, 2 x 4cpu/8GB workers) has plenty of capacity to run this test job, and just enough capacity to run 2 simultaneous instances of it; so we can easily contrive a situation where the cluster has no capacity for new jobs, and see the scheduling lock scenario

## 6. The example Pytorch DDP (Distributed Data Parallel) job
This example is a lightly-modified version of the example at [https://www.kubeflow.org/docs/components/training/getting-started/] in which we use Python threads to create several jobs simultaneously. When Volcano is not deployed in the cluster we see scheduling lock, with partial deployment of 2 jobs at once, and when Volcano is deployed, we see that the training operator works with volcano to create the one by one.
