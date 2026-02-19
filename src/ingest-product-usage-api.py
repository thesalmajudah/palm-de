import requests
import json
from datetime import datetime, timedelta
from azure.storage.blob import BlobServiceClient

def fetch_product_usage(start_date, end_date):

    current_date = start_date

    while current_date <= end_date:

        response = requests.get(
            "https://api.product.com/usage",
            params={
                "date": current_date.strftime("%Y-%m-%d")
            },
            headers={
                "Authorization": "Bearer <TOKEN>"
            }
        )

        if response.status_code != 200:
            raise Exception(f"API failed for {current_date}")

        data = response.json()

        # Write to Azure Blob
        blob_path = f"raw/product_usage/{current_date}.json"

        upload_to_blob(blob_path, json.dumps(data))

        current_date += timedelta(days=1)


def upload_to_blob(path, data):
    blob_service = BlobServiceClient.from_connection_string("<CONNECTION_STRING>")
    blob_client = blob_service.get_blob_client(
        container="datalake",
        blob=path
    )
    blob_client.upload_blob(data, overwrite=True)