import os
import pandas as pd
from dotenv import load_dotenv
from supabase import create_client

load_dotenv()

URL = os.getenv("SUPABASE_URL")
KEY = os.getenv("SUPABASE_KEY")

if not URL or not KEY:
    raise ValueError("Supabase credentials missing from .env")

supabase = create_client(URL, KEY)

# Read the geocoded CSV
df = pd.read_csv("hospitals_geocoded.csv")

target_names = [
    "Asha Pediatric Hospital",
    "Ashvini Nursing & Maternity Home, Dadar (E)",
    "Desai Memorial Hospital, Parel",
    "Dr B K Nadkarni Memorial Maternity & Surgical Hospital, Parel",
    "Dr Gadre's Nursing & Maternity Hospital",
    "Dr Shilpa Abhyankar Nursing Home",
    "Dr. Niranjn Unesh Joshi Nursing Home",
    "Hinduja Hospital",
    "KB HB Charitable E N T Hospital, Parel",
    "M/s. Samarth Eye Care And Laser Centre",
    "Mahatma Gandhi Memorial Hospital",
    "Mata Laxmi Trust Hospital",
    "Navroji Wadia Maternity Hospital",
    "Prashanti Medical Centre and Nursing Home",
    "Sai Sanjeevani Hospital",
    "Shobhana Nursing Home",
    "Silver Coin Nursing Home",
    "Tata Memorial Hospital",
    "Tilak Hospital",
    "Vaidya Hospital",
    "Vasudha Hospital"
]

df = df[df["name"].isin(target_names)].copy()

# Keep only hospitals with valid coordinates
df["latitude"] = pd.to_numeric(df["latitude"], errors="coerce")
df["longitude"] = pd.to_numeric(df["longitude"], errors="coerce")

valid = df[
    df["id"].notna()
    & df["latitude"].between(-90, 90)
    & df["longitude"].between(-180, 180)
].copy()

print(f"Total hospitals in CSV: {len(df)}")
print(f"Hospitals with valid coordinates: {len(valid)}")

confirm = input("Update Supabase with these coordinates? (yes/no): ")

if confirm.lower() != "yes":
    print("Update cancelled.")
    raise SystemExit

updated = 0
failed = []

for _, row in valid.iterrows():
    try:
        # Fetch the hospital's current coordinates
        result = supabase.table("hospitals") \
            .select("latitude, longitude") \
            .eq("id", row["id"]) \
            .execute()

        if not result.data:
            continue

        hospital = result.data[0]

        # Update only if latitude or longitude is NULL
        if hospital["latitude"] is None or hospital["longitude"] is None:
            supabase.table("hospitals").update({
                "latitude": float(row["latitude"]),
                "longitude": float(row["longitude"])
            }).eq("id", row["id"]).execute()

            updated += 1

            if updated % 20 == 0:
                print(f"Updated {updated} hospitals")

    except Exception as e:
        failed.append((row["id"], str(e)))

print("\nUpdate finished!")
print(f"Successfully processed: {updated}")
print(f"Failed: {len(failed)}")

if failed:
    print("\nFailed hospital IDs:")
    for hospital_id, error in failed:
        print(hospital_id, error)