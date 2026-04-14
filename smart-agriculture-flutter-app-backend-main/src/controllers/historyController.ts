import { Request, Response, NextFunction } from "express";
import {
    saveDetectionService,
    getHistoryService,
    deleteHistoryService,
} from "../models/historyModel";

export const saveDetection = async (req: Request, res: Response, next: NextFunction) => {
    const { disease, confidence, advice } = req.body;
    const user_id = (req.user as any).userId;

    if (!disease || confidence === undefined || !advice) {
        return res.status(400).json({ status: 400, message: "Missing fields" });
    }

    try {
        const record = await saveDetectionService(user_id, disease, confidence, advice);
        res.status(201).json({ status: 201, message: "Saved", data: record });
    } catch (error) {
        next(error);
    }
};

export const getHistory = async (req: Request, res: Response, next: NextFunction) => {
    const user_id = (req.user as any).userId;
    try {
        const history = await getHistoryService(user_id);
        res.status(200).json({ status: 200, message: "History", data: history });
    } catch (error) {
        next(error);
    }
};

export const deleteHistory = async (req: Request, res: Response, next: NextFunction) => {
    const user_id = (req.user as any).userId;
    try {
        await deleteHistoryService(user_id);
        res.status(200).json({ status: 200, message: "History cleared" });
    } catch (error) {
        next(error);
    }
};