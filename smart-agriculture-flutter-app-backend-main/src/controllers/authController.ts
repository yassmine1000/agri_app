import { Request, Response, NextFunction } from "express";
import bcrypt from "bcrypt";
import jwt from "jsonwebtoken";
import dotenv from "dotenv";
import {
    createUserService,
    getUserByUsernameService,
    getUserByIdService,
    UserRole,
    Gender,
} from "../models/authModel";

dotenv.config();

const handleResponse = (res: Response, status: number, message: string, data: any = null) => {
    res.status(status).json({ status, message, data });
};

export const registerUser = async (req: Request, res: Response, next: NextFunction) => {
  console.log("BODY REÇU:", req.body);
    const {
        username,
        password,
        role,
        name,
        address,
        phone_no,
        gender,
        dob,
        farm_name,
        farmer_registration_no,
        alt_contact_no,
    } = req.body as {
        username: string;
        password: string;
        role: UserRole;
        name: string;
        address: string;
        phone_no: string;
        gender: Gender;
        dob: string;
        farm_name?: string;
        farmer_registration_no?: string;
        alt_contact_no?: string;
    };

    try {
        const existingUser = await getUserByUsernameService(username);
        if (existingUser) return handleResponse(res, 400, "Username already registered");

        if (role === "farmer" && (!farm_name || !farmer_registration_no)) {
            return handleResponse(res, 400, "Farmer details required (farm_name and farmer_registration_no)");
        }

        const passwordHash = await bcrypt.hash(password, 10);

        const newUser = await createUserService({
            username,
            password: passwordHash,
            role,
            name,
            address,
            phone_no,
            gender,
            dob: new Date(dob),
            farm_name: farm_name || null,
            farmer_registration_no: farmer_registration_no || null,
            alt_contact_no: alt_contact_no || null,
        });

        handleResponse(res, 201, "User registered successfully", newUser);
    } catch (error) {
        next(error);
    }
};

export const loginUser = async (req: Request, res: Response, next: NextFunction) => {
    const { username, password } = req.body as { username: string; password: string };
    try {
        const user = await getUserByUsernameService(username);
        if (!user) return handleResponse(res, 401, "Invalid credentials");

        const match = await bcrypt.compare(password, user.password || "");
        if (!match) return handleResponse(res, 401, "Invalid credentials");

        const token = jwt.sign(
            { userId: user.id, role: user.role },
            process.env.JWT_SECRET || "secret123",
            { expiresIn: "7d" }
        );

        handleResponse(res, 200, "Login successful", {
            token,
            user: {
                id: user.id,
                username: user.username,
                role: user.role,
                name: user.name,
            },
        });
    } catch (err) {
        next(err);
    }
};

export const getCurrentUser = async (req: Request, res: Response, next: NextFunction) => {
    try {
        const user = await getUserByIdService((req.user as any).userId);
        if (!user) return handleResponse(res, 404, "User not found");
        handleResponse(res, 200, "User fetched successfully", user);
    } catch (err) {
        next(err);
    }
};
