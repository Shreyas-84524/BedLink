
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

from math import radians, sin, cos, sqrt, atan2

def calculate_distance(lat1, lon1, lat2, lon2):
    earth_radius = 6371

    lat1, lon1, lat2, lon2 = map(
        radians, [lat1, lon1, lat2, lon2]
    )

    dlat = lat2 - lat1
    dlon = lon2 - lon1

    a = (
        sin(dlat / 2) ** 2
        + cos(lat1) * cos(lat2) * sin(dlon / 2) ** 2
    )

    return 2 * earth_radius * atan2(
        sqrt(a), sqrt(1 - a)
    )
    

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

@app.route("/ambulance-requests", methods=["POST"])
def create_ambulance_request():
    data = request.get_json(silent=True) or {}

    required = ["ambulance_id", "bed_type", "latitude", "longitude"]

    if any(field not in data for field in required):
        return jsonify({
            "status": "error",
            "message": "Missing required fields"
        }), 400

    try:
        request_data = {
            "ambulance_id": data["ambulance_id"],
            "bed_type": data["bed_type"],
            "latitude": data["latitude"],
            "longitude": data["longitude"],
            "required_facilities": data.get(
                "required_facilities", []
            ),
            "status": "pending"
        }

        result = (
            supabase.table("ambulance_requests")
            .insert(request_data)
            .execute()
        )

        return jsonify({
            "status": "success",
            "message": "Ambulance request created!",
            "request": result.data[0]
        }), 201

    except Exception as e:
        return jsonify({
            "status": "error",
            "message": str(e)
        }), 500

@app.route("/match-request/<request_id>", methods=["GET"])
def match_request(request_id):
    try:
        result = (
            supabase.table("ambulance_requests")
            .select("*")
            .eq("id", request_id)
            .execute()
        )

        if not result.data:
            return jsonify({
                "status": "error",
                "message": "Ambulance request not found"
            }), 404

        ambulance = result.data[0]

        # Use the saved request's bed and facility requirements
        bed_type = ambulance["bed_type"]
        required_facilities = ambulance.get("required_facilities") or []

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

            if hospital.get("latitude") is None or hospital.get("longitude") is None:
             continue

            distance = calculate_distance(
                float(ambulance["latitude"]),
                float(ambulance["longitude"]),
                float(hospital["latitude"]),
                float(hospital["longitude"])
            )

            matches.append({
                "hospital_id": hospital["id"],
                "name": hospital["name"],
                "address": hospital["address"],
                "bed_type": bed_type,
                "hospital_load": hospital["hospital_load"],
                "facilities": facilities,
                "distance_km": round(distance, 2)
            })

        matches.sort(
            key=lambda hospital: hospital["distance_km"]
        )

        return jsonify({
            "status": "success",
            "request_id": request_id,
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
