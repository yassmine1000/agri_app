import pool from "../config/database";

export interface PlantPrice {
    id: number;
    plant_name: string;
    category: string;
    price: number;
    unit: string;
    created_at?: Date;
    updated_at?: Date;
}

export const getAllPricesService = async (): Promise<PlantPrice[]> => {
    const result = await pool.query<PlantPrice>(
        `SELECT * FROM plant_prices ORDER BY category, plant_name`
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
        `INSERT INTO plant_prices (plant_name, category, price, unit, created_at, updated_at)
         VALUES ($1, $2, $3, $4, NOW(), NOW())
         RETURNING *`,
        [plant_name, category, price, unit]
    );
    return result.rows[0];
};

export const updatePriceService = async (id: number, price: number): Promise<PlantPrice> => {
    const result = await pool.query<PlantPrice>(
        `UPDATE plant_prices 
         SET price = $1, updated_at = NOW()
         WHERE id = $2 
         RETURNING *`,
        [price, id]
    );
    if (result.rows.length === 0) throw new Error("Price not found");
    return result.rows[0];
};

export const deletePriceService = async (id: number): Promise<void> => {
    await pool.query(`DELETE FROM plant_prices WHERE id = $1`, [id]);
};