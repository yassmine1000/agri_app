import { Request, Response, NextFunction } from "express";
import pool from "../config/database";

//get all crop list
export const getCropLibrary = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const result = await pool.query(`
            SELECT id, name, ideal_season, duration_days, ideal_sowing_period FROM crop_library 
            ORDER BY id ASC
        `);
        res.json({ status: "success", data: result.rows });
    } catch (error) {
        next(error);
    }
};

// Create crop planning for a farmer
export const createCropPlanning = async (req: Request, res: Response, next: NextFunction) => {
    const userId = (req.user as any).userId; // Farmer ID from auth middleware
    const { crop_id, start_date, expected_harvest_date, notes, irrigation_reminder, fertilizer_reminder } 
    = req.body;

    try {
        // Insert new planning record
        const result = await pool.query(
            `INSERT INTO crop_planning 
            (user_id, crop_id, start_date, expected_harvest_date, notes, irrigation_reminder, 
            fertilizer_reminder)
            VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *`,
            [userId, crop_id, start_date, expected_harvest_date, notes || null, 
                irrigation_reminder || false, fertilizer_reminder || false]
        );
        const planning = result.rows[0];

        // Optionally generate initial tasks like sowing and harvest reminders here if desired

        res.status(201).json({ status: "success", data: planning });
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

// Create a task manually for a planning (or automatically depending on use case)
export const createTask = async (req: Request, res: Response, next: NextFunction) => {
    const userId = (req.user as any).userId;
    const { planning_id, task_type, task_date } = req.body;

    try {
        // Confirm planning belongs to this user
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

// Get calendar tasks for logged-in farmer grouped by date
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

// Get tasks by planning ID for the logged-in farmer
export const getTasksByPlanningId = async (req: Request, res: Response, next: NextFunction) => {
    const userId = (req.user as any).userId;
    const { planning_id } = req.params;

    try {
        // Verify the planning belongs to the user
        const planningCheck = await pool.query(
            `SELECT id FROM crop_planning WHERE id = $1 AND user_id = $2`,
            [planning_id, userId]
        );

        if (planningCheck.rowCount === 0) {
            return res.status(404).json({
                status: "fail",
                message: "Planning not found or unauthorized"
            });
        }

        // Get tasks for this planning
        const result = await pool.query(
            `SELECT t.*, c.name AS crop_name
             FROM crop_tasks t
             JOIN crop_planning cp ON t.planning_id = cp.id
             JOIN crop_library c ON cp.crop_id = c.id
             WHERE t.planning_id = $1 AND cp.user_id = $2
             ORDER BY t.task_date`,
            [planning_id, userId]
        );

        res.json({
            status: "success",
            data: result.rows
        });
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
        // Verify the task belongs to the user
        const taskCheck = await pool.query(
            `SELECT t.id 
             FROM crop_tasks t
             JOIN crop_planning cp ON t.planning_id = cp.id
             WHERE t.id = $1 AND cp.user_id = $2`,
            [task_id, userId]
        );

        if (taskCheck.rowCount === 0) {
            return res.status(404).json({
                status: "fail",
                message: "Task not found or unauthorized"
            });
        }

        // Update the task status (remove updated_at reference)
        const result = await pool.query(
            `UPDATE crop_tasks 
             SET status = $1
             WHERE id = $2 
             RETURNING *`,
            [status, task_id]
        );

        res.json({
            status: "success",
            message: "Task status updated successfully",
            data: result.rows[0]
        });
    } catch (error) {
        next(error);
    }
};

// Delete a task
export const deleteTask = async (req: Request, res: Response, next: NextFunction) => {
    const userId = (req.user as any).userId;
    const { task_id } = req.params;

    try {
        // Verify the task belongs to the user
        const taskCheck = await pool.query(
            `SELECT t.id 
             FROM crop_tasks t
             JOIN crop_planning cp ON t.planning_id = cp.id
             WHERE t.id = $1 AND cp.user_id = $2`,
            [task_id, userId]
        );

        if (taskCheck.rowCount === 0) {
            return res.status(404).json({
                status: "fail",
                message: "Task not found or unauthorized"
            });
        }

        // Delete the task
        await pool.query(
            `DELETE FROM crop_tasks WHERE id = $1`,
            [task_id]
        );

        res.json({
            status: "success",
            message: "Task deleted successfully"
        });
    } catch (error) {
        next(error);
    }
};