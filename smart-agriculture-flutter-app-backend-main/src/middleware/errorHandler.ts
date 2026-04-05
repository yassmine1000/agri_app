import { Request, Response, NextFunction } from "express";

const errorHandling = (err: any, req: Request, res: Response, next: NextFunction) => {
    console.error(err.stack);
    res.status(500).json({
        status: 500,
        message: "Something went wrong",
        error: err.message,
    });
};

export default errorHandling;
