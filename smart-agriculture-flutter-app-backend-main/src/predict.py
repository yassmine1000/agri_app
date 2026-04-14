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

# ── Conseils EN ──────────────────────────────────────────────────
disease_advice_en = {
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
        "Healthy tree detected. Monitor for cherry leaf spot and brown rot as seasons change."
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
        "Healthy plants detected. Monitor for two-spotted spider mite during hot, dry weather."
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

# ── Conseils FR ──────────────────────────────────────────────────
disease_advice_fr = {
    "Apple___Apple_scab": [
        "Appliquer des fongicides (myclobutanil ou captane) dès le débourrement. Ramasser et détruire les feuilles tombées pour réduire les spores hivernantes.",
        "Tailler les arbres pour améliorer la circulation de l'air. Appliquer des fongicides préventifs avant et après les pluies printanières.",
        "Utiliser des variétés de pommes résistantes lors de la replantation. Ratisser les feuilles infectées loin du verger."
    ],
    "Apple___Black_rot": [
        "Retirer immédiatement les fruits momifiés et le bois mort des arbres. Appliquer un fongicide à base de cuivre pendant la saison de croissance.",
        "Tailler les chancres et les branches mortes. Désinfecter les outils de taille entre chaque coupe. Appliquer du captane à la chute des pétales.",
        "Maintenir la vigueur de l'arbre par une nutrition et une irrigation appropriées. Retirer les fruits infectés rapidement avant que les spores ne se propagent."
    ],
    "Apple___Cedar_apple_rust": [
        "Retirer les genévriers/cèdres proches si possible. Appliquer du myclobutanil ou du mancozèbe au stade bouton rose.",
        "Appliquer des fongicides protecteurs du stade bouton rose jusqu'à la chute des pétales. Utiliser des variétés résistantes à la rouille pour les nouvelles plantations.",
        "Surveiller les masses de spores orange sur les cèdres voisins au printemps. Appliquer des fongicides avant les pluies pendant la période d'infection."
    ],
    "Apple___healthy": [
        "Votre pommier est en bonne santé ! Maintenez une taille régulière pour améliorer la circulation de l'air et la pénétration de la lumière.",
        "Très bonne condition ! Appliquez un engrais équilibré au début du printemps et assurez un arrosage régulier pendant les périodes sèches.",
        "Arbre en bonne santé. Continuez à surveiller les premiers signes de maladie et maintenez un verger propre."
    ],
    "Background_without_leaves": [
        "Aucune plante détectée dans l'image. Veuillez prendre une photo claire d'une feuille de plante pour une détection précise.",
        "L'image ne contient pas de feuille reconnaissable. Assurez un bon éclairage et focalisez l'appareil photo directement sur la feuille.",
        "Veuillez reprendre la photo avec une seule feuille remplissant la majeure partie du cadre pour de meilleurs résultats."
    ],
    "Blueberry___healthy": [
        "La myrtille est en bonne santé ! Maintenez le pH du sol entre 4,5 et 5,5 pour une absorption optimale des nutriments.",
        "Excellente condition ! Paillez avec de l'écorce de pin pour maintenir l'acidité et l'humidité. Taillez les vieilles tiges annuellement.",
        "Plante prospère. Assurez une irrigation adéquate pendant le développement des fruits et fertilisez avec des engrais acidifiants."
    ],
    "Cherry___Powdery_mildew": [
        "Appliquer un fongicide à base de soufre ou du bicarbonate de potassium au premier signe de revêtement blanc poudreux sur les feuilles.",
        "Améliorer la circulation de l'air par la taille. Éviter l'irrigation par aspersion. Appliquer de l'huile de neem le matin.",
        "Retirer et détruire les pousses fortement infectées. Appliquer du myclobutanil et éviter une fertilisation azotée excessive."
    ],
    "Cherry___healthy": [
        "Le cerisier est en excellente santé ! Taillez après la récolte pour maintenir la forme et retirer les branches croisées.",
        "Très bon état ! Appliquez un engrais équilibré au printemps et assurez un arrosage profond et peu fréquent pendant les périodes sèches.",
        "Arbre sain détecté. Surveillez la tache foliaire et la pourriture brune au changement de saison."
    ],
    "Corn___Cercospora_leaf_spot Gray_leaf_spot": [
        "Appliquer un fongicide strobilurine ou triazole au début de la floraison. Alterner les cultures — éviter de planter du maïs après du maïs.",
        "Utiliser des hybrides résistants. Le labour pour enfouir les résidus infectés réduit considérablement l'inoculum hivernal.",
        "Appliquer un fongicide (azoxystrobine ou propiconazole) dès l'apparition des lésions. Maintenir un espacement adéquat entre les plantes."
    ],
    "Corn___Common_rust": [
        "Appliquer un fongicide foliaire (propiconazole ou azoxystrobine) dès l'apparition des pustules de rouille sur les feuilles inférieures.",
        "Planter des hybrides de maïs résistants à la rouille. Inspecter régulièrement les champs et appliquer un fongicide avant la propagation.",
        "L'application de fongicide est la plus efficace avant la floraison. Utiliser du mancozèbe ou des produits triazolés dès les premiers signes."
    ],
    "Corn___Northern_Leaf_Blight": [
        "Appliquer un fongicide (azoxystrobine, propiconazole) à la floraison si le mildiou apparaît sur les feuilles inférieures.",
        "Alterner les cultures et labourer les débris infectés. Utiliser des hybrides résistants au mildiou nordique.",
        "Inspecter les champs à partir du stade V8. Appliquer un fongicide si le mildiou atteint la troisième feuille avant la floraison."
    ],
    "Corn___healthy": [
        "Le maïs est en bonne santé ! Assurez une fertilisation azotée adéquate au stade V6 pour un développement optimal de l'épi.",
        "Excellente santé végétale ! Surveiller les dommages causés par les ravageurs et maintenir une humidité du sol constante pendant la pollinisation.",
        "Culture saine détectée. Continuer à surveiller les premiers signes de maladie et maintenir la densité de plantation recommandée."
    ],
    "Grape___Black_rot": [
        "Appliquer du mancozèbe ou du myclobutanil dès le débourrement. Retirer les baies momifiées et les sarments infectés.",
        "Tailler abondamment pour améliorer la circulation de l'air. Appliquer un fongicide protecteur tous les 7-10 jours par temps pluvieux.",
        "Retirer tous les matériaux végétaux infectés du vignoble. Appliquer un fongicide triazole à la nouaison et au stade fermeture de la grappe."
    ],
    "Grape___Esca_(Black_Measles)": [
        "Aucun traitement curatif disponible. Retirer et détruire le bois infecté. Peindre les plaies de taille avec une pâte fongicide.",
        "Retarder la taille jusqu'à la fin de l'hiver pour réduire le risque d'infection. Appliquer du Trichoderma sur les plaies de taille.",
        "Améliorer la nutrition de la vigne et réduire le stress hydrique. Retirer les vignes sévèrement infectées pour éviter la propagation."
    ],
    "Grape___Leaf_blight_(Isariopsis_Leaf_Spot)": [
        "Appliquer un fongicide à base de cuivre ou du mancozèbe aux premiers signes de lésions brunes angulaires sur les feuilles.",
        "Améliorer la gestion de la canopée par l'effeuillage et le positionnement des rameaux pour augmenter la circulation de l'air.",
        "Appliquer des fongicides après les pluies. Retirer les feuilles fortement infectées pour ralentir la progression de la maladie."
    ],
    "Grape___healthy": [
        "La vigne est en excellent état ! Maintenir une nutrition équilibrée en potassium et magnésium pour une qualité optimale des baies.",
        "Vigne saine détectée. Continuer la gestion de la canopée et surveiller l'oïdium et le mildiou pendant les périodes humides.",
        "Très bon état ! Assurer un éclaircissage des rameaux et un effeuillage autour de la zone fructifère pour prévenir les maladies."
    ],
    "Orange___Haunglongbing_(Citrus_greening)": [
        "Aucun remède n'existe. Retirer et détruire immédiatement les arbres infectés pour éviter la propagation aux agrumes sains.",
        "Contrôler le psylle des agrumes (vecteur de la maladie) avec des insecticides systémiques. Inspecter les nouvelles plantations issues de pépinières certifiées.",
        "Utiliser des pièges à psylles dans tout le verger. Appliquer des insecticides pour contrôler les populations de psylles. Signaler aux autorités locales."
    ],
    "Peach___Bacterial_spot": [
        "Appliquer de l'hydroxyde de cuivre ou de l'oxytétracycline pendant la floraison. Éviter l'irrigation par aspersion pour réduire le mouillage des feuilles.",
        "Planter des variétés de pêchers résistants. Appliquer un bactéricide cuivré à la chute des calices et continuer tous les 7-14 jours.",
        "Tailler pour améliorer la circulation de l'air. Appliquer des pulvérisations de cuivre fixe avant les pluies pendant la saison de croissance."
    ],
    "Peach___healthy": [
        "Le pêcher est en bonne santé ! Éclaircissez les fruits à 15-20 cm d'intervalle pour obtenir des pêches plus grosses et de meilleure qualité.",
        "Excellent état ! Appliquez un engrais équilibré au début du printemps. Surveillez la cloque du pêcher à l'émergence des feuilles.",
        "Arbre sain détecté. Maintenez le désherbage sous la canopée et assurez un arrosage adéquat pendant le développement des fruits."
    ],
    "Pepper,_bell___Bacterial_spot": [
        "Appliquer un mélange cuivre + mancozèbe aux premiers signes de lésions gorgées d'eau. Éviter de travailler dans les champs mouillés.",
        "Utiliser des plants certifiés indemnes de maladies. Appliquer un bactéricide cuivré tous les 5-7 jours par temps chaud et humide.",
        "Retirer et détruire les plants fortement infectés. Alterner avec des cultures non solanacées pendant au moins 2 ans."
    ],
    "Pepper,_bell___healthy": [
        "Le poivron est en excellent état ! Maintenez une humidité du sol constante et fertilisez avec du calcium pour prévenir la pourriture apicale.",
        "Plante saine ! Tuteurez les plants pour améliorer la circulation de l'air. Appliquez un engrais équilibré à la nouaison.",
        "Excellente condition. Surveillez les pucerons et les thrips qui peuvent transmettre des maladies virales aux plantes saines."
    ],
    "Potato___Early_blight": [
        "Appliquer du chlorothalonil ou du mancozèbe dès l'apparition des premières lésions. Retirer les feuilles inférieures touchant le sol.",
        "Maintenir des niveaux adéquats de potassium — la carence augmente la sensibilité. Appliquer un fongicide tous les 7 jours par temps humide.",
        "Alterner les cultures pendant 3 ans minimum. Appliquer des fongicides préventifs dès la fermeture des rangs."
    ],
    "Potato___Late_blight": [
        "Appliquer immédiatement un fongicide systémique (métalaxyl + mancozèbe). Détruire les matériaux végétaux infectés — NE PAS composter.",
        "Éviter l'irrigation par aspersion. Appliquer un fongicide protecteur avant la pluie et un systémique après confirmation de l'infection.",
        "Retirer et détruire les plants entiers infectés y compris les tubercules. Appliquer un fongicide tous les 5-7 jours par temps frais et humide."
    ],
    "Potato___healthy": [
        "La plante de pomme de terre est en bonne santé ! Buttez le sol autour des tiges pour éviter le verdissement des tubercules et améliorer le rendement.",
        "Très bon état ! Assurez une humidité constante — un arrosage irrégulier provoque la gale commune et les désordres du cœur creux.",
        "Culture saine ! Surveillez régulièrement le doryphore et les pucerons. Appliquez un défanant 2 semaines avant la récolte."
    ],
    "Raspberry___healthy": [
        "Les cannes de framboisier sont en bonne santé ! Retirez les cannes fruitières usées après la récolte pour encourager la croissance des nouvelles.",
        "Excellent état ! Appliquez un engrais équilibré au début du printemps et paillez abondamment pour supprimer les mauvaises herbes.",
        "Plante saine détectée. Palissez correctement les cannes pour la circulation de l'air. Surveillez les dégâts du foreur des cannes."
    ],
    "Soybean___healthy": [
        "La culture de soja est en excellent état ! Assurez un apport adéquat en phosphore et potassium pour un remplissage optimal des gousses.",
        "Culture saine détectée. Surveiller le syndrome de mort subite et la pourriture blanche aux stades R3-R5.",
        "Très bon état ! Surveiller le puceron du soja et le coléoptère des haricots. Maintenir la densité de plantation pour la fermeture de la canopée."
    ],
    "Squash___Powdery_mildew": [
        "Appliquer du bicarbonate de potassium ou un fongicide soufré aux premiers signes de taches blanches poudreuses sur les feuilles.",
        "Appliquer de l'huile de neem ou de l'huile horticole tôt le matin. Retirer rapidement les feuilles fortement infectées.",
        "Améliorer la circulation de l'air par un espacement adéquat. Appliquer du myclobutanil ou de la trifloxystrobine de manière préventive."
    ],
    "Strawberry___Leaf_scorch": [
        "Appliquer du captane ou du myclobutanil aux premiers signes de taches violettes. Retirer et détruire les feuilles infectées.",
        "Éviter l'irrigation par aspersion. Appliquer un fongicide à base de cuivre pendant la période de rénovation après la récolte.",
        "Rénover les plantations de fraisiers après la récolte — tondre le feuillage, réduire les rangs, appliquer un fongicide pour encourager une repousse saine."
    ],
    "Strawberry___healthy": [
        "Les plants de fraisiers sont en excellent état ! Appliquez un engrais équilibré après la rénovation et maintenez une humidité constante.",
        "Très bon état ! Paillez avec de la paille pour garder les fruits propres et réduire les éclaboussures de terre qui propagent les maladies.",
        "Plants sains détectés. Surveillez l'acarien tétranyque par temps chaud et sec. Retirez les stolons pour concentrer l'énergie sur les fruits."
    ],
    "Tomato___Bacterial_spot": [
        "Appliquer un spray bactéricide cuivre + mancozèbe toutes les 5-7 jours. Éviter de travailler dans les champs quand les plants sont mouillés.",
        "Utiliser des transplants sains et des variétés résistantes. Retirer les feuilles infectées et appliquer de l'hydroxyde de cuivre de manière préventive.",
        "Alterner les tomates avec des cultures non solanacées. Appliquer un bactéricide après les opérations de taille et les événements orageux."
    ],
    "Tomato___Early_blight": [
        "Pailler abondamment pour éviter les éclaboussures de sol. Appliquer du chlorothalonil ou du mancozèbe dès les premières lésions. Retirer les feuilles basses infectées.",
        "Appliquer un fongicide tous les 7-10 jours par temps chaud et humide. Tuteurer les plants pour améliorer la circulation d'air autour du feuillage.",
        "Alterner les cultures pendant 2-3 ans. Maintenir une fertilisation adéquate en potassium pour renforcer la résistance des plants."
    ],
    "Tomato___Late_blight": [
        "Appliquer immédiatement du métalaxyl + mancozèbe. Retirer et emballer tous les matériaux végétaux infectés — ne pas composter.",
        "Appliquer un fongicide protecteur avant les pluies. Éviter l'irrigation par aspersion et travailler dans les champs uniquement quand ils sont secs.",
        "Détruire les plants infectés pour éviter la propagation. Appliquer un fongicide à base de cuivre comme mesure préventive sur les plants voisins."
    ],
    "Tomato___Leaf_Mold": [
        "Réduire l'humidité en serre en dessous de 85%. Appliquer un fongicide cuivré ou du chlorothalonil dès les premiers symptômes.",
        "Améliorer la ventilation en serre. Retirer rapidement les feuilles infectées. Appliquer du mancozèbe ou du thirame de manière préventive.",
        "Espacer adéquatement les plants pour la circulation de l'air. Éviter le mouillage des feuilles grâce à l'irrigation goutte à goutte."
    ],
    "Tomato___Septoria_leaf_spot": [
        "Appliquer du chlorothalonil ou du mancozèbe aux premiers symptômes. Retirer les feuilles basses infectées pour ralentir la progression de la maladie.",
        "Pailler pour éviter les éclaboussures de sol. Appliquer un fongicide cuivré tous les 7-10 jours par temps humide.",
        "Tuteurer les plants et retirer les gourmands pour améliorer la circulation de l'air. Alterner les cultures et éviter l'irrigation par aspersion."
    ],
    "Tomato___Spider_mites Two-spotted_spider_mite": [
        "Pulvériser le dessous des feuilles avec force d'eau pour déloger les acariens. Appliquer de l'huile horticole ou du savon insecticide.",
        "Utiliser un acaricide (abamectine ou bifénazate) et alterner les modes d'action. Retirer les feuilles fortement infestées.",
        "Maintenir une humidité du sol adéquate — les plants stressés par la sécheresse sont plus vulnérables. Introduire des acariens prédateurs comme lutte biologique."
    ],
    "Tomato___Target_Spot": [
        "Appliquer un fongicide strobilurine ou triazole (azoxystrobine, difénoconazole) dès l'apparition des premières lésions.",
        "Améliorer la circulation de l'air par le tuteurage, la taille et un espacement adéquat. Appliquer du mancozèbe comme spray protecteur.",
        "Retirer les feuilles infectées. Appliquer un fongicide tous les 7-14 jours par temps humide. Alterner les cultures avec des espèces non solanacées."
    ],
    "Tomato___Tomato_Yellow_Leaf_Curl_Virus": [
        "Contrôler les populations d'aleurodes avec des insecticides systémiques (imidaclopride). Utiliser des pièges jaunes collants pour la surveillance.",
        "Retirer et détruire immédiatement les plants infectés. Utiliser un paillis réfléchissant pour repousser les aleurodes des jeunes transplants.",
        "Planter des variétés résistantes (TYLCV-résistantes). Appliquer des insecticides à la plantation et utiliser des filets insect-proof en pépinière."
    ],
    "Tomato___Tomato_mosaic_virus": [
        "Désinfecter les mains et les outils avec du savon ou une solution de javel à 10% avant de manipuler les plants. Retirer les plants infectés.",
        "Contrôler les populations de pucerons et de thrips qui transmettent le virus. Utiliser des variétés de tomates résistantes si disponibles.",
        "Éviter les produits du tabac près des plants de tomates — le TMV peut être transmis mécaniquement. Retirer et détruire tous les matériaux infectés."
    ],
    "Tomato___healthy": [
        "Le plant de tomate est en excellent état ! Maintenez un arrosage régulier au niveau du sol pour prévenir la pourriture apicale.",
        "Très bon état ! Taillez régulièrement les gourmands pour les variétés indéterminées. Appliquez un engrais équilibré toutes les 2-3 semaines.",
        "Plant sain détecté. Surveillez les premiers signes de mildiou et assurez la disponibilité du calcium pour prévenir les désordres des fruits."
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
    print("URL ARGS:", dict(request.args))
    print("FULL URL:", request.url)
    if "image" not in request.files:
        return jsonify({"error": "No file uploaded"}), 400

    file = request.files["image"]
    print("FORM FIELDS:", dict(request.form))
    img_bytes = file.read()
    img = preprocess_image(img_bytes)

    prediction   = model.predict(img, verbose=0)
    class_idx    = int(np.argmax(prediction[0]))
    confidence   = float(np.max(prediction[0]))
    disease_name = classes.get(class_idx, "Unknown")

    # Détecter la langue depuis le header
    lang = request.args.get('lang', request.form.get('lang', 'EN')).upper()
    print(f"→ {disease_name} ({confidence:.2%}) — Lang: {lang}")

    # Choisir le bon dictionnaire
    if lang == 'FR':
        advice_dict = disease_advice_fr
    else:
        advice_dict = disease_advice_en

    advice_list = advice_dict.get(disease_name, [
        "Consultez un agronome pour un diagnostic et un traitement appropriés." if lang == 'FR' else
        "Please consult a local agronomist for proper diagnosis and treatment advice."
    ])
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
