import express from "express";
import { authMiddleware, adminOnly } from "../middleware/authMiddleware";
import { getAllUsers, getUserById, createUser, updateUser, deleteUser } from "../controllers/userController";

const router = express.Router();

router.use(authMiddleware, adminOnly);

router.get("/", getAllUsers);
router.get("/:id", getUserById);
router.post("/", createUser);
router.put("/:id", updateUser);
router.delete("/:id", deleteUser);

export default router;