import os
import random
import pandas as pd
from dotenv import load_dotenv
from supabase import create_client

# Connect to Supabase
load_dotenv()

url = os.getenv("SUPABASE_URL")
key = os.getenv("SUPABASE_KEY")

supabase = create_client(url, key)

# Read CSV
df = pd.read_csv("data/hospitals.csv")

# Clean data
df.columns = df.columns.str.strip()
df["Hospital Name"] = df["Hospital Name"].str.strip()
df["Address"] = df["Address"].fillna("").str.strip()

df = df.drop_duplicates(
    subset=["Hospital Name", "Address"]
)

# Mock bed types for the prototype
bed_types = ["general", "ICU", "emergency"]

for _, row in df.iterrows():
    name = row["Hospital Name"]
    address = row["Address"]

    if not name or not address:
        print(f"Skipping incomplete record: {name}")
        continue

    beds_value = row["No. of Beds"]
    total_beds = (
        int(beds_value)
        if pd.notna(beds_value) and beds_value >= 0
        else None
    )

    # Avoid importing the same hospital twice
    existing = (
        supabase.table("hospitals")
        .select("id")
        .eq("name", name)
        .eq("address", address)
        .execute()
    )

    if existing.data:
        print(f"Already exists: {name}")
        continue

    # Mock facilities (not verified hospital services)
    facilities = random.sample(
        ["ICU", "Emergency", "Trauma Care"],
        k=random.randint(1, 3)
    )

    hospital_data = {
        "name": name,
        "address": address,
        "latitude": None,
        "longitude": None,
        "ward_name": str(row["Ward Name"]),
        "hospital_type": str(
            row["Type of Hospital/Health facility"]
        ),
        "total_beds": total_beds,
        "contact": (
            str(row["Contact"])
            if pd.notna(row["Contact"])
            else None
        ),
        "hospital_load": random.randint(10, 90),
        "facilities": facilities,
        "is_active": True,
        "availability_is_simulated": True
    }

    result = (
        supabase.table("hospitals")
        .insert(hospital_data)
        .execute()
    )

    hospital_id = result.data[0]["id"]

    # Create a small sample of mock beds per hospital.
    # These are NOT the hospital's full bed inventory.
    bed_count = min(total_beds or 0, 5)

    mock_beds = []

    for i in range(bed_count):
        mock_beds.append({
            "hospital_id": hospital_id,
            "bed_type": bed_types[i % len(bed_types)],
            "status": random.choice(
                ["available", "occupied", "reserved"]
            )
        })

    if mock_beds:
        supabase.table("beds").insert(mock_beds).execute()

    print(f"Imported: {name}")

print("Hospital import complete!")