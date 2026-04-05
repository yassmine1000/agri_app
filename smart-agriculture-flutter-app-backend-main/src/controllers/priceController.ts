import { Request, Response, NextFunction } from "express";
import {
    getTodayPricesService,
    getAllPricesService,
    createPriceService,
    deletePriceService,
} from "../models/priceModel";

// GET /api/prices — prix du jour
export const getTodayPrices = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const prices = await getTodayPricesService();
        res.status(200).json({ status: 200, message: "Prix du jour", data: prices });
    } catch (error) {
        next(error);
    }
};

// GET /api/prices/all — tous les prix
export const getAllPrices = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const prices = await getAllPricesService();
        res.status(200).json({ status: 200, message: "Tous les prix", data: prices });
    } catch (error) {
        next(error);
    }
};

// POST /api/prices — ajouter un prix (admin seulement)
export const createPrice = async (req: Request, res: Response, next: NextFunction) => {
    const { plant_name, category, price, unit } = req.body;

    if (!plant_name || !category || !price || !unit) {
        return res.status(400).json({ status: 400, message: "Tous les champs sont requis" });
    }

    try {
        const newPrice = await createPriceService(plant_name, category, parseFloat(price), unit);
        res.status(201).json({ status: 201, message: "Prix ajouté", data: newPrice });
    } catch (error) {
        next(error);
    }
};

// DELETE /api/prices/:id — supprimer un prix (admin seulement)
export const deletePrice = async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    try {
        await deletePriceService(parseInt(id));
        res.status(200).json({ status: 200, message: "Prix supprimé" });
    } catch (error) {
        next(error);
    }
};