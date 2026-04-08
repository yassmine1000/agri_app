from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
import numpy as np
from PIL import Image
import io, json

# ── Charger les classes ──────────────────────────────────────────
with open("class_indices (2).json", "r") as f:
    class_indices = json.load(f)
classes = {int(k): v for k, v in class_indices.items()}
num_classes = len(classes)
print(f"✅ {num_classes} classes chargées")

# ── Reconstruire l'architecture EfficientNetB0 ───────────────────
IMG_SHAPE = (224, 224, 3)

base_model = tf.keras.applications.EfficientNetB0(
    input_shape=IMG_SHAPE,
    include_top=False,
    weights="imagenet"
)

inputs  = tf.keras.Input(shape=IMG_SHAPE)
x       = base_model(inputs, training=False)
x       = tf.keras.layers.GlobalAveragePooling2D()(x)
x       = tf.keras.layers.Dropout(0.3)(x)
outputs = tf.keras.layers.Dense(num_classes, activation="softmax", dtype="float32")(x)
model   = tf.keras.Model(inputs, outputs)

# ── Charger les poids ────────────────────────────────────────────
model.load_weights("plant_disease_weights.weights.h5")
print("✅ Poids chargés avec succès")

# ── Conseils par maladie ─────────────────────────────────────────
disease_advice = {
    "Pepper__bell___Bacterial_spot": "Use certified seed, copper + mancozeb rotations, avoid working plants when wet.",
    "Pepper__bell___healthy": "Mulch to reduce soil splash, drip irrigation, rotate with non-hosts.",
    "Potato___Early_blight": "Remove lower leaves touching soil, apply chlorothalonil or mancozeb early.",
    "Potato___Late_blight": "Destroy cull piles, avoid overhead irrigation, apply protectant + systemic fungicides.",
    "Potato___healthy": "Hilled rows, proper spacing, avoid waterlogging.",
    "Tomato_Bacterial_spot": "Use resistant transplants, copper + mancozeb rotation, avoid handling when wet.",
    "Tomato_Early_blight": "Mulch, remove lower leaves, rotate, apply chlorothalonil at first lesions.",
    "Tomato_Late_blight": "Destroy infected plants, strict sanitation, apply protectant fungicides.",
    "Tomato_Leaf_Mold": "Reduce humidity in greenhouses, prune, apply copper-based fungicides.",
    "Tomato_Septoria_leaf_spot": "Remove infected leaves, improve airflow, apply mancozeb sprays.",
    "Tomato_Spider_mites_Two_spotted_spider_mite": "Spray undersides with water, use horticultural oils or miticides.",
    "Tomato__Target_Spot": "Rotate crops, reduce humidity, apply strobilurin/triazole fungicides.",
    "Tomato__Tomato_YellowLeaf__Curl_Virus": "Control whiteflies with yellow sticky traps, remove infected plants.",
    "Tomato__Tomato_mosaic_virus": "Sanitize hands and tools, remove infected plants, use resistant cultivars.",
    "Tomato_healthy": "Consistent watering at soil level, balanced fertilization, stake for airflow.",
}

app = Flask(__name__)
CORS(app)

def preprocess_image(image_bytes):
    img = Image.open(io.BytesIO(image_bytes)).convert("RGB").resize((224, 224))
    img_array = np.array(img, dtype=np.float32)
    img_array = tf.keras.applications.efficientnet.preprocess_input(img_array)
    img_array = np.expand_dims(img_array, axis=0)
    return img_array

@app.route("/predict", methods=["POST"])
def predict():
    if "image" not in request.files:
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files["image"]
    img_bytes = file.read()
    img = preprocess_image(img_bytes)

    prediction   = model.predict(img, verbose=0)
    class_idx    = int(np.argmax(prediction[0]))
    confidence   = float(np.max(prediction[0]))
    disease_name = classes.get(class_idx, "Unknown")

    print(f"→ {disease_name} ({confidence:.2%})")

    advice = disease_advice.get(
        disease_name,
        "Consult an agronomist for proper diagnosis and treatment."
    )

    return jsonify({
        "disease":    disease_name,
        "confidence": confidence,
        "advice":     advice
    })

@app.route("/health", methods=["GET"])
def health():
    return jsonify({"status": "ok"})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=4000, debug=False)