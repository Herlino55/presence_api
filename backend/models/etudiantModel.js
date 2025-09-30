const db = require('../config/db');

exports.InsertEtudiant = async (matricule, nom, prenom, birthday, password, classe, image_url) =>{
    try{
        const result = await db.query(
            'INSERT INTO students (matricule, name, prenom, date_naissance, password, classe, image_url) VALUES ($1, $2, $3, $4, $5, $6, $7) RETURNING *',
            [matricule, nom, prenom, birthday, password, classe, image_url]
        );
        return result.rows[0];
    } catch (error) {
        console.error('Erreur lors de l\'insertion de l\'étudiant:', error);
        throw error; // Propager l'erreur pour la gestion ultérieure
  }
};

exports.getAllEtudiant = async() =>{
    try{
        const result = await db.query('SELECT * FROM students');
        return result.rows;

    }catch(error) {
        console.error('Erreur lors de la récupération des étudiants:', error);
        throw error; // Propager l'erreur pour la gestion ultérieure
    }
}

exports.getEtudiantByMatricule = async (mat) => {
    try {
        const result = await db.query('SELECT * FROM students WHERE matricule = $1', [mat]);
        return result.rows[0];
    } catch (error) {
        console.error('Erreur lors de la récupération de l\'étudiant par ID:', error);
        throw error; // Propager l'erreur pour la gestion ultérieure
    }
}