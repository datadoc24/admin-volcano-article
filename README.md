# Volcano gang-scheduling on Kubernetes - accompaniment to article in Admin Magazine
This repo and Readme contain everything needed to replicate the setup described in the article, starting with creating a Kubernetes cluster on Digial Ocean using OpenTofu. If you already have a Kubernetest cluster, skip ahead to section 3.


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
