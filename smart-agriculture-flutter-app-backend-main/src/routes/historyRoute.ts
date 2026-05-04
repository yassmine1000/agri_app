import express from "express";
import {
    saveDetection,
    getHistory,
    deleteHistory,
    deleteOneHistory,
} from "../controllers/historyController";
import { authMiddleware } from "../middleware/authMiddleware";

const router = express.Router();

router.post("/",    authMiddleware, saveDetection);
router.get("/",     authMiddleware, getHistory);
router.delete("/",  authMiddleware, deleteHistory);         // clear all
router.delete("/:id", authMiddleware, deleteOneHistory);   // delete one

export default router;