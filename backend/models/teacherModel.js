const db = require('../config/db');


exports.InsertTeacher = async (email, password, name, image_url) => {
    try {
        const result = await db.query(
            'INSERT INTO users (email, password, name, image_url) VALUES ($1, $2, $3, $4) RETURNING *',
            [email, password, name, image_url]
        );
        return result.rows[0];
    } catch (error) {
        console.error('Erreur lors de l\'insertion du professeur:', error);
        throw error; // Propager l'erreur pour la gestion ultérieure
    }
};

exports.getAllTeachers = async () => {
    try {
        const result = await db.query('SELECT * FROM users');
        return result.rows;
    } catch (error) {
        console.error('Erreur lors de la récupération des professeurs:', error);
        throw error; // Propager l'erreur pour la gestion ultérieure
    }
};

exports.getTeacherByEmail = async (email) => {
    try {
        const result = await db.query('SELECT * FROM users WHERE email = $1', [email]);
        return result.rows[0];
    } catch (error) {
        console.error('Erreur lors de la récupération du professeur par ID:', error);
        throw error; // Propager l'erreur pour la gestion ultérieure
    }
};

exports.getTeacherById = async (id) => {
    try {
        const result = await db.query('SELECT * FROM users WHERE id = $1', [id]);
        return result.rows[0];
    } catch (error) {
        console.error('Erreur lors de la récupération du professeur par ID:', error);
        throw error; // Propager l'erreur pour la gestion ultérieure
    }
};

