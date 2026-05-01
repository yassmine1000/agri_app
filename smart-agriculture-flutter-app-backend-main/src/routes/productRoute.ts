import express from "express";
import multer from "multer";
import path from "path";
import { authMiddleware, adminOnly } from "../middleware/authMiddleware";
import { getAllProducts, getProductById, createProduct, updateProduct, deleteProduct, getProductsByCategory } from "../controllers/productController";

const storage = multer.diskStorage({
  destination: (_req, _file, cb) => cb(null, path.join(__dirname, "../../uploads/products")),
  filename: (_req, file, cb) => {
    const unique = Date.now() + "-" + Math.round(Math.random() * 1e9);
    cb(null, unique + path.extname(file.originalname));
  },
});

const upload = multer({
  storage,
  fileFilter: (_req, file, cb) => {
    const allowed = /jpeg|jpg|png|webp/;
    cb(null, allowed.test(path.extname(file.originalname).toLowerCase()));
  },
  limits: { fileSize: 5 * 1024 * 1024 },
});

const router = express.Router();

// Public routes
router.get("/", getAllProducts); 
router.get("/:id", getProductById);
router.get("/category/:category", getProductsByCategory); 

// Admin only
router.post("/", authMiddleware, adminOnly, upload.single("image"), createProduct);
router.put("/:id", authMiddleware, adminOnly, upload.single("image"), updateProduct);
router.delete("/:id", authMiddleware, adminOnly, deleteProduct);

export default router;