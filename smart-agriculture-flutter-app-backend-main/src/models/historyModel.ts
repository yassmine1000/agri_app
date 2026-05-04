import pool from "../config/database";

export interface DetectionHistory {
    id: number;
    user_id: number;
    disease: string;
    confidence: number;
    advice: string;
    advice_en: string;
    advice_fr: string;
    advice_ar: string;
    plant_name_en: string | null;
    plant_name_fr: string | null;
    plant_name_ar: string | null;
    disease_label_en: string | null;
    disease_label_fr: string | null;
    disease_label_ar: string | null;
    detected_at: Date;
}

export const saveDetectionService = async (
    user_id: number,
    disease: string,
    confidence: number,
    advice: string,
    advice_en: string,
    advice_fr: string,
    advice_ar: string,
    plant_name_en: string | null,
    plant_name_fr: string | null,
    plant_name_ar: string | null,
    disease_label_en: string | null,
    disease_label_fr: string | null,
    disease_label_ar: string | null,
): Promise<DetectionHistory> => {
    const result = await pool.query<DetectionHistory>(
        `INSERT INTO detection_history
            (user_id, disease, confidence, advice,
             advice_en, advice_fr, advice_ar,
             plant_name_en, plant_name_fr, plant_name_ar,
             disease_label_en, disease_label_fr, disease_label_ar)
         VALUES ($1,$2,$3,$4,$5,$6,$7,$8,$9,$10,$11,$12,$13)
         RETURNING *`,
        [user_id, disease, confidence, advice,
         advice_en, advice_fr, advice_ar,
         plant_name_en, plant_name_fr, plant_name_ar,
         disease_label_en, disease_label_fr, disease_label_ar]
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

// Delete ALL history for a user
export const deleteHistoryService = async (user_id: number): Promise<void> => {
    await pool.query(
        `DELETE FROM detection_history WHERE user_id = $1`,
        [user_id]
    );
};

// Delete a SINGLE history entry by id (must belong to the user)
export const deleteOneHistoryService = async (id: number, user_id: number): Promise<{ id: number } | null> => {
    const result = await pool.query(
        `DELETE FROM detection_history WHERE id = $1 AND user_id = $2 RETURNING id`,
        [id, user_id]
    );
    return result.rows[0] ?? null;
};