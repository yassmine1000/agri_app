import express from "express";
import { validateLogin, validateRegister } from "../middleware/inputValidator";
import { getCurrentUser, loginUser, registerUser } from "../controllers/authController";
import { authMiddleware } from "../middleware/authMiddleware";

const router = express.Router();

router.post("/register", validateRegister, registerUser);
router.post("/login", validateLogin, loginUser);
router.get("/me", authMiddleware, getCurrentUser);

export default router;
