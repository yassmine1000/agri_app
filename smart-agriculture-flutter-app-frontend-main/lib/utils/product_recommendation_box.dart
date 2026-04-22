import 'package:flutter/material.dart';
import 'package:smart_agri_app/utils/app_theme.dart';

// ── Mapping maladie → produits recommandés ────────────────────────
// Chaque entrée : { 'name', 'category' (en/fr/ar), 'reason' (en/fr/ar) }
const Map<String, List<Map<String, String>>> _diseaseProducts = {

  // ── Apple ────────────────────────────────────────────────────────
  'Apple___Apple_scab': [
    {'name': 'Azumo',    'cat_en': 'Fungicide', 'cat_fr': 'Fongicide',  'cat_ar': 'مبيد فطري', 'reason_en': 'Triazole fungicide, effective against scab', 'reason_fr': 'Fongicide triazole, efficace contre la tavelure', 'reason_ar': 'مبيد فطري ترايازول فعّال ضد الجرب'},
    {'name': 'Kocide 2000', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Copper hydroxide, protective contact action', 'reason_fr': 'Cuivre hydroxyde, action protectrice de contact', 'reason_ar': 'هيدروكسيد النحاس، حماية وقائية'},
  ],
  'Apple___Black_rot': [
    {'name': 'Kocide 2000', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Copper-based, controls black rot and cankers', 'reason_fr': 'À base de cuivre, contrôle la pourriture noire', 'reason_ar': 'نحاسي يكافح العفن الأسود والقرح'},
    {'name': 'Cuprofix',    'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Contact copper fungicide, protective spray', 'reason_fr': 'Fongicide cuivrique de contact', 'reason_ar': 'مبيد نحاسي للتطبيق الوقائي'},
  ],
  'Apple___Cedar_apple_rust': [
    {'name': 'Azumo',   'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Triazole, effective against rust diseases', 'reason_fr': 'Triazole, efficace contre les rouilles', 'reason_ar': 'ترايازول فعّال ضد أمراض الصدأ'},
    {'name': 'Feuraci', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Specifically formulated against rust and mildew', 'reason_fr': 'Formulé spécifiquement contre rouille et mildiou', 'reason_ar': 'مصمم خصيصاً لمكافحة الصدأ والبياض'},
  ],

  // ── Cherry ───────────────────────────────────────────────────────
  'Cherry___Powdery_mildew': [
    {'name': 'Stin',    'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Controls foliar diseases including powdery mildew', 'reason_fr': 'Contrôle les maladies foliaires dont l\'oïdium', 'reason_ar': 'يكافح أمراض الأوراق بما فيها البياض الدقيقي'},
    {'name': 'Pristine','cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Mixed fungicide, excellent against botrytis and powdery mildew', 'reason_fr': 'Fongicide mixte, excellent contre botrytis et oïdium', 'reason_ar': 'مبيد مزدوج ممتاز ضد البياض الدقيقي'},
  ],

  // ── Corn ─────────────────────────────────────────────────────────
  'Corn___Cercospora_leaf_spot Gray_leaf_spot': [
    {'name': 'Azumo',   'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Broad-spectrum triazole against Cercospora', 'reason_fr': 'Triazole large spectre contre Cercospora', 'reason_ar': 'ترايازول واسع الطيف ضد السيركوسبورا'},
    {'name': 'Cropshield', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Versatile protective fungicide', 'reason_fr': 'Fongicide protecteur polyvalent', 'reason_ar': 'مبيد فطري وقائي متعدد الاستخدامات'},
  ],
  'Corn___Common_rust': [
    {'name': 'Feuraci', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Targeted against rust diseases in cereals', 'reason_fr': 'Ciblé contre les rouilles des céréales', 'reason_ar': 'مستهدف لأمراض الصدأ في الحبوب'},
    {'name': 'Azumo',   'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Triazole, effective foliar application', 'reason_fr': 'Triazole, application foliaire efficace', 'reason_ar': 'ترايازول، تطبيق ورقي فعّال'},
  ],
  'Corn___Northern_Leaf_Blight': [
    {'name': 'Azumo',      'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Triazole against leaf blight pathogens', 'reason_fr': 'Triazole contre les agents de brûlure foliaire', 'reason_ar': 'ترايازول لمكافحة لفحة الأوراق'},
    {'name': 'Cropshield', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Protective fungicide, apply preventively', 'reason_fr': 'Fongicide protecteur, appliquer préventivement', 'reason_ar': 'مبيد وقائي، يُطبق بشكل وقائي'},
  ],

  // ── Grape ────────────────────────────────────────────────────────
  'Grape___Black_rot': [
    {'name': 'Kocide 2000', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Copper hydroxide, bud break application', 'reason_fr': 'Cuivre hydroxyde, application au débourrement', 'reason_ar': 'هيدروكسيد النحاس، يُطبق عند انفتاح البراعم'},
    {'name': 'Azumo',       'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Systemic triazole for black rot control', 'reason_fr': 'Triazole systémique contre la pourriture noire', 'reason_ar': 'ترايازول جهازي لمكافحة العفن الأسود'},
  ],
  'Grape___Leaf_blight_(Isariopsis_Leaf_Spot)': [
    {'name': 'Cuprofix',    'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Copper contact fungicide against leaf blight', 'reason_fr': 'Fongicide cuivrique de contact contre la brûlure foliaire', 'reason_ar': 'نحاسي للتطبيق ضد لفحة الأوراق'},
    {'name': 'Cropshield',  'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Protective polyvalent fungicide', 'reason_fr': 'Fongicide protecteur polyvalent', 'reason_ar': 'مبيد فطري وقائي متعدد'},
  ],
  'Grape___Esca_(Black_Measles)': [
    {'name': 'Kocide 2000', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Apply to pruning wounds to limit infection spread', 'reason_fr': 'Appliquer sur les plaies de taille pour limiter l\'infection', 'reason_ar': 'يُطبق على جروح التقليم للحد من الإصابة'},
  ],

  // ── Orange ───────────────────────────────────────────────────────
  'Orange___Haunglongbing_(Citrus_greening)': [
    {'name': 'Decis Expert (Bayer)', 'cat_en': 'Insecticide', 'cat_fr': 'Insecticide', 'cat_ar': 'مبيد حشري', 'reason_en': 'Controls Asian citrus psyllid (disease vector)', 'reason_fr': 'Contrôle le psylle des agrumes (vecteur)', 'reason_ar': 'يكافح حشرة الجسيد الآسيوي (ناقل المرض)'},
    {'name': 'Calypso',              'cat_en': 'Insecticide', 'cat_fr': 'Insecticide', 'cat_ar': 'مبيد حشري', 'reason_en': 'Systemic insecticide against psyllid populations', 'reason_fr': 'Insecticide systémique contre les populations de psylles', 'reason_ar': 'مبيد جهازي لمكافحة الجسيد'},
  ],

  // ── Peach ────────────────────────────────────────────────────────
  'Peach___Bacterial_spot': [
    {'name': 'Kocide 2000', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Copper hydroxide bactericide against bacterial spot', 'reason_fr': 'Bactéricide cuivrique contre les taches bactériennes', 'reason_ar': 'مبيد نحاسي للتبقع البكتيري'},
    {'name': 'Cuprofix',    'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Contact copper, apply before rain events', 'reason_fr': 'Cuivre de contact, appliquer avant les pluies', 'reason_ar': 'نحاسي للتطبيق قبل هطول الأمطار'},
  ],

  // ── Pepper ───────────────────────────────────────────────────────
  'Pepper,_bell___Bacterial_spot': [
    {'name': 'Kocide 2000', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Copper-based bactericide, spray every 5-7 days', 'reason_fr': 'Bactéricide cuivrique, pulvériser tous les 5-7 jours', 'reason_ar': 'مبيد نحاسي، يُرش كل 5-7 أيام'},
    {'name': 'Cuprofix',    'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Protective copper contact against bacterial diseases', 'reason_fr': 'Cuivre de contact contre les maladies bactériennes', 'reason_ar': 'نحاسي وقائي ضد الأمراض البكتيرية'},
  ],

  // ── Potato ───────────────────────────────────────────────────────
  'Potato___Early_blight': [
    {'name': 'Azumo',      'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Triazole against Alternaria early blight', 'reason_fr': 'Triazole contre Alternaria (mildiou précoce)', 'reason_ar': 'ترايازول ضد الألتيرناريا واللفحة المبكرة'},
    {'name': 'Cropshield', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Protective polyvalent fungicide', 'reason_fr': 'Fongicide protecteur polyvalent', 'reason_ar': 'مبيد فطري وقائي'},
  ],
  'Potato___Late_blight': [
    {'name': 'Infinito (Bayer)',     'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Specifically formulated against potato late blight', 'reason_fr': 'Formulé spécifiquement contre le mildiou de la pomme de terre', 'reason_ar': 'مصمم خصيصاً للفحة المتأخرة في البطاطا'},
    {'name': 'Aliette WG (Bayer)',   'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Systemic against Phytophthora (late blight)', 'reason_fr': 'Systémique contre Phytophthora (mildiou tardif)', 'reason_ar': 'جهازي ضد الفيتوفثورا (اللفحة المتأخرة)'},
    {'name': 'Orondis Ultra (Syngenta)', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Advanced mildew control, highly effective', 'reason_fr': 'Contrôle avancé du mildiou, très efficace', 'reason_ar': 'مكافحة متقدمة للفحة، فعّالية عالية'},
  ],

  // ── Squash ───────────────────────────────────────────────────────
  'Squash___Powdery_mildew': [
    {'name': 'Stin',    'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Effective against powdery mildew on cucurbits', 'reason_fr': 'Efficace contre l\'oïdium des cucurbitacées', 'reason_ar': 'فعّال ضد البياض الدقيقي في القرعيات'},
    {'name': 'Volare',  'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Against powdery mildew and downy mildew', 'reason_fr': 'Contre oïdium et mildiou', 'reason_ar': 'ضد البياض الدقيقي والزغبي'},
    {'name': 'Pristine','cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Excellent preventive and curative action on powdery mildew', 'reason_fr': 'Excellent contre oïdium, action préventive et curative', 'reason_ar': 'ممتاز ضد البياض الدقيقي وقائياً وعلاجياً'},
  ],

  // ── Strawberry ───────────────────────────────────────────────────
  'Strawberry___Leaf_scorch': [
    {'name': 'Cuprofix',    'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Copper contact fungicide against leaf scorch', 'reason_fr': 'Fongicide cuivrique de contact contre la brûlure', 'reason_ar': 'نحاسي للتطبيق ضد احتراق الأوراق'},
    {'name': 'Cropshield',  'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Protective application during renovation period', 'reason_fr': 'Application protectrice pendant la période de rénovation', 'reason_ar': 'تطبيق وقائي خلال فترة التجديد'},
  ],

  // ── Tomato ───────────────────────────────────────────────────────
  'Tomato___Bacterial_spot': [
    {'name': 'Kocide 2000', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Copper hydroxide bactericide, spray every 5-7 days', 'reason_fr': 'Bactéricide cuivrique, pulvériser tous les 5-7 jours', 'reason_ar': 'هيدروكسيد النحاس، يُرش كل 5-7 أيام'},
    {'name': 'Cuprofix',    'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Contact copper spray against bacterial spot', 'reason_fr': 'Pulvérisation cuivrique contre les taches bactériennes', 'reason_ar': 'رش نحاسي ضد التبقع البكتيري'},
  ],
  'Tomato___Early_blight': [
    {'name': 'Azumo',      'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Triazole against Alternaria (early blight)', 'reason_fr': 'Triazole contre Alternaria (mildiou précoce)', 'reason_ar': 'ترايازول ضد اللفحة المبكرة'},
    {'name': 'Cropshield', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Preventive protective application', 'reason_fr': 'Application protectrice préventive', 'reason_ar': 'تطبيق وقائي مانع'},
  ],
  'Tomato___Late_blight': [
    {'name': 'Aliette WG (Bayer)',       'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Systemic against Phytophthora late blight', 'reason_fr': 'Systémique contre Phytophthora (mildiou tardif)', 'reason_ar': 'جهازي ضد اللفحة المتأخرة'},
    {'name': 'Orondis Ultra (Syngenta)', 'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Advanced mildew control, highly effective on tomato', 'reason_fr': 'Contrôle avancé mildiou, très efficace sur tomate', 'reason_ar': 'مكافحة متقدمة للفحة، فعّالية عالية على الطماطم'},
    {'name': 'Infinito (Bayer)',         'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Highly effective against late blight', 'reason_fr': 'Très efficace contre le mildiou tardif', 'reason_ar': 'فعّال جداً ضد اللفحة المتأخرة'},
  ],
  'Tomato___Leaf_Mold': [
    {'name': 'Stin',       'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Foliar disease fungicide, controls leaf mold', 'reason_fr': 'Fongicide foliaire contre la moisissure des feuilles', 'reason_ar': 'مبيد الأمراض الورقية يكافح عفن الأوراق'},
    {'name': 'Pristine',   'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Preventive and curative against mold in greenhouses', 'reason_fr': 'Préventif et curatif contre les moisissures en serre', 'reason_ar': 'وقائي وعلاجي ضد العفن في البيوت المحمية'},
  ],
  'Tomato___Septoria_leaf_spot': [
    {'name': 'Preza',      'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'SDHI fungicide, specifically effective against Septoria', 'reason_fr': 'Fongicide SDHI, spécifiquement efficace contre Septoria', 'reason_ar': 'مبيد SDHI فعّال خصيصاً ضد سبتوريا'},
    {'name': 'Azumo',      'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Triazole against septoria leaf spot', 'reason_fr': 'Triazole contre la septoriose', 'reason_ar': 'ترايازول ضد تبقع سبتوريا'},
    {'name': 'Cuprofix',   'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Protective copper spray, apply every 7-10 days', 'reason_fr': 'Pulvérisation cuivrique protectrice tous les 7-10 jours', 'reason_ar': 'رش نحاسي وقائي كل 7-10 أيام'},
  ],
  'Tomato___Spider_mites Two-spotted_spider_mite': [
    {'name': 'Takumi',       'cat_en': 'Insecticide', 'cat_fr': 'Insecticide', 'cat_ar': 'مبيد حشري', 'reason_en': 'Acaricide specifically against spider mites', 'reason_fr': 'Acaricide spécifique contre les acariens', 'reason_ar': 'مبيد عث متخصص ضد العناكب الحمراء'},
    {'name': 'Aggis',        'cat_en': 'Insecticide', 'cat_fr': 'Insecticide', 'cat_ar': 'مبيد حشري', 'reason_en': 'Controls thrips and spider mites effectively', 'reason_fr': 'Contrôle les thrips et acariens efficacement', 'reason_ar': 'يكافح التربس والعناكب بفعالية'},
    {'name': 'Voliam Targo (Syngenta)', 'cat_en': 'Insecticide', 'cat_fr': 'Insecticide', 'cat_ar': 'مبيد حشري', 'reason_en': 'Mixed insecticide-acaricide, broad spectrum', 'reason_fr': 'Insecto-acaricide mixte à large spectre', 'reason_ar': 'مبيد حشري وعث مزدوج واسع الطيف'},
  ],
  'Tomato___Target_Spot': [
    {'name': 'Ortiva Top',   'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Premium mixed fungicide, strobilurin + triazole', 'reason_fr': 'Fongicide mixte premium, strobilurine + triazole', 'reason_ar': 'مبيد مزدوج ممتاز ستروبيلورين + ترايازول'},
    {'name': 'Azumo',        'cat_en': 'Fungicide', 'cat_fr': 'Fongicide', 'cat_ar': 'مبيد فطري', 'reason_en': 'Triazole against target spot lesions', 'reason_fr': 'Triazole contre les lésions de la tache cible', 'reason_ar': 'ترايازول ضد التبقع الدائري'},
  ],
  'Tomato___Tomato_Yellow_Leaf_Curl_Virus': [
    {'name': 'Calypso',              'cat_en': 'Insecticide', 'cat_fr': 'Insecticide', 'cat_ar': 'مبيد حشري', 'reason_en': 'Systemic insecticide against whitefly (virus vector)', 'reason_fr': 'Insecticide systémique contre les aleurodes (vecteur)', 'reason_ar': 'جهازي ضد الذبابة البيضاء ناقلة الفيروس'},
    {'name': 'Volteo',               'cat_en': 'Insecticide', 'cat_fr': 'Insecticide', 'cat_ar': 'مبيد حشري', 'reason_en': 'Specifically against whitefly populations', 'reason_fr': 'Spécifiquement contre les mouches blanches', 'reason_ar': 'متخصص ضد الذبابة البيضاء'},
    {'name': 'Movento (Bayer)',       'cat_en': 'Insecticide', 'cat_fr': 'Insecticide', 'cat_ar': 'مبيد حشري', 'reason_en': 'Bidirectional systemic, reaches hidden whitefly larvae', 'reason_fr': 'Systémique bidirectionnel, atteint les larves cachées', 'reason_ar': 'جهازي ثنائي الاتجاه، يصل لليرقات المختبئة'},
  ],
  'Tomato___Tomato_mosaic_virus': [
    {'name': 'Calypso', 'cat_en': 'Insecticide', 'cat_fr': 'Insecticide', 'cat_ar': 'مبيد حشري', 'reason_en': 'Controls aphids and thrips that transmit the virus', 'reason_fr': 'Contrôle pucerons et thrips transmettant le virus', 'reason_ar': 'يكافح المن والتربس الناقلين للفيروس'},
    {'name': 'Aggis',   'cat_en': 'Insecticide', 'cat_fr': 'Insecticide', 'cat_ar': 'مبيد حشري', 'reason_en': 'Against thrips populations involved in virus spread', 'reason_fr': 'Contre les thrips impliqués dans la propagation virale', 'reason_ar': 'ضد التربس الناقل للفيروس'},
  ],

  // ── Blueberry, Raspberry, Soybean, Peach healthy — fertilizers ──
  'Blueberry___healthy': [
    {'name': 'Manni-Plex K', 'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Potassium foliar fertilizer for optimal berry quality', 'reason_fr': 'Fertilisant potassique foliaire pour qualité optimale des baies', 'reason_ar': 'سماد بوتاسيوم ورقي لجودة مثلى للثمار'},
    {'name': 'Algamina',     'cat_en': 'Biostimulant', 'cat_fr': 'Biostimulant', 'cat_ar': 'منشط بيولوجي', 'reason_en': 'Seaweed biostimulant for plant vigor and growth', 'reason_fr': 'Biostimulant algues pour vigueur et croissance', 'reason_ar': 'منشط طحالب لتعزيز النمو والقوة'},
  ],
  'Soybean___healthy': [
    {'name': 'Manni-Plex K', 'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Potassium for optimal pod fill', 'reason_fr': 'Potassium pour remplissage optimal des gousses', 'reason_ar': 'بوتاسيوم لأفضل حشو للقرون'},
    {'name': 'Boramin',      'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Boron + nitrogen fertilizer for legume crops', 'reason_fr': 'Bore et azote pour légumineuses', 'reason_ar': 'بورون وآزوت للمحاصيل البقولية'},
  ],
  'Corn___healthy': [
    {'name': 'RA.AN L13186', 'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Complex foliar fertilizer for ear development', 'reason_fr': 'Fertilisant foliaire complexe pour développement de l\'épi', 'reason_ar': 'سماد ورقي مركب لتطوير السنبلة'},
    {'name': 'Algamina',     'cat_en': 'Biostimulant', 'cat_fr': 'Biostimulant', 'cat_ar': 'منشط بيولوجي', 'reason_en': 'Biostimulant to boost plant immunity and yield', 'reason_fr': 'Biostimulant pour renforcer l\'immunité et le rendement', 'reason_ar': 'منشط بيولوجي لتعزيز المناعة والإنتاجية'},
  ],
  'Tomato___healthy': [
    {'name': 'Naturquel CA/B', 'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Calcium + boron chelate to prevent blossom end rot', 'reason_fr': 'Chélate calcium + bore pour prévenir la pourriture apicale', 'reason_ar': 'كيلات كالسيوم وبورون لمنع تعفن الزهرة'},
    {'name': 'Algamina',       'cat_en': 'Biostimulant', 'cat_fr': 'Biostimulant', 'cat_ar': 'منشط بيولوجي', 'reason_en': 'Biostimulant for fruit quality and plant vigor', 'reason_fr': 'Biostimulant pour qualité des fruits et vigueur', 'reason_ar': 'منشط بيولوجي لجودة الثمار والقوة النباتية'},
  ],
  'Apple___healthy': [
    {'name': 'Manni-Plex K', 'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Potassium foliar to improve fruit size and color', 'reason_fr': 'Potassium foliaire pour améliorer calibre et couleur des fruits', 'reason_ar': 'بوتاسيوم ورقي لتحسين حجم الثمار ولونها'},
    {'name': 'Rooter 5',    'cat_en': 'Biostimulant', 'cat_fr': 'Biostimulant', 'cat_ar': 'منشط بيولوجي', 'reason_en': 'Rooting stimulant for vigor and nutrient uptake', 'reason_fr': 'Stimulateur d\'enracinement pour vigueur et absorption', 'reason_ar': 'منشط تجذير لتحسين النمو وامتصاص المغذيات'},
  ],
  'Grape___healthy': [
    {'name': 'Manni-Plex K', 'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Potassium for berry quality and sugar content', 'reason_fr': 'Potassium pour qualité des baies et teneur en sucre', 'reason_ar': 'بوتاسيوم لجودة الثمار ومحتوى السكر'},
    {'name': 'Borengel',     'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Boron gel for pollination and fruit set', 'reason_fr': 'Bore en gel pour pollinisation et nouaison', 'reason_ar': 'بورون جل للتلقيح وتشكيل الثمار'},
  ],
  'Strawberry___healthy': [
    {'name': 'Naturquel CA/B', 'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Calcium + boron for firm fruit and root health', 'reason_fr': 'Calcium + bore pour fruits fermes et santé racinaire', 'reason_ar': 'كالسيوم وبورون لثمار متماسكة وجذور صحية'},
    {'name': 'Osiryl',        'cat_en': 'Biostimulant', 'cat_fr': 'Biostimulant', 'cat_ar': 'منشط بيولوجي', 'reason_en': 'Amino acids biostimulant for plant recovery and yield', 'reason_fr': 'Biostimulant acides aminés pour reprise et rendement', 'reason_ar': 'منشط أحماض أمينية للنمو والإنتاجية'},
  ],
  'Potato___healthy': [
    {'name': 'Manni-Plex K', 'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Potassium for tuber development and starch quality', 'reason_fr': 'Potassium pour développement des tubercules', 'reason_ar': 'بوتاسيوم لتطور الدرنات وجودة النشا'},
    {'name': 'Calimag Plus', 'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Calcium + magnesium to prevent internal disorders', 'reason_fr': 'Calcium + magnésium contre les désordres internes', 'reason_ar': 'كالسيوم ومغنيسيوم لمنع الاضطرابات الداخلية'},
  ],
  'Peach___healthy': [
    {'name': 'Manni-Plex K', 'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Potassium for peach size, color and sugar content', 'reason_fr': 'Potassium pour calibre, couleur et sucre des pêches', 'reason_ar': 'بوتاسيوم لحجم الخوخ ولونه وسكره'},
    {'name': 'Algamina',     'cat_en': 'Biostimulant', 'cat_fr': 'Biostimulant', 'cat_ar': 'منشط بيولوجي', 'reason_en': 'Marine algae biostimulant for fruit development', 'reason_fr': 'Biostimulant algues marines pour développement des fruits', 'reason_ar': 'منشط طحالب بحرية لتطور الثمار'},
  ],
  'Cherry___healthy': [
    {'name': 'Borengel',     'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Boron for fruit set and quality in cherries', 'reason_fr': 'Bore pour la nouaison et qualité des cerises', 'reason_ar': 'بورون للتلقيح وجودة الكرز'},
    {'name': 'Manni-Plex K', 'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Potassium foliar for fruit firmness', 'reason_fr': 'Potassium foliaire pour la fermeté des fruits', 'reason_ar': 'بوتاسيوم ورقي لتماسك الثمار'},
  ],
  'Raspberry___healthy': [
    {'name': 'Algamina',     'cat_en': 'Biostimulant', 'cat_fr': 'Biostimulant', 'cat_ar': 'منشط بيولوجي', 'reason_en': 'Seaweed biostimulant for cane vigor', 'reason_fr': 'Biostimulant algues pour vigueur des cannes', 'reason_ar': 'منشط طحالب لقوة القصبات'},
    {'name': 'Manni-Plex K', 'cat_en': 'Fertilizer', 'cat_fr': 'Fertilisant', 'cat_ar': 'سماد', 'reason_en': 'Potassium for fruit quality and sweetness', 'reason_fr': 'Potassium pour qualité et sucrosité des fruits', 'reason_ar': 'بوتاسيوم لجودة الثمار وحلاوتها'},
  ],
};

// ── Couleur par catégorie ─────────────────────────────────────────
Color _categoryColor(String category, bool isDark) {
  final c = category.toLowerCase();
  if (c.contains('insect') || c.contains('حشري')) {
    return isDark ? const Color(0xFFFF6B6B) : const Color(0xFFE53935);
  }
  if (c.contains('herb') || c.contains('أعشاب')) {
    return isDark ? const Color(0xFFFFB347) : const Color(0xFFF57C00);
  }
  if (c.contains('fertil') || c.contains('سماد')) {
    return isDark ? const Color(0xFF4CAF50) : const Color(0xFF388E3C);
  }
  if (c.contains('bio') || c.contains('منشط')) {
    return isDark ? const Color(0xFF26C6DA) : const Color(0xFF00838F);
  }
  // Fongicide default
  return isDark ? const Color(0xFF7C4DFF) : const Color(0xFF6A1B9A);
}

IconData _categoryIcon(String category) {
  final c = category.toLowerCase();
  if (c.contains('insect') || c.contains('حشري')) return Icons.bug_report_outlined;
  if (c.contains('herb') || c.contains('أعشاب')) return Icons.grass_outlined;
  if (c.contains('fertil') || c.contains('سماد')) return Icons.spa_outlined;
  if (c.contains('bio') || c.contains('منشط')) return Icons.eco_outlined;
  return Icons.science_outlined;
}

// ── Widget principal ──────────────────────────────────────────────
class ProductRecommendationBox extends StatelessWidget {
  final String disease;   // clé brute dataset
  final String lang;      // 'EN' | 'FR' | 'AR'

  const ProductRecommendationBox({
    super.key,
    required this.disease,
    required this.lang,
  });

  @override
  Widget build(BuildContext context) {
    final products = _diseaseProducts[disease];
    if (products == null || products.isEmpty) return const SizedBox.shrink();

    final isDark = Theme.of(context).brightness == Brightness.dark;

    final surface       = isDark ? AppColors.surface       : AppColorsLight.surface;
    final surfaceAlt    = isDark ? AppColors.surfaceAlt    : AppColorsLight.surfaceAlt;
    final border        = isDark ? AppColors.border        : AppColorsLight.border;
    final textPrimary   = isDark ? AppColors.textPrimary   : AppColorsLight.textPrimary;
    final textSecondary = isDark ? AppColors.textSecondary : AppColorsLight.textSecondary;
    final gold          = isDark ? AppColors.gold          : AppColorsLight.gold;

    // Textes traduits du titre
    final title = lang == 'AR'
        ? 'المنتجات الموصى بها'
        : lang == 'FR'
            ? 'Produits Recommandés'
            : 'Recommended Products';

    final isRtl = lang == 'AR';

    return Directionality(
      textDirection: isRtl ? TextDirection.rtl : TextDirection.ltr,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: gold.withOpacity(0.3)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Header ─────────────────────────────────────────────
            Row(children: [
              Container(
                width: 32, height: 32,
                decoration: BoxDecoration(
                  color: gold.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.shopping_bag_outlined, color: gold, size: 18),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                  color: gold,
                ),
              ),
            ]),
            const SizedBox(height: 14),

            // ── Liste des produits ──────────────────────────────────
            ...products.asMap().entries.map((entry) {
              final i = entry.key;
              final p = entry.value;

              final catKey = lang == 'AR' ? 'cat_ar'
                           : lang == 'FR' ? 'cat_fr'
                           : 'cat_en';
              final reasonKey = lang == 'AR' ? 'reason_ar'
                              : lang == 'FR' ? 'reason_fr'
                              : 'reason_en';

              final category = p[catKey] ?? p['cat_en']!;
              final reason   = p[reasonKey] ?? p['reason_en']!;
              final color    = _categoryColor(category, isDark);
              final icon     = _categoryIcon(category);

              return Column(
                children: [
                  if (i > 0) ...[
                    Divider(height: 16, color: border, thickness: 0.5),
                  ],
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: surfaceAlt,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: color.withOpacity(0.2)),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36, height: 36,
                          decoration: BoxDecoration(
                            color: color.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(icon, color: color, size: 18),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: Text(
                                      p['name']!,
                                      style: TextStyle(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w700,
                                        color: textPrimary,
                                      ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 3),
                                    decoration: BoxDecoration(
                                      color: color.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                    child: Text(
                                      category,
                                      style: TextStyle(
                                        fontSize: 10,
                                        fontWeight: FontWeight.w600,
                                        color: color,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 4),
                              Text(
                                reason,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: textSecondary,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}