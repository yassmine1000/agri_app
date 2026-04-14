import pool from "../config/database";

export interface DetectionHistory {
    id: number;
    user_id: number;
    disease: string;
    confidence: number;
    advice: string;
    detected_at: Date;
}

export const saveDetectionService = async (
    user_id: number,
    disease: string,
    confidence: number,
    advice: string
): Promise<DetectionHistory> => {
    const result = await pool.query<DetectionHistory>(
        `INSERT INTO detection_history (user_id, disease, confidence, advice)
         VALUES ($1, $2, $3, $4)
         RETURNING *`,
        [user_id, disease, confidence, advice]
    );
    return result.rows[0];
};

export const getHistoryService = async (user_id: number): Promise<DetectionHistory[]> => {
    const result = await pool.query<DetectionHistory>(
        `SELECT * FROM detection_history 
         WHERE user_id = $1 
         ORDER BY detected_at DESC 
         LIMIT 50`,
        [user_id]
    );
    return result.rows;
};

export const deleteHistoryService = async (user_id: number): Promise<void> => {
    await pool.query(
        `DELETE FROM detection_history WHERE user_id = $1`,
        [user_id]
    );
};