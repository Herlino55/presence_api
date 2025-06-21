const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const adminModel = require('../models/AdminModel');


exports.register = async (req, res) => {
    const { email, password } = req.body;
    
    if (!email || !password) {
        return res.status(400).json({ error: 'Email et mot de passe requis' });
    }
    
    try {
        // Vérifier si l'admin existe déjà
        const userCheck = await adminModel.getAdminByEmail(email);
        if (userCheck) {
        return res.status(400).json({ error: 'Email déjà utilisé' });
        }
    
        // Hasher le mot de passe
        const hashedPassword = await bcrypt.hash(password, 10);
    
        // Enregistrer l'admin
        const newAdmin = await adminModel.InsertAdmin(email, hashedPassword);
    
        res.status(201).json({ message: 'Admin créé avec succès', admin: newAdmin });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Erreur serveur' });
    }

};


exports.login = async (req, res) => {
    const { email, password } = req.body;
    
    if (!email || !password) {
        return res.status(400).json({ error: 'Email et mot de passe requis' });
    }
    
    try {
        // Trouver l'admin
        const user = await adminModel.getAdminByEmail(email);
    
        if (!user) return res.status(404).json({ error: 'Admin non trouvé' });
    
        // Vérifier le mot de passe
        const validPassword = await bcrypt.compare(password, user.password);
        if (!validPassword) return res.status(401).json({ error: 'Mot de passe incorrect' });
    
        // Générer le token
        const token = jwt.sign(
            { id: user.id, email: user.email, role: 'admin' },
            process.env.JWT_SECRET,
            { expiresIn: '02h' }
        );
        
        res.json({ role: `${user.email}`, token: `${token}` });
    } catch (err) {
        console.error(err);
        res.status(500).json({ error: 'Erreur serveur' });
    }
};



exports.logout = async (req,res) =>
{
    res.status(200).json({ message: 'Déconnexion réussie' });
};