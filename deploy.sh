#!/bin/bash

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
