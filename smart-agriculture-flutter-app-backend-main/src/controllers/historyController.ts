import { Request, Response, NextFunction } from "express";
import {
    saveDetectionService,
    getHistoryService,
    deleteHistoryService,
    deleteOneHistoryService,
} from "../models/historyModel";

export const saveDetection = async (req: Request, res: Response, next: NextFunction) => {
    const {
        disease, confidence, advice,
        advice_en, advice_fr, advice_ar,
        plant_name_en, plant_name_fr, plant_name_ar,
        disease_label_en, disease_label_fr, disease_label_ar,
    } = req.body;
    const user_id = (req.user as any).userId;

    if (!disease || confidence === undefined || !advice) {
        return res.status(400).json({ status: 400, message: "Missing fields" });
    }

    try {
        const record = await saveDetectionService(
            user_id, disease, confidence, advice,
            advice_en    ?? advice,
            advice_fr    ?? advice,
            advice_ar    ?? advice,
            plant_name_en    ?? null,
            plant_name_fr    ?? null,
            plant_name_ar    ?? null,
            disease_label_en ?? null,
            disease_label_fr ?? null,
            disease_label_ar ?? null,
        );
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

// Delete ALL history for a user
export const deleteHistory = async (req: Request, res: Response, next: NextFunction) => {
    const user_id = (req.user as any).userId;
    try {
        await deleteHistoryService(user_id);
        res.status(200).json({ status: 200, message: "History cleared" });
    } catch (error) {
        next(error);
    }
};

// Delete a SINGLE history entry by id
export const deleteOneHistory = async (req: Request, res: Response, next: NextFunction) => {
    const user_id = (req.user as any).userId;
    const id = Number(req.params.id);

    if (isNaN(id)) {
        return res.status(400).json({ status: 400, message: "Invalid id" });
    }

    try {
        const deleted = await deleteOneHistoryService(id, user_id);
        if (!deleted) {
            return res.status(404).json({ status: 404, message: "Not found" });
        }
        res.status(200).json({ status: 200, message: "Deleted" });
    } catch (error) {
        next(error);
    }
};