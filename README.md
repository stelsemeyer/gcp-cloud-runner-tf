# Serverless & containerized tasks using Google Cloud Run, Pub/Sub, Cloud Storage and Terraform

<p align="center">
  <img src="architecture.png" />
</p>

## Overview


We will build a serverless service which will listen to new files in a Cloud Storage bucket via Pub/Sub, run some small containzerized process via Cloud Run once files are available and publish results of the process to another bucket.

As a process here I will run a simple logistic regression model.

- [Google Cloud Run](https://cloud.google.com/run) is a service to run containers on a serverless infrastructure.
- [Google Pub/Sub](https://cloud.google.com/pubsub/architecture) is a asynchronous messaging service which allows decoupling of sender and receiver of messages.
- [Google Cloud Storage](https://cloud.google.com/storage) is a service to store objects.
- [terraform](https://www.terraform.io/) is a infrastructure-as-code software.


## Prerequisites

Google authentication to enable planning and applying with terraform and updating the image:

```
gcloud auth application-default login
```

You can check if you are authenticated with the right user using `gcloud auth list`.


## Setup

Run terraform plan & apply using the setup script `setup.sh` which contains the following steps:

```
# build container once to enable caching
(cd app && 
	docker build -t cloud-runner .)

(cd terraform && 
	terraform init && 
	terraform apply)
```


We can upload the dataset to GCS with `gsutil`:

```
gsutil cp app/data/financial_statements.csv gs://my-cloud-runner-input-bucket/financial_statements.csv
```

If our infrastructure works properly we can check the Cloud Run logs in the Google console, and We should see that the container received some data and returning an output.


## Deploy new image

Run the simple deploy script `deploy.sh` which contains the following steps:

```
# get project id, image output and service name from terraform output
PROJECT_ID=$(cd terraform && terraform output -json | jq -r .project_id.value)
IMAGE_URI=$(cd terraform && terraform output -json | jq -r .image_uri.value)
SERVICE_NAME=$(cd terraform && terraform output -json | jq -r .service_name.value)

# build and push image
(cd app && 
	./build.sh && 
	IMAGE_URI=$IMAGE_URI ./push.sh)

# update image
gcloud --project $PROJECT_ID \
	run services update $SERVICE_NAME \
	--image $IMAGE_URI \
	--platform managed \
	--region europe-west3

# send traffic to latest
gcloud --project $PROJECT_ID \
	run services update-traffic $SERVICE_NAME \
	--platform managed \
	--region europe-west3 \
	--to-latest

```

## Destroy

Run the destroy script `_destroy.sh` to delete(!) the bucket contents and the project or execute the following steps:

```
# # delete bucket content
# gsutil rm "gs://my-cloud-runner-input-bucket/**"
# gsutil rm "gs://my-cloud-runner-output-bucket/**"
# 
# # destroy infra
# (cd terraform && 
# 	terraform state rm "google_project_iam_member.project_owner" &&
# 	terraform destroy)
```

## Remarks

- Cloud Run run has a [maximum timeout](https://cloud.google.com/run/docs/configuring/request-timeout) of 15 minutes, Google Pub/Sub has a [maximum acknowledge time](https://github.com/googleapis/google-cloud-go/issues/608) of 10 minutes, making it useless for more time-consuming tasks. You can use [bigger resources](https://cloud.google.com/run/docs/configuring/cpu#yaml) though to speed up the processing time.
