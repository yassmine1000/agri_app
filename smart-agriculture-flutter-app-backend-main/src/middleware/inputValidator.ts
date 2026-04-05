import { Request, Response, NextFunction } from "express";
import Joi from "joi";

const registerSchema = Joi.object({
    username: Joi.string().min(3).required(),
    password: Joi.string().min(6).required(),
    role: Joi.string().valid("farmer", "customer").required(),
    name: Joi.string().required(),
    address: Joi.string().required(),
    phone_no: Joi.string().required(),
    gender: Joi.string().valid("male", "female", "other").required(),
    dob: Joi.date().required(),
    farm_name: Joi.string().when("role", {
      is: "farmer",
      then: Joi.required(),
      otherwise: Joi.optional().allow(null, ""),
  }),
  farmer_registration_no: Joi.string().when("role", {
      is: "farmer",
      then: Joi.required(),
      otherwise: Joi.optional().allow(null, ""),
  }),
    alt_contact_no: Joi.string().optional().allow(null, ""),
});

const loginSchema = Joi.object({
    username: Joi.string().required(),
    password: Joi.string().min(6).required(),
});

export const validateRegister = (req: Request, res: Response, next: NextFunction) => {
  console.log("VALIDATOR BODY:", JSON.stringify(req.body)); // ← AJOUTE
  const { error } = registerSchema.validate(req.body);
  if (error) {
      console.log("JOI ERROR:", error.details[0].message); // ← AJOUTE
      return res.status(400).json({
          status: 400,
          message: error.details[0].message,
      });
  }
  next();
};

export const validateLogin = (req: Request, res: Response, next: NextFunction) => {
    const { error } = loginSchema.validate(req.body);
    if (error) {
        return res.status(400).json({
            status: 400,
            message: error.details[0].message,
        });
    }
    next();
};
