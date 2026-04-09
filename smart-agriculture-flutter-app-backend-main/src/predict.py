from flask import Flask, request, jsonify
from flask_cors import CORS
import tensorflow as tf
import numpy as np
from PIL import Image
import io, json, random

# ── Charger les classes ──────────────────────────────────────────
with open("class_indices.json", "r") as f:
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

model.load_weights("best_weights.weights.h5")
print("✅ Poids chargés avec succès")

# ── Conseils détaillés pour toutes les 39 classes ────────────────
disease_advice = {
    "Apple___Apple_scab": [
        "Apply fungicides (myclobutanil or captan) at early leaf development. Remove and destroy fallen leaves to reduce overwintering spores.",
        "Prune trees to improve air circulation. Apply protective fungicide sprays before and after rain events during spring.",
        "Use resistant apple varieties when replanting. Rake and compost infected leaves away from the orchard."
    ],
    "Apple___Black_rot": [
        "Remove mummified fruits and dead wood from trees immediately. Apply copper-based fungicide during the growing season.",
        "Prune out cankers and dead branches. Disinfect pruning tools between cuts. Apply captan fungicide at petal fall.",
        "Maintain tree vigor through proper nutrition and irrigation. Remove infected fruit promptly before spores spread."
    ],
    "Apple___Cedar_apple_rust": [
        "Remove nearby juniper/cedar trees if possible. Apply myclobutanil or mancozeb fungicide at pink bud stage.",
        "Apply protective fungicide sprays from pink bud through petal fall. Use rust-resistant apple varieties for new plantings.",
        "Monitor for orange spore masses on nearby cedar trees in spring. Apply fungicide before rain events during infection period."
    ],
    "Apple___healthy": [
        "Your apple tree looks healthy! Maintain regular pruning to improve air circulation and light penetration.",
        "Great condition! Apply balanced fertilizer in early spring and ensure consistent watering during dry periods.",
        "Tree is healthy. Continue monitoring for early signs of disease and maintain a clean orchard floor."
    ],
    "Background_without_leaves": [
        "No plant detected in the image. Please take a clear photo of a plant leaf for accurate disease detection.",
        "Image does not contain a recognizable leaf. Ensure good lighting and focus the camera directly on the leaf.",
        "Please retake the photo with a single leaf filling most of the frame for better analysis results."
    ],
    "Blueberry___healthy": [
        "Blueberry plant looks healthy! Maintain soil pH between 4.5-5.5 for optimal nutrient uptake.",
        "Excellent condition! Mulch with pine bark to maintain acidity and moisture. Prune old canes annually.",
        "Plant is thriving. Ensure adequate irrigation during fruit development and fertilize with acid-forming fertilizers."
    ],
    "Cherry___Powdery_mildew": [
        "Apply sulfur-based fungicide or potassium bicarbonate at first sign of white powdery coating on leaves.",
        "Improve air circulation by pruning. Avoid overhead irrigation. Apply neem oil spray in early morning.",
        "Remove and destroy heavily infected shoots. Apply myclobutanil fungicide and avoid excessive nitrogen fertilization."
    ],
    "Cherry___healthy": [
        "Cherry tree is in great health! Prune after harvest to maintain shape and remove crossing branches.",
        "Looking good! Apply balanced fertilizer in spring and ensure deep, infrequent watering during dry spells.",
        "Healthy tree detected. Monitor for cherry leaf spot and brown rot as seasons change. Maintain good sanitation."
    ],
    "Corn___Cercospora_leaf_spot Gray_leaf_spot": [
        "Apply strobilurin or triazole fungicide at early tassel stage. Rotate crops — avoid planting corn after corn.",
        "Use resistant hybrid varieties. Tillage to bury infected residue reduces overwintering inoculum significantly.",
        "Apply fungicide (azoxystrobin or propiconazole) when lesions first appear. Maintain proper plant spacing for airflow."
    ],
    "Corn___Common_rust": [
        "Apply foliar fungicide (propiconazole or azoxystrobin) when rust pustules first appear on lower leaves.",
        "Plant rust-resistant corn hybrids. Scout fields regularly and apply fungicide before disease spreads to upper canopy.",
        "Fungicide application is most effective before tasseling. Use mancozeb or triazole-based products at first sign."
    ],
    "Corn___Northern_Leaf_Blight": [
        "Apply fungicide (azoxystrobin, propiconazole) at early tasseling if blight appears on lower leaves.",
        "Rotate crops and till infected debris. Use resistant hybrids rated for Northern Leaf Blight tolerance.",
        "Scout fields from V8 stage onward. Apply fungicide if blight reaches third leaf from ear before silking."
    ],
    "Corn___healthy": [
        "Corn looks healthy! Ensure adequate nitrogen fertilization at V6 stage for optimal ear development.",
        "Great plant health! Monitor for pest damage and maintain consistent soil moisture during pollination.",
        "Healthy crop detected. Continue scouting for early disease signs and maintain recommended plant population."
    ],
    "Grape___Black_rot": [
        "Apply mancozeb or myclobutanil fungicide starting at bud break. Remove mummified berries and infected canes.",
        "Prune heavily to improve air circulation. Apply protective fungicide every 7-10 days during wet spring weather.",
        "Remove all infected plant material from the vineyard. Apply triazole fungicide at fruit set and berry touch stages."
    ],
    "Grape___Esca_(Black_Measles)": [
        "No curative treatment available. Remove and destroy infected wood. Paint pruning wounds with fungicidal paste.",
        "Delay pruning until late winter to reduce infection risk. Apply Trichoderma-based biological control to pruning wounds.",
        "Improve vine nutrition and reduce water stress. Remove severely infected vines to prevent spread to healthy plants."
    ],
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)": [
        "Apply copper-based fungicide or mancozeb at first sign of angular brown lesions on leaves.",
        "Improve canopy management through leaf removal and shoot positioning to increase air circulation in the vine.",
        "Apply fungicide sprays after rain events. Remove heavily infected leaves to slow disease progression."
    ],
    "Grape___healthy": [
        "Grapevine looks excellent! Maintain balanced nutrition with potassium and magnesium for optimal berry quality.",
        "Healthy vine detected. Continue canopy management and monitor for powdery and downy mildew during humid periods.",
        "Great condition! Ensure proper shoot thinning and leaf removal around the fruit zone for disease prevention."
    ],
    "Orange___Haunglongbing_(Citrus_greening)": [
        "No cure exists. Remove and destroy infected trees immediately to prevent spread to healthy citrus.",
        "Control Asian citrus psyllid (disease vector) with systemic insecticides. Inspect new plantings from certified nurseries only.",
        "Use psyllid monitoring traps throughout the orchard. Apply insecticide to control psyllid populations. Report to local authorities."
    ],
    "Peach___Bacterial_spot": [
        "Apply copper hydroxide or oxytetracycline during bloom. Avoid overhead irrigation to reduce leaf wetness periods.",
        "Plant resistant peach varieties. Apply copper bactericide at shuck split and continue on 7-14 day intervals.",
        "Prune to improve air circulation. Apply fixed copper sprays before rain events during the growing season."
    ],
    "Peach___healthy": [
        "Peach tree is healthy! Thin fruit to 6-8 inches apart for larger, higher quality peaches.",
        "Great health! Apply balanced fertilizer in early spring. Monitor for peach leaf curl as leaves emerge.",
        "Healthy tree detected. Maintain weed control under the canopy and ensure adequate water during fruit development."
    ],
    "Pepper,_bell___Bacterial_spot": [
        "Apply copper + mancozeb tank mix at first sign of water-soaked lesions. Avoid working in wet fields.",
        "Use certified disease-free transplants. Apply copper bactericide every 5-7 days during warm, wet weather.",
        "Remove and destroy heavily infected plants. Rotate with non-solanaceous crops for at least 2 years."
    ],
    "Pepper,_bell___healthy": [
        "Bell pepper looks great! Maintain consistent soil moisture and fertilize with calcium to prevent blossom end rot.",
        "Healthy plant! Stake plants to improve air circulation. Side-dress with balanced fertilizer at first fruit set.",
        "Excellent condition. Monitor for aphids and thrips which can transmit viral diseases to healthy plants."
    ],
    "Potato___Early_blight": [
        "Apply chlorothalonil or mancozeb fungicide at first lesion appearance. Remove lower leaves touching the soil.",
        "Maintain adequate potassium levels — deficiency increases susceptibility. Apply fungicide on 7-day intervals during wet weather.",
        "Rotate crops for 3 years minimum. Apply preventive fungicide sprays starting at row closure stage."
    ],
    "Potato___Late_blight": [
        "Apply systemic fungicide (metalaxyl + mancozeb) immediately. Destroy infected plant material — do NOT compost.",
        "Avoid overhead irrigation. Apply protectant fungicide (chlorothalonil) before rain and systemic after infection is confirmed.",
        "Remove and destroy entire infected plants including tubers. Apply fungicide on 5-7 day intervals during cool, wet weather."
    ],
    "Potato___healthy": [
        "Potato plant looks healthy! Hill soil around stems to prevent tuber greening and improve yield.",
        "Great condition! Ensure consistent moisture — irregular watering causes common scab and hollow heart disorders.",
        "Healthy crop! Scout regularly for Colorado potato beetle and aphids. Apply haulm desiccant 2 weeks before harvest."
    ],
    "Raspberry___healthy": [
        "Raspberry canes are healthy! Remove spent fruiting canes after harvest to encourage new primocane growth.",
        "Great health! Apply balanced fertilizer in early spring and mulch heavily to suppress weeds and retain moisture.",
        "Healthy plant detected. Trellis canes properly for air circulation. Scout for raspberry cane borer damage."
    ],
    "Soybean___healthy": [
        "Soybean crop looks excellent! Ensure adequate phosphorus and potassium for optimal pod fill.",
        "Healthy crop detected. Monitor for sudden death syndrome and white mold during R3-R5 growth stages.",
        "Great condition! Scout for soybean aphid and bean leaf beetle. Maintain proper plant population for canopy closure."
    ],
    "Squash___Powdery_mildew": [
        "Apply potassium bicarbonate or sulfur fungicide at first sign of white powdery patches on leaves.",
        "Apply neem oil or horticultural oil spray in early morning. Remove severely infected leaves promptly.",
        "Improve air circulation through proper plant spacing. Apply myclobutanil or trifloxystrobin fungicide preventively."
    ],
    "Strawberry___Leaf_scorch": [
        "Apply captan or myclobutanil fungicide at first sign of purple spots. Remove and destroy infected leaves.",
        "Avoid overhead irrigation. Apply copper-based fungicide during the renovation period after harvest.",
        "Renovate strawberry beds after harvest — mow foliage, narrow rows, apply fungicide to encourage healthy regrowth."
    ],
    "Strawberry___healthy": [
        "Strawberry plants are in excellent health! Apply balanced fertilizer after renovation and maintain consistent moisture.",
        "Great condition! Mulch with straw to keep fruit clean and reduce soil splash that spreads disease.",
        "Healthy plants detected. Monitor for two-spotted spider mite during hot, dry weather. Remove runners to focus energy on fruit."
    ],
    "Tomato___Bacterial_spot": [
        "Apply copper + mancozeb bactericide spray every 5-7 days. Avoid working in the field when plants are wet.",
        "Use disease-free transplants and resistant varieties. Remove infected leaves and apply copper hydroxide preventively.",
        "Rotate tomatoes with non-solanaceous crops. Apply bactericide after pruning operations and storm events."
    ],
    "Tomato___Early_blight": [
        "Mulch heavily to prevent soil splash. Apply chlorothalonil or mancozeb at first lesion. Remove lowest infected leaves.",
        "Apply fungicide every 7-10 days during warm, humid conditions. Stake plants to improve airflow around foliage.",
        "Rotate crops for 2-3 years. Maintain adequate potassium fertilization to strengthen plant resistance."
    ],
    "Tomato___Late_blight": [
        "Apply metalaxyl + mancozeb immediately. Remove and bag all infected plant material — do not compost.",
        "Apply protectant fungicide before rain events. Avoid overhead irrigation and work in fields only when dry.",
        "Destroy infected plants to prevent spread. Apply copper-based fungicide as protective measure in neighboring plants."
    ],
    "Tomato___Leaf_Mold": [
        "Reduce greenhouse humidity below 85%. Apply copper fungicide or chlorothalonil when first symptoms appear.",
        "Improve ventilation in greenhouses. Remove infected leaves promptly. Apply mancozeb or thiram fungicide preventively.",
        "Space plants adequately for airflow. Avoid leaf wetness through drip irrigation instead of overhead sprinklers."
    ],
    "Tomato___Septoria_leaf_spot": [
        "Apply chlorothalonil or mancozeb at first spotting. Remove infected lower leaves to slow upward disease spread.",
        "Mulch to prevent soil splash. Apply copper fungicide every 7-10 days during wet weather conditions.",
        "Stake plants and remove suckers to improve air circulation. Rotate crops and avoid overhead irrigation."
    ],
    "Tomato___Spider_mites Two-spotted_spider_mite": [
        "Spray undersides of leaves forcefully with water to dislodge mites. Apply horticultural oil or insecticidal soap.",
        "Use miticide (abamectin or bifenazate) and alternate modes of action. Remove heavily infested leaves.",
        "Maintain adequate soil moisture — water-stressed plants are more susceptible. Introduce predatory mites as biological control."
    ],
    "Tomato___Target_Spot": [
        "Apply strobilurin or triazole fungicide (azoxystrobin, difenoconazole) at first lesion appearance.",
        "Improve airflow through staking, pruning and proper plant spacing. Apply mancozeb as protective spray.",
        "Remove infected leaves. Apply fungicide every 7-14 days during humid conditions. Rotate with non-solanaceous crops."
    ],
    "Tomato___Tomato_Yellow_Leaf_Curl_Virus": [
        "Control whitefly populations with systemic insecticides (imidacloprid). Use yellow sticky traps for monitoring.",
        "Remove and destroy infected plants immediately. Use reflective mulch to repel whiteflies from young transplants.",
        "Plant resistant varieties (TYLCV-resistant). Apply insecticide at transplanting and use insect-proof screens in nurseries."
    ],
    "Tomato___Tomato_mosaic_virus": [
        "Sanitize hands and tools with soap or 10% bleach solution before handling plants. Remove infected plants.",
        "Control aphid and thrips populations which transmit the virus. Use resistant tomato varieties when available.",
        "Avoid tobacco products near tomato plants — TMV can be transmitted mechanically. Remove and destroy all infected material."
    ],
    "Tomato___healthy": [
        "Tomato plant is in excellent health! Maintain consistent watering at soil level to prevent blossom end rot.",
        "Great condition! Prune suckers regularly for indeterminate varieties. Apply balanced fertilizer every 2-3 weeks.",
        "Healthy plant detected. Monitor for early signs of blight and ensure calcium availability to prevent fruit disorders."
    ],
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

    print(f"→ disease_name: '{disease_name}'")
    print(f"→ in advice dict: {disease_name in disease_advice}")
    print(f"→ repr: {repr(disease_name)}")

    advice_list = disease_advice.get(disease_name, ["Please consult a local agronomist for proper diagnosis and treatment advice."])
    print(f"DEBUG: '{disease_name}' -> found: {disease_name in disease_advice} -> list length: {len(advice_list)}")
    advice = random.choice(advice_list)

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