## Build your own version of Apache Spark that includes Volcano support and AWS S3 connectivity

### Download Spark source code of desired version:
https://spark.apache.org/downloads.html - select package type 'Source code' and extract the download to a local directory. 

### Ensure that Java, R, Python and Make are installed
```
sudo apt install r-base-core  
R --version && python --version && make --version && java --version  
export MAVEN_OPTS="-Xss64m -Xmx2g -XX:ReservedCodeCacheSize=1g"  
./dev/make-distribution.sh --name custom-spark --pip --r --tgz -Psparkr -Phive -Phive-thriftserver -Pkubernetes -Pvolcano  
```
Extract the resulting tgz output to another directory of your choice and set the SPARK_HOME env to point to that new directory.
Build a Spark container image containing the S3 jars as well. S3 connectivity is very helpful when running Spark in a hybrid environment, where you run spark-submit on your local PC but the Spark cluster itself is in public cloud. Search for these jars in Maven and download them to $SPARK_HOME/jars
hadoop-aws-3.3.4.jar  
aws-java-sdk-bundle-1.12.262.jar

### Build a container image with your new Spark
./bin/docker-image-tool.sh -r abesharphpe/spark351 -t 03 build
Push the image to dockerhub or whatever registry your Kubernetes cluster can access.

Apply spark-rbac.yaml to your cluster. This ensures that your Spakr jobs' driver pods have all the rights they need to create executor pods, access storage and so on.
```
kubectl apply -f spark-rbac.yaml
```
You can now run the spark-submit examples from the article.
