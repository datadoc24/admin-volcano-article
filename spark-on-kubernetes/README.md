**Build your own version of Apache Spark that include Volcano support and AWS S3 connectivity**  

Download Spark source code of desired version:  
https://spark.apache.org/downloads.html - select package type 'Source code' and extract the download to a local dir  

Ensure that Java, R, Python and Make are installed:  
sudo apt install r-base-core  
R --version && python --version && make --version && java --version  

export MAVEN_OPTS="-Xss64m -Xmx2g -XX:ReservedCodeCacheSize=1g"  
./dev/make-distribution.sh --name custom-spark --pip --r --tgz -Psparkr -Phive -Phive-thriftserver -Pkubernetes -Pvolcano  

Extract the resulting tgz output to another directory of your choice and set the SPARK_HOME env to point to that new directory.
Build a Spark container image containing the S3 jars as well. S3 connectivity is very helpful when running Spark in a hybrid environment, where you run spark-submit on your local PC but the Spark cluster itself is in public cloud. Download these  jars from Maven and place them at $SPARK_HOME/jars
hadoop-aws-3.3.4.jar  
aws-java-sdk-bundle-1.12.262.jar
./bin/docker-image-tool.sh -r abesharphpe/spark351 -t 03 build
Push the image to dockerhub or whatever registry your Kubernetes cluster can access.
Run a test spark job. The K8S cluster in the TF script (1 master, 2 x 4cpu/8GB workers) has plenty of capacity to run this test job, and just enough capacity to run 2 simultaneous instances of it; so we can easily contrive a situation where the cluster has no capacity for new jobs, and see the scheduling lock scenario
