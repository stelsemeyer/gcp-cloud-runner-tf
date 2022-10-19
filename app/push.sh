#!/bin/bash

docker tag cloud-runner $IMAGE_URI 
docker push $IMAGE_URI 

