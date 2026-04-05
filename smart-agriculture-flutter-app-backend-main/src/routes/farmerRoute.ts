import express from "express";
import { authMiddleware, farmerOnly } from "../middleware/authMiddleware";
import { createCropPlanning, getCropPlanning, createTask, getTasksCalendar, getCropLibrary, updateTaskStatus, deleteTask, getTasksByPlanningId } from "../controllers/farmerController";

const router = express.Router();

router.use(authMiddleware, farmerOnly);

router.get("/get_crop_list", getCropLibrary);
router.post("/planning", createCropPlanning);
router.get("/planning", getCropPlanning);
router.post("/tasks", createTask);
router.get("/tasks/calendar", getTasksCalendar);
router.get("/tasks/:planning_id/tasks", getTasksByPlanningId);
router.patch("/tasks/:task_id", updateTaskStatus);
router.delete("/tasks/:task_id", deleteTask);

export default router;
