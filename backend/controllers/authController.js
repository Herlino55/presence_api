const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const pool = require('../config/db');
const teacherModel = require('../models/teacherModel');

// Inscription
exports.register = async (req, res) => {
  const { name, email, password} = req.body;
  const image_url = req.file ? req.file.path : null; 

  if (!name || !email || !password) {
    return res.status(400).json({ error: 'Nom, email et mot de passe requis' });
  }

  if(image_url && !image_url.match(/\.(jpg|jpeg|png|gif)$/)) {
    return res.status(400).json({ error: 'Format d\'image non supporté' });
  }

  try {
    // Vérifier si l'utilisateur existe déjà
    const userCheck = await teacherModel.getTeacherByEmail(email);
    if (userCheck > 0) {
      return res.status(400).json({ error: 'Email déjà utilisé' });
    }

    // Hasher le mot de passe
    const hashedPassword = await bcrypt.hash(password, 10);

    // Enregistrer l'utilisateur
    const newUser = await teacherModel.InsertTeacher(
      email,
      hashedPassword, // Utiliser le mot de passe haché
      name,
      image_url // Chemin de l'image
    );

    return res.status(201).json({ message: 'enseignant créé avec succès', user: newUser });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
};

// Connexion
exports.login = async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email et mot de passe requis' });
  }

  try {
    // Trouver l'utilisateur
    const userResult = await teacherModel.getTeacherByEmail(email);
  
    const user = userResult;

    if (!user) return res.status(404).json({ error: 'enseignant non trouvé' });

    // Vérifier le mot de passe
    const validPassword = await bcrypt.compare(password, user.password);
    if (!validPassword) return res.status(401).json({ error: 'Mot de passe incorrect' });

    // Générer le token
    const token = jwt.sign(
      { id: user.id, name: user.name, email: user.email, role: 'teacher', image_url: user.image_url },
      process.env.JWT_SECRET,
      { expiresIn: '02h' }
    );
    return res.json({ role: `${user.name}`, token: `${token}` });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
};

exports.AllTeacher = async (req,res) =>{
  try {
    const teachers = await teacherModel.getAllTeachers();
    const result = teachers.map(teacher => ({
      id: teacher.id,
      name: teacher.name
    }));
    return res.status(200).json(result);
  } catch (error) {
    console.error('Erreur lors de la récupération des professeurs:', error);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
}
