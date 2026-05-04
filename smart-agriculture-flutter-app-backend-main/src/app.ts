import express, { Request, Response } from "express";

import multer from "multer";
import path from "path";
import fs from "fs";
import FormData from "form-data";
import axios from "axios";
import historyRoute from "./routes/historyRoute";

import csv from "csv-parser";

import cors from "cors";
import dotenv from "dotenv";
import pool from "./config/database";
import authRouter from "./routes/authRoute";
import farmerRoute from "./routes/farmerRoute";
import errorHandling from "./middleware/errorHandler";
import priceRoute from "./routes/priceRoute";   // avec les autres imports
import profileRoute from "./routes/profileRoute";
import userRoute from "./routes/userRoute";
import productRoute from "./routes/productRoute";

dotenv.config();

const app = express();

app.get("/health", (req, res) => res.status(200).json({ status: "ok" }));
const port = process.env.PORT || 6070;

const upload = multer({ dest: "uploads/" });

app.use(express.json());
app.use(cors());


app.use("/api/auth", authRouter);
app.use("/api/farmer", farmerRoute);
app.use("/api/prices", priceRoute);
app.use("/api/history", historyRoute);
app.use("/api/profile", profileRoute);
app.use("/api/users", userRoute);
app.use("/api/products", productRoute);
app.use("/uploads", express.static(path.join(__dirname, "../uploads")));

// Disease Detection endpoint
app.post("/predict", upload.single("image"), async (req: Request, res: Response) => {
  console.log("PREDICT REQUEST REÇU");
  if (!req.file) {
      return res.status(400).json({ error: "No file uploaded" });
  }

  const imagePath = path.resolve(req.file.path);
  const requestedLang = (req.headers['accept-language'] || 'EN').toString().toUpperCase();

  // Helper: call CNN for a single language with timeout
  const callCNN = async (lang: string): Promise<any> => {
      const fd = new FormData();
      fd.append("image", fs.createReadStream(imagePath));
      const r = await axios.post(
          `https://agriscan-cnn.onrender.com/predict?lang=${lang}`,
          fd,
          { headers: fd.getHeaders(), timeout: 60000 }
      );
      return r.data;
  };

  try {
      // Step 1: call CNN once with the requested language
      const primary = await callCNN(requestedLang);

      // Step 2: call the other 2 languages independently — never block the response
      const otherLangs = ['EN', 'FR', 'AR'].filter(l => l !== requestedLang);
      const results: Record<string, any> = { [requestedLang]: primary };

      await Promise.allSettled(
          otherLangs.map(lang =>
              callCNN(lang)
                  .then(r => { results[lang] = r; })
                  .catch(() => { results[lang] = null; })
          )
      );

      if (fs.existsSync(imagePath)) fs.unlinkSync(imagePath);

      const en = results['EN'];
      const fr = results['FR'];
      const ar = results['AR'];

      res.json({
          disease:          primary.disease,
          confidence:       primary.confidence,
          plant_name:       primary.plant_name,
          disease_label:    primary.disease_label,
          advice:           primary.advice,
          advice_en:        en?.advice        ?? primary.advice,
          advice_fr:        fr?.advice        ?? primary.advice,
          advice_ar:        ar?.advice        ?? primary.advice,
          plant_name_en:    en?.plant_name    ?? primary.plant_name,
          plant_name_fr:    fr?.plant_name    ?? primary.plant_name,
          plant_name_ar:    ar?.plant_name    ?? primary.plant_name,
          disease_label_en: en?.disease_label ?? primary.disease_label,
          disease_label_fr: fr?.disease_label ?? primary.disease_label,
          disease_label_ar: ar?.disease_label ?? primary.disease_label,
      });
  } catch (error: any) {
      if (fs.existsSync(imagePath)) fs.unlinkSync(imagePath);
      res.status(500).json({ error: error.message });
  }
});


app.use((err: any, req: any, res: any, next: any) => {
  console.error("ERREUR GLOBALE:", err);
  res.status(500).json({ message: "Something went wrong", error: err.message });
});

// API to fetch crop, stage and soil types names from CSV
app.get("/api/dropdowns", async (req: Request, res: Response) => {
  const csvFilePath = path.resolve(__dirname, "../src/fertilizer_recommendation_dataset.csv");

    const crops: Set<string> = new Set();
    const stages: Set<string> = new Set();
    const soilTypes: Set<string> = new Set();

    fs.createReadStream(csvFilePath)
        .pipe(csv())
        .on("data", (row) => {
            crops.add(row.Crop);
            stages.add(row.Stage);
            soilTypes.add(row.Soil_Type);
        })
        .on("end", () => {
            res.json({
                crops: Array.from(crops),
                stages: Array.from(stages),
                soilTypes: Array.from(soilTypes),
            });
        })
        .on("error", (error) => {
            res.status(500).json({ error: error.message });
        }); 

});

// Fertilizer Prediction endpoint
app.post("/predict_fertilizer", async (req: Request, res: Response) => {
    // Validate the request body
    const { crop, stage, soil_type, N, P, K, pH, organic_carbon, temp, rainfall } = req.body;

    if (
        crop === undefined || crop === null || crop === '' ||
        stage === undefined || stage === null || stage === '' ||
        soil_type === undefined || soil_type === null || soil_type === '' ||
        N === undefined || N === null ||
        P === undefined || P === null ||
        K === undefined || K === null ||
        pH === undefined || pH === null ||
        organic_carbon === undefined || organic_carbon === null ||
        temp === undefined || temp === null ||
        rainfall === undefined || rainfall === null
    ) {
        return res.status(400).json({ error: "Missing required fields" });
    }

    try {
        // Prepare data to send to Flask API
        const payload = {
            crop,
            stage,
            soil_type,
            N,
            P,
            K,
            pH,
            organic_carbon,
            temp,
            rainfall,
        };

        // Send POST request to Flask API running on http://127.0.0.1:5000/predict_fertilizer
        const response = await axios.post(`https://agriscan-fertilizer.onrender.com/predict_fertilizer`, payload, {
            headers: { "Content-Type": "application/json" },
        });

        // Return the prediction result from Flask API
        res.json(response.data);
    } catch (error: any) {
        res.status(500).json({ error: error.message });
    }
});


app.use(errorHandling);

pool.connect()
    .then(() => console.log("Connected to Postgres"))
    .catch(err => console.log("DB connection error", err));

app.listen(port, () => {
    console.log(`Server is running on http://localhost:${port}`);
});