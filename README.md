# Volcano gang-scheduling on Kubernetes - accompaniment to Admin Magazine article.
This repo contains everything needed to replicate the environment and examples in the article, starting by creating a GPU-enabled Kubernetes cluster on Digital Ocean using OpenTofu. The GPUs are optional, and if you already have a Kubernetes cluster, skip ahead to section 2.

## 1. Creating a test Kubernetes cluster with GPUs, Minio and Volcano.

See the [digital-ocean-kubernetes-cluster](digital-ocean-kubernetes-cluster) directory and its README file. Obviously, there are loads of ways to create a Kubernetes cluster; in this case, because I needed access to GPU hosts while wanting to minimize costs, I used a Terraform-based approach to store my entire setup 'as code' and only deploy it when actively working on it. The GPU aspect is particularly relevant to the 'real-world' use case of Volcano, because the GPUs are the resources that are likely to be shared between competing users and therefore lead to scheduling lock. However, you can run all the examples without GPUs, in which case you can just microk8s in your local workstation or something similar.

## 2. The single-pod wordcount job

See the [single-pod-wordcount-job](single-pod-wordcount-job) directory. If you like, build your own image based on the contents of the 'image' subdirectory, otherwise deploy wordcount-pod.yaml by followng the bash snippet given in the artcile. This example demonstrates how kube-scheduler copes just fine when handling multiple instances of a single-pod batch job. Even if the cluster only has enough resources to schedule one of the specified pods at a time, we can still create as many job objects as we like simultaneously. kube-scheduler will schedule them one by one until they are all done. Volcano is not required in this use case.

## 3. Building Apache Spark to work with Kubernetes and Volcano

See the [spark-on-kubernetes](spark-on-kubernetes) directory and its README file. This example is somewhat involved because the pre-compiled Spark binaries don't support Volcano scheduler - that's why you have to go through the process of building your own Spark.

Run a test spark job. The K8S cluster in the TF script (1 master, 2 x 4cpu/8GB workers) has plenty of capacity to run this test job, and just enough capacity to run 2 simultaneous instances of it; so we can easily contrive a situation where the cluster has no capacity for new jobs, and see the scheduling lock scenario

## 4. The example Pytorch DDP (Distributed Data Parallel) job

See the [kubeflow-training-operator](kubeflow-training-operator) directory; also, check the [prerequisites](https://www.kubeflow.org/docs/components/training/getting-started/) for your local Python environment. This example is a lightly-modified version of the example shown on that Kubeflow docs page, in which we use Python threads to create several jobs simultaneously. When Volcano is not deployed in the cluster we see scheduling lock, with partial deployment of 2 jobs at once, and when Volcano is deployed, we see that the training operator works with volcano to create the one by one. The 'PyTorch' section of the article shows how to run the examples given here.
