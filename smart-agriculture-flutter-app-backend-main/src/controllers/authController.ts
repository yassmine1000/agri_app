import { Request, Response, NextFunction } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import nodemailer from "nodemailer";
import crypto from "crypto";
import pool from "../config/database";


const JWT_SECRET = process.env.JWT_SECRET || "your_jwt_secret";

const transporter = nodemailer.createTransport({
  service: "gmail",
  auth: {
    user: "agriscan2026@gmail.com",
    pass: "sfyb onja eznx dszn",
  },
});

// ── Register ──────────────────────────────────────────────────────
export const register = async (req: Request, res: Response, next: NextFunction) => {
  const { username, password, role, name, address, phone_no, alt_contact_no, gender, dob, farm_name, farmer_registration_no, email } = req.body;
  try {
    const existing = await pool.query("SELECT id FROM users WHERE username = $1", [username]);
    if (existing.rows.length > 0) {
      return res.status(400).json({ message: "Username already exists" });
    }
    const hashedPassword = await bcrypt.hash(password, 10);
    // Générer un token QR unique
    const qrToken = crypto.randomBytes(32).toString('hex');
    const result = await pool.query(
      `INSERT INTO users (username, password, role, name, address, phone_no, alt_contact_no, gender, dob, farm_name, farmer_registration_no, email, qr_token)
       VALUES ($1, $2, $3, $4, $5, $6, $7, $8, $9, $10, $11, $12, $13) RETURNING id, username, role`,
      [username, hashedPassword, role || "customer", name || null, address || null,
       phone_no || null, alt_contact_no || null, gender || null, dob || null,
       farm_name || null, farmer_registration_no || null, email || null, qrToken]
    );
    res.status(201).json({ 
      message: "User registered successfully", 
      user: result.rows[0],
      qr_token: qrToken  // ← ajoute cette ligne
    });
  } catch (error) {
    next(error);
  }
};

// ── Login ─────────────────────────────────────────────────────────
export const login = async (req: Request, res: Response, next: NextFunction) => {
  const { username, password } = req.body;
  try {
    const result = await pool.query("SELECT * FROM users WHERE username = $1", [username]);
    if (result.rows.length === 0) {
      return res.status(401).json({ message: "Invalid credentials" });
    }
    const user = result.rows[0];
    const isMatch = await bcrypt.compare(password, user.password);
    if (!isMatch) {
      return res.status(401).json({ message: "Invalid credentials" });
    }
    const token = jwt.sign(
      { userId: user.id, username: user.username, role: user.role },
      JWT_SECRET,
      { expiresIn: "7d" }
    );
    res.json({
      message: "Login successful",
      token,
      user: { id: user.id, username: user.username, role: user.role, name: user.name },
    });
  } catch (error) {
    next(error);
  }
};

// ── Get QR Token ──────────────────────────────────────────────────
export const getQrToken = async (req: Request, res: Response, next: NextFunction) => {
  const userId = (req.user as any).userId;
  try {
    const result = await pool.query("SELECT qr_token FROM users WHERE id = $1", [userId]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }
    // Si pas de token QR, en générer un
    let qrToken = result.rows[0].qr_token;
    if (!qrToken) {
      qrToken = crypto.randomBytes(32).toString('hex');
      await pool.query("UPDATE users SET qr_token = $1 WHERE id = $2", [qrToken, userId]);
    }
    res.json({ status: "success", qr_token: qrToken });
  } catch (error) {
    next(error);
  }
};

// ── Login with QR ─────────────────────────────────────────────────
export const loginWithQr = async (req: Request, res: Response, next: NextFunction) => {
  const { qr_token } = req.body;
  if (!qr_token) {
    return res.status(400).json({ message: "QR token is required" });
  }
  try {
    const result = await pool.query("SELECT * FROM users WHERE qr_token = $1", [qr_token]);
    if (result.rows.length === 0) {
      return res.status(401).json({ message: "Invalid QR code" });
    }
    const user = result.rows[0];
    const token = jwt.sign(
      { userId: user.id, username: user.username, role: user.role },
      JWT_SECRET,
      { expiresIn: "7d" }
    );
    res.json({
      message: "Login successful",
      token,
      user: { id: user.id, username: user.username, role: user.role, name: user.name },
    });
  } catch (error) {
    next(error);
  }
};

// ── Forgot Password ───────────────────────────────────────────────
export const forgotPassword = async (req: Request, res: Response, next: NextFunction) => {
  const { email } = req.body;
  if (!email) return res.status(400).json({ message: "Email is required" });
  try {
    const result = await pool.query("SELECT * FROM users WHERE email = $1", [email]);
    if (result.rows.length === 0) {
      return res.json({ message: "If this account exists, a reset email has been sent." });
    }
    const user = result.rows[0];
    const resetCode = Math.floor(100000 + Math.random() * 900000).toString();
    const expiry = new Date(Date.now() + 15 * 60 * 1000);
    await pool.query("UPDATE users SET reset_token = $1, reset_token_expiry = $2 WHERE id = $3", [resetCode, expiry, user.id]);
    await transporter.sendMail({
      from: '"AgriScan 🌿" <agriscan2026@gmail.com>',
      to: email,
      subject: "AgriScan — Code de réinitialisation",
      html: `
        <div style="font-family: Arial, sans-serif; max-width: 500px; margin: 0 auto; padding: 20px;">
          <div style="background: linear-gradient(135deg, #00FF88, #00C4FF); padding: 20px; border-radius: 12px; text-align: center; margin-bottom: 20px;">
            <h1 style="color: #0B1120; margin: 0; font-size: 24px;">🌿 AgriScan</h1>
          </div>
          <h2 style="color: #333;">Réinitialisation de mot de passe</h2>
          <p style="color: #666;">Bonjour <strong>${user.name || user.username}</strong>,</p>
          <p style="color: #666;">Voici votre code de réinitialisation :</p>
          <div style="background: #f5f5f5; border-radius: 8px; padding: 20px; text-align: center; margin: 20px 0;">
            <span style="font-size: 36px; font-weight: bold; color: #00AA55; letter-spacing: 8px;">${resetCode}</span>
          </div>
          <p style="color: #999; font-size: 13px;">Ce code expire dans <strong>15 minutes</strong>.</p>
        </div>
      `,
    });
    res.json({ message: "If this account exists, a reset email has been sent." });
  } catch (error) {
    next(error);
  }
};

// ── Reset Password ────────────────────────────────────────────────
export const resetPassword = async (req: Request, res: Response, next: NextFunction) => {
  const { email, code, newPassword } = req.body;
  if (!email || !code || !newPassword) {
    return res.status(400).json({ message: "Email, code and new password are required" });
  }
  try {
    const result = await pool.query(
      "SELECT * FROM users WHERE email = $1 AND reset_token = $2 AND reset_token_expiry > NOW()",
      [email, code]
    );
    if (result.rows.length === 0) {
      return res.status(400).json({ message: "Invalid or expired code" });
    }
    const hashedPassword = await bcrypt.hash(newPassword, 10);
    await pool.query(
      "UPDATE users SET password = $1, reset_token = NULL, reset_token_expiry = NULL WHERE id = $2",
      [hashedPassword, result.rows[0].id]
    );
    res.json({ message: "Password reset successfully" });
  } catch (error) {
    next(error);
  }
};