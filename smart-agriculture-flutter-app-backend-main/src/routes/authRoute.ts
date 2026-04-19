import express from "express";
import { register, login, forgotPassword, resetPassword, getQrToken, loginWithQr } from "../controllers/authController";
import { authMiddleware } from "../middleware/authMiddleware";

const router = express.Router();

router.post("/register", register);
router.post("/login", login);
router.post("/forgot-password", forgotPassword);
router.post("/reset-password", resetPassword);
router.post("/login-qr", loginWithQr);
router.get("/qr-token", authMiddleware, getQrToken);

export default router;