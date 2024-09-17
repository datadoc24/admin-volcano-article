FROM debian:12

WORKDIR /root
RUN apt update && apt install -y python3
RUN apt install -y python3-pip
RUN apt install -y python3-boto3
COPY s3wordcount.py .
ENTRYPOINT ["python3","s3wordcount.py"]
