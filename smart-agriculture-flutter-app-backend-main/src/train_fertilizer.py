import pandas as pd
from sklearn.model_selection import train_test_split
from sklearn.preprocessing import LabelEncoder
from sklearn.ensemble import RandomForestRegressor
from sklearn.multioutput import MultiOutputRegressor
import joblib

# Load dataset
df = pd.read_csv("fertilizer_recommendation_dataset.csv")

# Function to parse fertilizer recommendation string into numeric values
def parse_recommendation(rec):
    ferts = {"Urea": 0, "DAP": 0, "MOP": 0, "SSP": 0, "Compost": 0}
    parts = rec.split("+")
    for p in parts:
        p = p.strip()
        for f in ferts.keys():
            if f in p:
                try:
                    ferts[f] = int(p.split("kg")[0].strip())
                except:
                    ferts[f] = 0
    return ferts

fert_values = df["Fertilizer_Recommendation"].apply(parse_recommendation)
fert_df = pd.DataFrame(fert_values.tolist())

# Merge into dataset
df = pd.concat([df, fert_df], axis=1)

# Encode categorical features
label_encoders = {}
for col in ["Crop", "Stage", "Soil_Type"]:
    le = LabelEncoder()
    df[col] = le.fit_transform(df[col])
    label_encoders[col] = le

# Features and targets
X = df.drop(columns=["Fertilizer_Recommendation", "Urea", "DAP", "MOP", "SSP", "Compost"])
y = df[["Urea", "DAP", "MOP", "SSP", "Compost"]]

# Train-test split
X_train, X_test, y_train, y_test = train_test_split(X, y, test_size=0.2, random_state=42)

# Train multi-output regression model
model = MultiOutputRegressor(RandomForestRegressor(n_estimators=200, random_state=42))
model.fit(X_train, y_train)

# Save the trained model
joblib.dump(model, 'fertilizer_model.pkl')
joblib.dump(label_encoders, 'label_encoders.pkl')

print("Model training completed and saved.")
