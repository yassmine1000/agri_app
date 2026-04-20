import { Request, Response, NextFunction } from "express";
import pool from "../config/database";
import fs from "fs";
import path from "path";

// ── Get all products ──────────────────────────────────────────────
export const getAllProducts = async (_req: Request, res: Response, next: NextFunction) => {
  try {
    const result = await pool.query(
      `SELECT * FROM products ORDER BY category, name ASC`
    );
    res.json({ status: "success", data: result.rows });
  } catch (error) {
    next(error);
  }
};

// ── Get single product ────────────────────────────────────────────
export const getProductById = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  try {
    const result = await pool.query("SELECT * FROM products WHERE id = $1", [id]);
    if (result.rows.length === 0) return res.status(404).json({ message: "Product not found" });
    res.json({ status: "success", data: result.rows[0] });
  } catch (error) {
    next(error);
  }
};

// ── Create product (admin) ────────────────────────────────────────
export const createProduct = async (req: Request, res: Response, next: NextFunction) => {
  const { name, name_fr, name_ar, price, category, category_fr, category_ar, description, description_fr, description_ar, stock_available } = req.body;
  const imageUrl = req.file ? `/uploads/products/${req.file.filename}` : null;
  try {
    const result = await pool.query(
      `INSERT INTO products (name, name_fr, name_ar, price, category, category_fr, category_ar, description, description_fr, description_ar, image_url, stock_available)
       VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12) RETURNING *`,
      [name, name_fr || name, name_ar || name, parseFloat(price), category, category_fr || category, category_ar || category,
       description || null, description_fr || null, description_ar || null, imageUrl, stock_available !== 'false']
    );
    res.status(201).json({ status: "success", data: result.rows[0] });
  } catch (error) {
    next(error);
  }
};

// ── Update product (admin) ────────────────────────────────────────
export const updateProduct = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  const { name, name_fr, name_ar, price, category, category_fr, category_ar, description, description_fr, description_ar, stock_available } = req.body;

  try {
    // Get old image if new one uploaded
    let imageUrl: string | null = null;
    if (req.file) {
      imageUrl = `/uploads/products/${req.file.filename}`;
      // Delete old image
      const old = await pool.query("SELECT image_url FROM products WHERE id = $1", [id]);
      if (old.rows[0]?.image_url) {
        const oldPath = path.join(__dirname, "../..", old.rows[0].image_url);
        if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
      }
    }

    const result = await pool.query(
      `UPDATE products SET
        name=$1, name_fr=$2, name_ar=$3, price=$4,
        category=$5, category_fr=$6, category_ar=$7,
        description=$8, description_fr=$9, description_ar=$10,
        stock_available=$11
        ${imageUrl ? ', image_url=$13' : ''}
       WHERE id=$12 RETURNING *`,
      imageUrl
        ? [name, name_fr, name_ar, parseFloat(price), category, category_fr, category_ar, description, description_fr, description_ar, stock_available !== 'false', id, imageUrl]
        : [name, name_fr, name_ar, parseFloat(price), category, category_fr, category_ar, description, description_fr, description_ar, stock_available !== 'false', id]
    );
    if (result.rows.length === 0) return res.status(404).json({ message: "Product not found" });
    res.json({ status: "success", data: result.rows[0] });
  } catch (error) {
    next(error);
  }
};

// ── Delete product (admin) ────────────────────────────────────────
export const deleteProduct = async (req: Request, res: Response, next: NextFunction) => {
  const { id } = req.params;
  try {
    const old = await pool.query("SELECT image_url FROM products WHERE id = $1", [id]);
    if (old.rows[0]?.image_url) {
      const oldPath = path.join(__dirname, "../..", old.rows[0].image_url);
      if (fs.existsSync(oldPath)) fs.unlinkSync(oldPath);
    }
    await pool.query("DELETE FROM products WHERE id = $1", [id]);
    res.json({ status: "success", message: "Product deleted" });
  } catch (error) {
    next(error);
  }
};