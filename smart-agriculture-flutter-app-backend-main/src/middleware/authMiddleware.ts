import { Request, Response, NextFunction } from "express";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";

dotenv.config();

export interface JwtPayload {
    userId: number;
    role: "farmer" | "customer" | "admin";
}

declare global {
    namespace Express {
        interface Request {
            user?: JwtPayload;
        }
    }
}

export const authMiddleware = (req: Request, res: Response, next: NextFunction) => {
    const header = req.headers.authorization;
    if (!header) return res.status(401).json({ status: 401, message: "Missing token" });

    const token = header.split(" ")[1];
    try {
        const decoded = jwt.verify(token, process.env.JWT_SECRET || "secret123") as JwtPayload;
        req.user = decoded;
        next();
    } catch {
        return res.status(401).json({ status: 401, message: "Invalid token" });
    }
};

export const farmerOnly = (req: Request, res: Response, next: NextFunction) => {
    if (req.user?.role !== "farmer") {
        return res.status(403).json({ message: "Farmer access only" });
    }
    next();
};

export const adminOnly = (req: Request, res: Response, next: NextFunction) => {
  if (req.user?.role !== "admin") {
      return res.status(403).json({ message: "Accès réservé à l'administrateur" });
  }
  next();
};