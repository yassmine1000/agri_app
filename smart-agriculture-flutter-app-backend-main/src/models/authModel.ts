import pool from "../config/database";

export type UserRole = "farmer" | "customer" | "admin";
export type Gender = "male" | "female" | "other";

export interface User {
    id: number;
    username: string;
    password?: string;
    role: UserRole;
    name: string;
    address: string;
    phone_no: string;
    gender: Gender;
    dob: Date;
    farm_name?: string | null;
    farmer_registration_no?: string | null;
    alt_contact_no?: string | null;
    created_at?: Date;
    updated_at?: Date;
}

export const getUserByUsernameService = async (username: string): Promise<User | null> => {
    const result = await pool.query<User>("SELECT * FROM users WHERE username=$1", [username]);
    return result.rows[0] || null;
};

export const createUserService = async (user: Omit<User, "id" | "created_at" | "updated_at">): Promise<User> => {
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
        alt_contact_no
    } = user;

    const result = await pool.query<User>(
        `INSERT INTO users (
      username, password, role, name, address, phone_no, gender, dob,
      farm_name, farmer_registration_no, alt_contact_no
    ) VALUES (
      $1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11
    )
    RETURNING id, username, role, name, address, phone_no, gender, dob, farm_name, 
        farmer_registration_no, alt_contact_no, created_at, updated_at`,
        [
            username,
            password,
            role,
            name,
            address,
            phone_no,
            gender,
            dob,
            role === "farmer" ? farm_name : null,
            role === "farmer" ? farmer_registration_no : null,
            alt_contact_no || null
        ]
    );

    return result.rows[0];
};

export const getUserByIdService = async (id: number): Promise<User | null> => {
    const result = await pool.query<User>(
        `SELECT id, username, role, name, address, phone_no, gender, dob,
            farm_name, farmer_registration_no, alt_contact_no, created_at, updated_at
     FROM users WHERE id=$1`,
        [id]
    );
    return result.rows[0] || null;
};
