
# get bucket names from terraform output
INPUT_BUCKET=$(cd terraform && terraform output -json | jq -r .input_bucket.value)
OUTPUT_BUCKET=$(cd terraform && terraform output -json | jq -r .output_bucket.value)

OUTPUT_FILE=gs://${OUTPUT_BUCKET}/financial_statements.csv

# upload data to input bucket
gsutil cp app/data/yahoo_financials.csv gs://${INPUT_BUCKET}/financial_statements.csv

while true; 
do
	 check if forecast exists, returns 0 if yes, 1 if not 
	# (ref. https://cloud.google.com/storage/docs/gsutil/commands/stat#description)
	gsutil -q stat OUTPUT_FILE

	# if [ $? -eq 0 ]
	# then
	#   gsutil cp OUTPUT_FILE app/data/hyndsight_forecast.csv 
	#   echo "Downloaded forecast.";

	#   gsutil rm OUTPUT_FILE
	#   echo "Remote forecast deleted.";

	#   break;
	# else
	#   echo "Waiting for forecast.";
	# fi;

	sleep 1;
done
