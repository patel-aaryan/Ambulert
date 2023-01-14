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

    user_lat = args["lat"]
    user_lon = args["lon"]

    for key in ambulance_dict:
        print(vincenty((args['lat'], args['lon']), ambulance_dict[key]))
        if vincenty((args['lat'], args['lon']), ambulance_dict[key]) < RANGE:
            return jsonify({"val" : True})
    return jsonify({"val" : False})





@app.route('/ambulance/', methods=['POST'])
def save_ambulance_location():
    ambulance_id = request.form.get('ambulance_id')
    ambulance_lat = request.form.get('lat')
    ambulance_lon = request.form.get('lon')

    ambulance_dict[ambulance_id] =  (ambulance_lat, ambulance_lon)
    return jsonify({"value" : True})

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=80)