import express, { Request, Response } from "express";

import multer from "multer";
import path from "path";
import fs from "fs";
import FormData from "form-data";
import axios from "axios";


import csv from "csv-parser";

import cors from "cors";
import dotenv from "dotenv";
import pool from "./config/database";
import authRouter from "./routes/authRoute";
import farmerRoute from "./routes/farmerRoute";
import errorHandling from "./middleware/errorHandler";
import priceRoute from "./routes/priceRoute";   // avec les autres imports

dotenv.config();

const app = express();
const port = process.env.PORT || 6070;

const upload = multer({ dest: "uploads/" });

app.use(express.json());
app.use(cors());

app.use("/uploads", express.static(path.join(__dirname, "uploads")));

app.use("/api/auth", authRouter);
app.use("/api/farmer", farmerRoute);
app.use("/api/prices", priceRoute);

// Disease Detection endpoint
app.post("/predict", upload.single("image"), async (req: Request, res: Response) => {
    console.log("PREDICT REQUEST REÇU");  // ← AJOUTE ICI  
    if (!req.file) {
        return res.status(400).json({ error: "No file uploaded" });
    }

    const imagePath = path.resolve(req.file.path);

    try {
        const formData = new FormData();
        const fileStream = fs.createReadStream(imagePath);
        formData.append("image", fileStream);  // was "file"

        console.log("ENVOI A FLASK..."); // ← AJOUTE
        const response = await axios.post("http://127.0.0.1:4000/predict", formData, {
            headers: formData.getHeaders(),
        });
        console.log("REPONSE FLASK:", response.data); // ← AJOUTE
        fs.unlinkSync(imagePath); // cleanup
        res.json(response.data);
    } catch (error: any) {
        console.log("ERREUR FLASK:", error.message); // ← AJOUTE ICI
        fs.unlinkSync(imagePath);
        res.status(500).json({ error: error.message });
    }
});

// API to fetch crop, stage and soil types names from CSV
app.get("/api/dropdowns", async (req: Request, res: Response) => {
    const csvFilePath = path.resolve(__dirname, "fertilizer_recommendation_dataset.csv");

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

    if (!crop || !stage || !soil_type || !N || !P || !K || !pH || !organic_carbon || !temp || !rainfall) {
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
        const response = await axios.post("http://192.168.100.35:5000/predict_fertilizer", payload, {
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
