## Build your own version of Apache Spark that includes Volcano support and AWS S3 connectivity

### Download Spark source code of desired version:
https://spark.apache.org/downloads.html - select package type 'Source code' and extract the download to a local directory of your choice. 

### Ensure that Java, R, Python and Make are installed, and build Spark
```
#this apt command is just an example - adapt it to suit the packages available in your environment
sudo apt install -y r-base-core openjdk-11-jdk make python3.12
#check that the packages did get installed and added to your path
R --version && python --version && make --version && java --version
#export some options for the spark build
export MAVEN_OPTS="-Xss64m -Xmx2g -XX:ReservedCodeCacheSize=1g"  
./dev/make-distribution.sh --name custom-spark --pip --r --tgz -Psparkr -Phive -Phive-thriftserver -Pkubernetes -Pvolcano  
```
### Install your new Spark locally, along with extra jars for S3 compatibility
Extract the resulting tgz output to *another* local directory and set the SPARK_HOME env to point to that new directory. This is your local Spark installation. In the example, we use S3-comptible object storage (Minio) to store the text sources that our job will process, so place these 2 jars under $SPARK_HOME/jars to give Spark the S3 classes that it needs:
[hadoop-aws-3.3.4.jar](https://repo1.maven.org/maven2/org/apache/hadoop/hadoop-aws/3.3.4/hadoop-aws-3.3.4.jar)
[aws-java-sdk-bundle-1.12.262.jar](https://repo1.maven.org/maven2/com/amazonaws/aws-java-sdk-bundle/1.12.262/aws-java-sdk-bundle-1.12.262.jar)

### Build a container image containing your new Spark, for Kubernetes deployment
```
./bin/docker-image-tool.sh -r yourregistrytag/spark351 -t v01 build
```
Use Push the image to dockerhub or whatever registry your Kubernetes cluster can access.

Apply spark-rbac.yaml to your cluster. This ensures that your Spakr jobs' driver pods have all the rights they need to create executor pods, access storage and so on.
```
kubectl apply -f spark-rbac.yaml
```
You can now run the spark-submit examples from the article.
