import { Request, Response, NextFunction } from "express";
import {
    getAllPricesService,
    createPriceService,
    updatePriceService,
    deletePriceService,
} from "../models/priceModel";

export const getPrices = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const prices = await getAllPricesService();
        res.status(200).json({ status: 200, message: "Prices", data: prices });
    } catch (error) { next(error); }
};

export const createPrice = async (req: Request, res: Response, next: NextFunction) => {
  const { plant_name, category, price, unit, crop_id } = req.body;

  if (!plant_name || !category || !price || !unit || !crop_id) {
      return res.status(400).json({ status: 400, message: "All fields are required" });
  }

  const cropId = Number(crop_id);
  if (isNaN(cropId)) {
      return res.status(400).json({ status: 400, message: "Invalid crop_id" });
  }

  try {
    const newPrice = await createPriceService(
      plant_name,
      category,
      parseFloat(Array.isArray(price) ? price[0] : String(price)),
      unit,
      cropId
  );
      res.status(201).json({ status: 201, message: "Price added", data: newPrice });
  } catch (error) { next(error); }
};

export const updatePrice = async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    const { price } = req.body;
    const priceStr = Array.isArray(price) ? price[0] : String(price);
    if (!priceStr || isNaN(parseFloat(priceStr))) {
        return res.status(400).json({ status: 400, message: "Valid price is required" });
    }
    try {
        const updated = await updatePriceService(parseInt(id as string), parseFloat(priceStr));
        res.status(200).json({ status: 200, message: "Price updated", data: updated });
    } catch (error) { next(error); }
};

export const deletePrice = async (req: Request, res: Response, next: NextFunction) => {
    const { id } = req.params;
    try {
        await deletePriceService(parseInt(id as string));
        res.status(200).json({ status: 200, message: "Price deleted" });
    } catch (error) { next(error); }
};
