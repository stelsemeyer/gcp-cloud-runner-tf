#!/bin/bash

# build container once to enable caching
(cd app && 
	./build.sh)

# init and apply terraform
(cd terraform && 
	terraform init && 
	terraform apply)
