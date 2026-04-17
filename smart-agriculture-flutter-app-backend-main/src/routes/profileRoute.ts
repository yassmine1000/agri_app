import express from "express";
import { authMiddleware } from "../middleware/authMiddleware";
import { getProfile, updateProfile, deleteProfile } from "../controllers/profileController";

const router = express.Router();

router.use(authMiddleware);

router.get("/", getProfile);
router.put("/", updateProfile);
router.delete("/", deleteProfile);

export default router;