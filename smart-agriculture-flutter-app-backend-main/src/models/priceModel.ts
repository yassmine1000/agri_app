import pool from "../config/database";

export interface PlantPrice {
    id: number;
    plant_name: string;
    category: string;
    price: number;
    unit: string;
    date: Date;
    created_at?: Date;
}

export const getTodayPricesService = async (): Promise<PlantPrice[]> => {
    const result = await pool.query<PlantPrice>(
        `SELECT * FROM plant_prices 
         WHERE date = CURRENT_DATE 
         ORDER BY category, plant_name`
    );
    return result.rows;
};

export const getAllPricesService = async (): Promise<PlantPrice[]> => {
    const result = await pool.query<PlantPrice>(
        `SELECT * FROM plant_prices ORDER BY date DESC, category, plant_name`
    );
    return result.rows;
};

export const createPriceService = async (
    plant_name: string,
    category: string,
    price: number,
    unit: string
): Promise<PlantPrice> => {
    const result = await pool.query<PlantPrice>(
        `INSERT INTO plant_prices (plant_name, category, price, unit, date)
         VALUES ($1, $2, $3, $4, CURRENT_DATE)
         RETURNING *`,
        [plant_name, category, price, unit]
    );
    return result.rows[0];
};

export const deletePriceService = async (id: number): Promise<void> => {
    await pool.query(`DELETE FROM plant_prices WHERE id = $1`, [id]);
};