from flask import Flask, jsonify, request
import json
from flask_cors import CORS
from vincenty import vincenty

app = Flask(__name__)
CORS(app)

#Ambulance data load
ambulance_dict = {}

RANGE = 1


 
# Query string format /inrange?lat=&lon=
@app.route('/inrange', methods=['GET'])
def find_nearest_ambulance():
    args = request.args.to_dict()

    print(args)

    user_lat = args["lat"]
    user_lon = args["lon"]

    for key in ambulance_dict:
            if vincenty((float(user_lat), float(user_lon)), ambulance_dict[key]["location"]) < RANGE and int(ambulance_dict[key]["state"]) == 1:
                return jsonify({"val" : True})
    return jsonify({"val" : False})





@app.route('/ambulance/', methods=['POST'])
def save_ambulance_location():
    ambulance_id = int(request.form.get('ambulance_id'))
    ambulance_lat = request.form.get('lat')
    ambulance_lon = request.form.get('lon')
    #0 for inactive 1 for active
    ambulance_state = request.form.get('state')

    ambulance_dict[ambulance_id] =  {"state" : int(ambulance_state), "location" : (float(ambulance_lat), float(ambulance_lon))}
    return jsonify({"value" : True})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)