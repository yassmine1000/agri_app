import express from "express";
import { getTodayPrices, getAllPrices, createPrice, deletePrice } from "../controllers/priceController";
import { authMiddleware, adminOnly } from "../middleware/authMiddleware";

const router = express.Router();

// Accessible à tous les utilisateurs connectés
router.get("/", authMiddleware, getTodayPrices);
router.get("/all", authMiddleware, getAllPrices);

// Réservé à l'admin uniquement
router.post("/", authMiddleware, adminOnly, createPrice);
router.delete("/:id", authMiddleware, adminOnly, deletePrice);

export default router;