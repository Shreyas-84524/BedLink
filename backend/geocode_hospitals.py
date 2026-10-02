import os
import time
import requests
import pandas as pd
from dotenv import load_dotenv

load_dotenv()

API_KEY = os.getenv("GEOAPIFY_API_KEY")
if not API_KEY:
            
    raise ValueError("Geoapify API key missing from .env")

INPUT_FILE = "hospitals_minus21.csv"
OUTPUT_FILE = "hospitals_geocoded.csv"
JOB_FILE = "geocode_jobs.json"

BATCH_SIZE = 20
BASE_URL = "https://api.geoapify.com/v1/batch/geocode/search"

df = pd.read_csv(INPUT_FILE)

df["latitude"] = pd.to_numeric(df["latitude"], errors="coerce")
df["longitude"] = pd.to_numeric(df["longitude"], errors="coerce")

# Keep only hospitals missing coordinates.
missing = df[
    df["latitude"].isna() | df["longitude"].isna()
].copy()


def make_address(row):
    name = str(row.get("name", "")).strip()
    address = str(row.get("address", "")).strip()

    if address.lower() == "nan":
        address = ""

    return f"{name}, {address}, Mumbai, Maharashtra, India"


def submit_batch(batch):
    addresses = [make_address(row) for _, row in batch.iterrows()]

    response = requests.post(
        BASE_URL,
        params={"apiKey": API_KEY},
        json=addresses,
        timeout=60
    )
    response.raise_for_status()

    # Geoapify may return results immediately or a job ID.
    data = response.json()

    if response.status_code == 200:
        return data

    job_id = data.get("id")
    if not job_id:
        raise RuntimeError("No job ID returned by Geoapify.")

    print(f"Batch submitted. Job ID: {job_id}")
    return poll_batch(job_id)


def poll_batch(job_id):
    for attempt in range(60):
        time.sleep(10)

        response = requests.get(
            BASE_URL,
            params={"apiKey": API_KEY, "id": job_id},
            timeout=60
        )

        if response.status_code == 200:
            return response.json()

        if response.status_code == 202:
            print(f"Still processing... ({attempt + 1}/60)")
            continue

        response.raise_for_status()

    raise TimeoutError(f"Batch {job_id} is still processing.")


def extract_features(result):
    # Handle either a FeatureCollection or a list of results.
    if isinstance(result, dict):
        if result.get("type") == "FeatureCollection":
            return result.get("features", [])

        if "features" in result:
            return result["features"]

        if "results" in result:
            return result["results"]

    if isinstance(result, list):
        return result

    return []


def save_results(batch, results):
    features = extract_features(results)

    print("Received results:", len(features))

    for position, (_, row) in enumerate(batch.iterrows()):
        if position >= len(features):
            print(f"No result for: {row['name']}")
            continue

        item = features[position]

        # Geoapify may return a Feature or a result object.
        properties = item.get("properties", item)

        lat = properties.get("lat")
        lon = properties.get("lon")

        if lat is not None and lon is not None:
            df.at[row.name, "latitude"] = lat
            df.at[row.name, "longitude"] = lon
            print(f"Found: {row['name']} ({lat}, {lon})")
        else:
            print(f"No coordinates found: {row['name']}")

    df.to_csv(OUTPUT_FILE, index=False)
    print("Progress saved.")


print(f"Total hospitals: {len(df)}")
print(f"Hospitals needing coordinates: {len(missing)}")

# Start with only one hospital.
# Process all remaining hospitals in batches.
for start in range(0, len(missing), BATCH_SIZE):

    batch = missing.iloc[start:start + BATCH_SIZE]

    print(
        f"\nProcessing hospitals "
        f"{start + 1}-{start + len(batch)} of {len(missing)}"
    )

    try:
        results = submit_batch(batch)
        save_results(batch, results)

    except Exception as error:
        print(f"Batch failed: {error}")
        print("Stopping to avoid unnecessary API requests.")
        break

    time.sleep(2)

completed = (
    df["latitude"].notna() &
    df["longitude"].notna()
)

print("\n==============================")
print("GEOCODING COMPLETE")
print("==============================")
print(f"Hospitals with coordinates: {completed.sum()} / {len(df)}")
print(f"Still missing: {len(df) - completed.sum()}")
print(f"Output: {OUTPUT_FILE}")