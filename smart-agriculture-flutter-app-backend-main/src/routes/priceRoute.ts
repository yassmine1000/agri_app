import express from "express";
import { getPrices, createPrice, updatePrice, deletePrice } from "../controllers/priceController";
import { authMiddleware, adminOnly } from "../middleware/authMiddleware";

const router = express.Router();

router.get("/", authMiddleware, getPrices);
router.post("/", authMiddleware, adminOnly, createPrice);
router.put("/:id", authMiddleware, adminOnly, updatePrice);
router.delete("/:id", authMiddleware, adminOnly, deletePrice);

export default router;