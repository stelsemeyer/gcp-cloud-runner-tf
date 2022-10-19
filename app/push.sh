#!/bin/bash

docker tag stocks $IMAGE_URI
docker push $IMAGE_URI

