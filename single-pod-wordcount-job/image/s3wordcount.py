import os
import boto3
import string
from collections import Counter

# Create S3 client
s3 = boto3.resource(
    "s3",
    aws_access_key_id=os.environ['S3_ACCESS_KEY'],
    aws_secret_access_key=os.environ['S3_SECRET_KEY'],
    endpoint_url=os.environ['S3_ENDPOINT_URL']
)

obj = s3.Object(os.environ['S3_BUCKET'],os.environ['S3_FILENAME'])
data = obj.get()['Body'].read().decode("utf-8")

text = data.lower().translate(str.maketrans('', '', string.punctuation))
words = text.split()
word_count=Counter(words)


print(word_count)
