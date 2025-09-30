const b = require('../config/db');

exports.InsertAdmin = async (email,password) =>{
    try{
        const result = await b.query(
            'INSERT INTO admins (email, password) VALUES ($1, $2) RETURNING *',
            [email, password]
        );
        return result.rows[0];
    } catch (error) {
        console.error('Erreur lors de l\'insertion de l\'admin:', error);
        throw error; // Propager l'erreur pour la gestion ultérieure
    }
}

exports.getAdminByEmail = async (email) => {
    try {
        const result = await b.query('SELECT * FROM admins WHERE email = $1', [email]);
        return result.rows[0];
    } catch (error) {
        console.error('Erreur lors de la récupération de l\'admin par email:', error);
        throw error; // Propager l'erreur pour la gestion ultérieure
    }
}