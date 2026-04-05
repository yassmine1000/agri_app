# app.py
from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
import numpy as np
from PIL import Image
import io, json

# Load model
model = tf.keras.models.load_model("plant_disease_model.h5")

# Load class labels
with open("class_indices.json", "r") as f:
    class_indices = json.load(f)
classes = {v: k for k, v in class_indices.items()}  # reverse mapping

# Disease advice dictionary
disease_advice = {
    "Pepper__bell___Bacterial_spot": "Use certified seed, copper + mancozeb rotations, avoid working plants when wet.",
    "Pepper__bell___healthy": "Mulch to reduce soil splash, drip irrigation, rotate with non-hosts.",
    "Potato___Early_blight": "Remove lower leaves touching soil, apply chlorothalonil or mancozeb early; ensure K is adequate.",
    "Potato___Late_blight": "Destroy cull piles, avoid overhead irrigation, protectant + systemic fungicide rotations (e.g., chlorothalonil + cyazofamid).",
    "Potato___healthy": "Hilled rows, proper spacing, avoid waterlogging.",
    "Tomato_Bacterial_spot": "Use resistant seed/transplants, copper + mancozeb rotation, avoid handling when wet; sanitize tools.",
    "Tomato_Early_blight": "Mulch, remove lower leaves, rotate, chlorothalonil/mancozeb at first lesions; stake and prune for airflow.",
    "Tomato_Late_blight": "Destroy infected plants, strict sanitation, apply protectant + systemic fungicides; avoid high leaf wetness.",
    "Tomato_Leaf_Mold": "Reduce humidity in greenhouses; prune; copper-based fungicides if severe.",
    "Tomato_Septoria_leaf_spot": "Remove infected leaves, improve airflow, chlorothalonil or mancozeb sprays.",
    "Tomato_Spider_mites_Two_spotted_spider_mite": "Spray undersides with water, use horticultural oils/miticides; avoid plant stress.",
    "Tomato__Target_Spot": "Rotate, reduce humidity, fungicides (strobilurin/triazole) as needed.",
    "Tomato__Tomato_YellowLeaf__Curl_Virus": "Control whiteflies (yellow sticky traps, insecticides), remove infected plants, use resistant varieties.",
    "Tomato__Tomato_mosaic_virus": "Sanitize hands/tools, remove infected plants, resistant cultivars.",
    "Tomato_healthy": "Consistent watering at soil level, balanced fertilization, prune suckers, stake/cage for airflow.",
}

app = Flask(__name__)
CORS(app)

def preprocess_image(image_bytes):
    img = Image.open(io.BytesIO(image_bytes)).resize((128,128))
    img = np.array(img) / 255.0
    img = np.expand_dims(img, axis=0)
    return img

@app.route("/predict", methods=["POST"])
def predict():
    print("Received predict request")
    if "image" not in request.files:
        print("No 'image' found in request.files")
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files["image"]
    print(f"File received: {file.filename}")

    img_bytes = file.read()
    img = preprocess_image(img_bytes)
    prediction = model.predict(img)
    class_idx = np.argmax(prediction[0])
    disease_name = classes[class_idx]
    confidence = float(np.max(prediction[0]))
    print(f"Prediction: {disease_name}, Confidence: {confidence}")

    advice = disease_advice.get(disease_name, "No advice available for this disease.")

    return jsonify({
        "disease": disease_name,
        "confidence": confidence,
        "advice": advice
    })


@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=4000, debug=True)

