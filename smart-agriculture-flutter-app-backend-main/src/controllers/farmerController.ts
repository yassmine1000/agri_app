import { Request, Response, NextFunction } from "express";
import pool from "../config/database";

// Get all crop list
export const getCropLibrary = async (_req: Request, res: Response, next: NextFunction) => {
    try {
        const result = await pool.query(`
            SELECT id, name, name_fr, name_ar,
                   ideal_season, ideal_season_fr, ideal_season_ar,
                   duration_days, duration_label_en, duration_label_fr, duration_label_ar,
                   ideal_sowing_period, ideal_sowing_period_fr, ideal_sowing_period_ar
            FROM crop_library 
            ORDER BY id ASC
        `);
        res.json({ status: "success", data: result.rows });
    } catch (error) {
        next(error);
    }
};

// Create crop planning for a farmer
export const createCropPlanning = async (req: Request, res: Response, next: NextFunction) => {
    const userId = (req.user as any).userId;
    const { crop_id, start_date, expected_harvest_date, notes, irrigation_reminder, fertilizer_reminder } = req.body;

    try {
        const result = await pool.query(
            `INSERT INTO crop_planning 
            (user_id, crop_id, start_date, expected_harvest_date, notes, irrigation_reminder, fertilizer_reminder)
            VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
            [userId, crop_id, start_date, expected_harvest_date, notes || null,
                irrigation_reminder || false, fertilizer_reminder || false]
        );
        res.status(201).json({ status: "success", data: result.rows[0] });
    } catch (error) {
        next(error);
    }
};

// Get all crop planning records for the logged-in farmer
export const getCropPlanning = async (req: Request, res: Response, next: NextFunction) => {
    const userId = (req.user as any).userId;
    try {
        const result = await pool.query(
            `SELECT cp.*, c.name AS crop_name FROM crop_planning cp
             JOIN crop_library c ON cp.crop_id = c.id
             WHERE cp.user_id = $1 ORDER BY cp.start_date`,
            [userId]
        );
        res.json({ status: "success", data: result.rows });
    } catch (error) {
        next(error);
    }
};

// Create a task manually for a planning
export const createTask = async (req: Request, res: Response, next: NextFunction) => {
    const userId = (req.user as any).userId;
    const { planning_id, task_type, task_date } = req.body;

    try {
        const planningCheck = await pool.query(
            `SELECT id FROM crop_planning WHERE id=$1 AND user_id=$2`,
            [planning_id, userId]
        );
        if (planningCheck.rowCount === 0) {
            return res.status(403).json({ status: "fail", message: "Unauthorized or invalid planning" });
        }
        const result = await pool.query(
            `INSERT INTO crop_tasks (planning_id, task_type, task_date) VALUES ($1, $2, $3) RETURNING *`,
            [planning_id, task_type, task_date]
        );
        res.status(201).json({ status: "success", data: result.rows[0] });
    } catch (error) {
        next(error);
    }
};

// Get calendar tasks for logged-in farmer
export const getTasksCalendar = async (req: Request, res: Response, next: NextFunction) => {
    const userId = (req.user as any).userId;
    try {
        const result = await pool.query(
            `SELECT t.id, t.task_type, t.task_date, t.status, cp.crop_id, c.name AS crop_name
             FROM crop_tasks t
             JOIN crop_planning cp ON t.planning_id = cp.id
             JOIN crop_library c ON cp.crop_id = c.id
             WHERE cp.user_id = $1
             ORDER BY t.task_date`,
            [userId]
        );
        res.json({ status: "success", data: result.rows });
    } catch (error) {
        next(error);
    }
};

// Get tasks by planning ID
export const getTasksByPlanningId = async (req: Request, res: Response, next: NextFunction) => {
    const userId = (req.user as any).userId;
    const { planning_id } = req.params;

    try {
        const planningCheck = await pool.query(
            `SELECT id FROM crop_planning WHERE id = $1 AND user_id = $2`,
            [planning_id, userId]
        );
        if (planningCheck.rowCount === 0) {
            return res.status(404).json({ status: "fail", message: "Planning not found or unauthorized" });
        }
        const result = await pool.query(
            `SELECT t.*, c.name AS crop_name
             FROM crop_tasks t
             JOIN crop_planning cp ON t.planning_id = cp.id
             JOIN crop_library c ON cp.crop_id = c.id
             WHERE t.planning_id = $1 AND cp.user_id = $2
             ORDER BY t.task_date`,
            [planning_id, userId]
        );
        res.json({ status: "success", data: result.rows });
    } catch (error) {
        next(error);
    }
};

// Update task status
export const updateTaskStatus = async (req: Request, res: Response, next: NextFunction) => {
    const userId = (req.user as any).userId;
    const { task_id } = req.params;
    const { status } = req.body;

    try {
        const taskCheck = await pool.query(
            `SELECT t.id FROM crop_tasks t
             JOIN crop_planning cp ON t.planning_id = cp.id
             WHERE t.id = $1 AND cp.user_id = $2`,
            [task_id, userId]
        );
        if (taskCheck.rowCount === 0) {
            return res.status(404).json({ status: "fail", message: "Task not found or unauthorized" });
        }
        const result = await pool.query(
            `UPDATE crop_tasks SET status = $1 WHERE id = $2 RETURNING *`,
            [status, task_id]
        );
        res.json({ status: "success", message: "Task status updated successfully", data: result.rows[0] });
    } catch (error) {
        next(error);
    }
};

// Delete a task
export const deleteTask = async (req: Request, res: Response, next: NextFunction) => {
    const userId = (req.user as any).userId;
    const { task_id } = req.params;

    try {
        const taskCheck = await pool.query(
            `SELECT t.id FROM crop_tasks t
             JOIN crop_planning cp ON t.planning_id = cp.id
             WHERE t.id = $1 AND cp.user_id = $2`,
            [task_id, userId]
        );
        if (taskCheck.rowCount === 0) {
            return res.status(404).json({ status: "fail", message: "Task not found or unauthorized" });
        }
        await pool.query(`DELETE FROM crop_tasks WHERE id = $1`, [task_id]);
        res.json({ status: "success", message: "Task deleted successfully" });
    } catch (error) {
        next(error);
    }
};

// Delete a planning
export const deletePlanning = async (req: Request, res: Response, next: NextFunction) => {
    const userId = (req.user as any).userId;
    const { planning_id } = req.params;

    try {
        const check = await pool.query(
            `SELECT id FROM crop_planning WHERE id = $1 AND user_id = $2`,
            [planning_id, userId]
        );
        if (check.rowCount === 0) {
            return res.status(404).json({ status: "fail", message: "Planning not found or unauthorized" });
        }
        await pool.query(`DELETE FROM crop_planning WHERE id = $1`, [planning_id]);
        res.json({ status: "success", message: "Planning deleted successfully" });
    } catch (error) {
        next(error);
    }
};