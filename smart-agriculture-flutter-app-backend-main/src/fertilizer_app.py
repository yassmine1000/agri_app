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

        # Prepare the feature array
        features = np.array([[crop_encoded, stage_encoded, soil_type_encoded, N, P, K, pH, organic_carbon, temp, rainfall]])

        # Predict fertilizer recommendation
        prediction = model.predict(features)

        # Format the prediction as a string
        response = f"{round(prediction[0][1], 2)}kg DAP + {round(prediction[0][2], 2)}kg MOP + {round(prediction[0][0], 2)}kg Urea/acre + {round(prediction[0][3], 2)}kg SSP + {round(prediction[0][4], 2)}kg Compost"

        return jsonify({"recommendation": response})
    except Exception as e:
        return jsonify({"error": str(e)}), 400

# Run the Flask app
if __name__ == '__main__':
    app.run(debug=True)
