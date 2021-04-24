#!/bin/bash

# get bucket names from terraform output
INPUT_BUCKET=$(cd terraform && terraform output -json | jq -r .input_bucket.value)
OUTPUT_BUCKET=$(cd terraform && terraform output -json | jq -r .output_bucket.value)

for BUCKET in $INPUT_BUCKET $OUTPUT_BUCKET
do
	read -p "Do you wish to delete all files in the bucket ${BUCKET} (yes/no)? " choice
	case "$choice" in 
	  yes ) 
			gsutil rm "gs://${BUCKET}/**"
			;;
	  no ) 
			exit;;
	  * ) 
			echo "Invalid choice. Skipped.";;
	esac
done

read -p "Do you wish to destroy the infrastructure (yes/no)? " choice
case "$choice" in 
  yes ) 
		(cd terraform && 
			terraform state rm "google_project_iam_member.project_owner" &&
			terraform destroy)
		;;
  no ) 
		exit;;
  * ) 
		echo "Invalid choice. Skipped.";;
esac
