import { Request, Response, NextFunction } from "express";
import bcrypt from "bcrypt";
import pool from "../config/database";

// ── Get Profile ───────────────────────────────────────────────────
export const getProfile = async (req: Request, res: Response, next: NextFunction) => {
  const userId = (req.user as any).userId;
  try {
    const result = await pool.query(
      `SELECT id, username, role, name, address, phone_no, alt_contact_no, 
              gender, dob, farm_name, farmer_registration_no, email, created_at
       FROM users WHERE id = $1`,
      [userId]
    );
    if (result.rows.length === 0) {
      return res.status(404).json({ message: "User not found" });
    }
    res.json({ status: "success", data: result.rows[0] });
  } catch (error) {
    next(error);
  }
};

// ── Update Profile ────────────────────────────────────────────────
export const updateProfile = async (req: Request, res: Response, next: NextFunction) => {
  const userId = (req.user as any).userId;
  const { name, address, phone_no, alt_contact_no, gender, dob, farm_name, farmer_registration_no, email, newPassword } = req.body;

  try {
    let passwordUpdate = "";
    const params: any[] = [name, address, phone_no, alt_contact_no, gender, dob, farm_name, farmer_registration_no, email];

    if (newPassword && newPassword.length >= 6) {
      const hashed = await bcrypt.hash(newPassword, 10);
      passwordUpdate = ", password = $10";
      params.push(hashed);
      params.push(userId);
    } else {
      params.push(userId);
    }

    const paramIndex = newPassword && newPassword.length >= 6 ? 11 : 10;

    const result = await pool.query(
      `UPDATE users SET 
        name = $1, address = $2, phone_no = $3, alt_contact_no = $4,
        gender = $5, dob = $6, farm_name = $7, farmer_registration_no = $8,
        email = $9${passwordUpdate}
       WHERE id = $${paramIndex} RETURNING id, username, role, name, address, 
       phone_no, alt_contact_no, gender, dob, farm_name, farmer_registration_no, email`,
      params
    );

    res.json({ status: "success", data: result.rows[0] });
  } catch (error) {
    next(error);
  }
};

// ── Delete Profile ────────────────────────────────────────────────
export const deleteProfile = async (req: Request, res: Response, next: NextFunction) => {
  const userId = (req.user as any).userId;
  try {
    await pool.query("DELETE FROM users WHERE id = $1", [userId]);
    res.json({ status: "success", message: "Account deleted successfully" });
  } catch (error) {
    next(error);
  }
};