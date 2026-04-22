from flask import Flask, request, jsonify
import joblib
import numpy as np

# Initialize the Flask app
app = Flask(__name__)

# Load the trained model and label encoders
model = joblib.load('fertilizer_model.pkl')
label_encoders = joblib.load('label_encoders.pkl')

@app.route('/predict_fertilizer', methods=['POST'])
def predict():
    try:
        # Extract data from the request
        data = request.get_json()

        # Prepare input data
        crop = data['crop']
        stage = data['stage']
        soil_type = data['soil_type']
        N = data['N']
        P = data['P']
        K = data['K']
        pH = data['pH']
        organic_carbon = data['organic_carbon']
        temp = data['temp']
        rainfall = data['rainfall']

        # Encode categorical data
        crop_encoded = label_encoders['Crop'].transform([crop])[0]
        stage_encoded = label_encoders['Stage'].transform([stage])[0]
        soil_type_encoded = label_encoders['Soil_Type'].transform([soil_type])[0]

        # Prepare the feature array — order must match training column order:
        # ['Crop', 'Stage', 'N (kg/ha)', 'P (kg/ha)', 'K (kg/ha)', 'pH', 'Organic_Carbon', 'Temp (°C)', 'Rainfall (mm)', 'Soil_Type']
        features = np.array([[crop_encoded, stage_encoded, N, P, K, pH, organic_carbon, temp, rainfall, soil_type_encoded]])

        # Predict fertilizer recommendation
        prediction = model.predict(features)

        # Convert from kg/acre to kg/ha (1 acre = 0.4047 ha, so kg/ha = kg/acre / 0.4047)
        ACRE_TO_HA = 1 / 0.4047  # = 2.471
        urea_ha    = round(prediction[0][0] * ACRE_TO_HA, 1)
        dap_ha     = round(prediction[0][1] * ACRE_TO_HA, 1)
        mop_ha     = round(prediction[0][2] * ACRE_TO_HA, 1)
        ssp_ha     = round(prediction[0][3] * ACRE_TO_HA, 1)
        compost_ha = round(prediction[0][4] * ACRE_TO_HA, 1)

        # Format the prediction as a string (kg/ha)
        response = f"{dap_ha}kg DAP + {mop_ha}kg MOP + {urea_ha}kg Urea + {ssp_ha}kg SSP + {compost_ha}kg Compost"

        return jsonify({"recommendation": response})
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True)