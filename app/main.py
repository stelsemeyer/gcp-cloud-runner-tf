import base64
import os
import json
import pandas as pd
import logging

from flask import Flask, request
from app.model import forecast
from model import forecast


OUTPUT_BUCKET = os.environ.get("OUTPUT").replace("gs://", "")


log = logging.getLogger()
app = Flask(__name__)


@app.route("/", methods=["POST"])
def index():
    # https://cloud.google.com/storage/docs/json_api/v1/objects
    envelope = request.get_json()

    if not envelope:
        msg = "No message received"
        log.error(f"Error: {msg}")
        return f"Bad Request: {msg}", 400

    if not isinstance(envelope, dict) or "message" not in envelope:
        msg = "Invalid message format"
        log.error(f"Error: {msg}")
        return f"Bad Request: {msg}", 400

    message = envelope["message"]

    data = {}
    if isinstance(message, dict) and "data" in message:
        payload = base64.b64decode(message["data"]).decode("utf-8").strip()
        data = json.loads(payload)

    log.info(f"Data received: {data}")

    bucket = data["bucket"]
    name = data["name"]

    input_file = f"gs://{bucket}/{name}"
    log.info(f"Input file: {input_file}")
    df = pd.read_csv(input_file)

    output = forecast(df)

    output_file = f"gs://{OUTPUT_BUCKET}/{name}"
    log.info(f"Output file: {output_file}")
    output.to_csv(output_file, index=False)

    return ("", 204)
    #return ('buy or sell with balanced accuracy',output_df )
