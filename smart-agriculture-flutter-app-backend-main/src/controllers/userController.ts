import { Request, Response, NextFunction } from "express";
import bcrypt from "bcrypt";
import crypto from "crypto";
import pool from "../config/database";

// ── Get all users ─────────────────────────────────────────────────
export const getAllUsers = async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await pool.query(
      `SELECT id, username, role, name, email, phone_no, address, gender, dob,
              farm_name, farmer_registration_no, created_at
       FROM users ORDER BY created_at DESC`
    );
    res.json({ status: "success", data: result.rows });
  } catch (error) {
    next(error);
  }
};

// ── Get single user ───────────────────────────────────────────────
export const getUserById = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  try {
    const result = await pool.query(
      `SELECT id, username, role, name, email, phone_no, address, gender, dob,
              farm_name, farmer_registration_no, created_at
       FROM users WHERE id = $1`,
      [id]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json({ status: "success", data: result.rows[0] });
  } catch (error) {
    next(error);
  }
};

// ── Create user (admin) ───────────────────────────────────────────
export const createUser = async (req: Request, res: Response, next: NextFunction) => {
  const { username, password, role, name, email, phone_no, address, gender, dob, farm_name, farmer_registration_no } = req.body;
  try {
    const existing = await pool.query("SELECT id FROM users WHERE username = $1", [username]);
    if (existing.rows.length > 0) {
      return res.status(400).json({ message: "Username already exists" });
    }
    if (email && email.trim() !== '') {
      const emailCheck = await pool.query("SELECT id FROM users WHERE email = $1", [email]);
      if (emailCheck.rows.length > 0) {
        return res.status(400).json({ message: "This email address is already associated with an account" });
      }
    }
    const hashedPassword = await bcrypt.hash(password || "agriscan123", 10);
    const qrToken = crypto.randomBytes(32).toString('hex');

    const result = await pool.query(
      `INSERT INTO users (username, password, role, name, email, phone_no, address, gender, dob, farm_name, farmer_registration_no, qr_token)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12)
       RETURNING id, username, role, name, email`,
      [username, hashedPassword, role || "customer", name || null, email || null,
       phone_no || null, address || null, gender || null, dob || null,
       farm_name || null, farmer_registration_no || null, qrToken]
    );
    res.status(201).json({ status: "success", data: result.rows[0] });
  } catch (error) {
    next(error);
  }
};

// ── Update user (admin) ───────────────────────────────────────────
export const updateUser = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  const { role, name, email, phone_no, address, gender, dob, farm_name, farmer_registration_no, password } = req.body;
  try {
    if (password && password.length >= 6) {
      const hashed = await bcrypt.hash(password, 10);
      const result = await pool.query(
        `UPDATE users SET role=$1, name=$2, email=$3, phone_no=$4, address=$5,
         gender=$6, dob=$7, farm_name=$8, farmer_registration_no=$9, password=$10
         WHERE id=$11
         RETURNING id, username, role, name, email`,
        [role, name, email, phone_no, address, gender, dob, farm_name, farmer_registration_no, hashed, id]
      );
      if (result.rows.length === 0) return res.status(404).json({ message: "User not found" });
      return res.json({ status: "success", data: result.rows[0] });
    } else {
      const result = await pool.query(
        `UPDATE users SET role=$1, name=$2, email=$3, phone_no=$4, address=$5,
         gender=$6, dob=$7, farm_name=$8, farmer_registration_no=$9
         WHERE id=$10
         RETURNING id, username, role, name, email`,
        [role, name, email, phone_no, address, gender, dob, farm_name, farmer_registration_no, id]
      );
      if (result.rows.length === 0) return res.status(404).json({ message: "User not found" });
      return res.json({ status: "success", data: result.rows[0] });
    }
  } catch (error) {
    next(error);
  }
};

// ── Delete user (admin) ───────────────────────────────────────────
export const deleteUser = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  const adminId = (req as any).user?.userId;
  try {
    if (parseInt(id as string) === adminId) {
      return res.status(400).json({ message: "Cannot delete your own account" });
    }
    const result = await pool.query("DELETE FROM users WHERE id = $1 RETURNING id", [Array.isArray(id) ? id[0] : String(id)]);
    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json({ status: "success", message: "User deleted successfully" });
  } catch (error) {
    next(error);
  }
};
