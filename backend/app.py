from flask import Flask, jsonify, request
from flask_cors import CORS
from supabase import create_client
from dotenv import load_dotenv
import os

load_dotenv()

app = Flask(__name__)
CORS(app)

SUPABASE_URL = os.getenv("SUPABASE_URL")
SUPABASE_KEY = os.getenv("SUPABASE_KEY")

supabase = create_client(SUPABASE_URL, SUPABASE_KEY)


@app.route("/")
def home():
    return jsonify({
        "message": "BedLink API is running!",
        "status": "success"
    })


@app.route("/health")
def health():
    return jsonify({"status": "healthy"})


@app.route("/test-db")
def test_db():
    try:
        result = supabase.table("hospitals").select("id").limit(1).execute()
        return jsonify({
            "status": "success",
            "message": "Connected to Supabase!",
            "hospitals_found": len(result.data)
        })
    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route("/hospitals")
def get_hospitals():
    try:
        hospitals = supabase.table("hospitals") \
            .select("*") \
            .eq("is_active", True) \
            .execute()

        beds = supabase.table("beds") \
            .select("*") \
            .eq("status", "available") \
            .execute()

        result = []

        for hospital in hospitals.data:
            available_beds = [
                bed for bed in beds.data
                if bed["hospital_id"] == hospital["id"]
            ]

            result.append({
                "id": hospital["id"],
                "name": hospital["name"],
                "address": hospital["address"],
                "latitude": hospital["latitude"],
                "longitude": hospital["longitude"],
                "facilities": hospital["facilities"],
                "available_beds": available_beds
            })

        return jsonify(result)

    except Exception as e:
        return jsonify({"error": str(e)}), 500

@app.route("/match-hospitals", methods=["POST"])
def match_hospitals():
    data = request.get_json()

    bed_type = data.get("bed_type")
    required_facilities = data.get("required_facilities", [])

    if not bed_type:
        return jsonify({"error": "Bed type is required"}), 400

    try:
        # Find hospitals with available beds of the required type
        beds = (
            supabase.table("beds")
            .select("hospital_id")
            .eq("bed_type", bed_type)
            .eq("status", "available")
            .execute()
        )

        hospital_ids = list(set(
            bed["hospital_id"] for bed in beds.data
        ))

        matches = []

        for hospital_id in hospital_ids:
            hospital_result = (
                supabase.table("hospitals")
                .select("*")
                .eq("id", hospital_id)
                .eq("is_active", True)
                .execute()
            )

            if not hospital_result.data:
                continue

            hospital = hospital_result.data[0]
            facilities = hospital.get("facilities") or []

            if not all(
                facility in facilities
                for facility in required_facilities
            ):
                continue

            matches.append({
                "hospital_id": hospital["id"],
                "name": hospital["name"],
                "address": hospital["address"],
                "bed_type": bed_type,
                "hospital_load": hospital["hospital_load"],
                "facilities": facilities
            })

        matches.sort(
            key=lambda hospital: hospital["hospital_load"]
        )

        return jsonify({
            "status": "success",
            "total_matches": len(matches),
            "hospitals": matches
        })

    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500
        
if __name__ == "__main__":
    app.run(debug=True, port=5000)