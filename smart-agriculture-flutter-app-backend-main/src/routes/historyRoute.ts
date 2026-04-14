import express from "express";
import { saveDetection, getHistory, deleteHistory } from "../controllers/historyController";
import { authMiddleware } from "../middleware/authMiddleware";

const router = express.Router();

router.post("/", authMiddleware, saveDetection);
router.get("/", authMiddleware, getHistory);
router.delete("/", authMiddleware, deleteHistory);

export default router;