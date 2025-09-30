const bcrypt = require('bcrypt');
const jwt = require('jsonwebtoken');
const etudiantModel = require('../models/etudiantModel');

exports.register = async (req, res) => {
  const { matricule, nom, prenom, birthday, password, classe } = req.body;
  const image_url = req.file ? req.file.path : null; // Chemin de l'image si uploadée
  const user = req.user.role;

  if(user !=="admin"){
     return res.status(400).json({ error: 'seule les admins ont acces a cette page' });
  }

  if (!matricule) {
    return res.status(400).json({ error: 'Matricule requis' });
  }
  if (!nom) {
    return res.status(400).json({ error: 'nom requis' });
  }
  if (!prenom) {
    return res.status(400).json({ error: 'prenom requis' });
  }
  if (!birthday) {
    return res.status(400).json({ error: 'date de naissance requis' });
  }
  if (!password) {
    return res.status(400).json({ error: 'mot de passe requis' });
  }
    if (!classe) {
    return res.status(400).json({ error: 'classe requis' });
  }

  if (image_url && !image_url.match(/\.(jpg|jpeg|png|gif)$/)) {
    return res.status(400).json({ error: 'Format d\'image non supporté' });
  }

  try {
    // Vérifier si l'étudiant existe déjà
    const userCheck = await etudiantModel.getEtudiantByMatricule(matricule);
    if (userCheck) {
      return res.status(400).json({ error: 'Matricule déjà utilisé' });
    }

    // Hasher le mot de passe
    const hashedPassword = await bcrypt.hash(password, 10);

    // Enregistrer l'étudiant
    const newStudent = etudiantModel.InsertEtudiant(
      matricule,
      nom,
      prenom,
      birthday,
      hashedPassword, // Utiliser le mot de passe haché
      classe,
      image_url // Chemin de l'image
    );

    return res.status(201).json({ message: 'Étudiant créé avec succès', student: newStudent });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Erreur serveur' });
  }
}

exports.login = async (req, res) => {
  const { matricule, password } = req.body;

  try {
    // Trouver l'étudiant
    const studentResult = await etudiantModel.getEtudiantByMatricule(matricule);
    const student = studentResult;

    if (!student) return res.status(404).json({ error: 'Étudiant non trouvé' });

    // Vérifier le mot de passe
    const validPassword = await bcrypt.compare(password, student.password);
    if (!validPassword) return res.status(401).json({ error: 'Mot de passe incorrect' });

    // Générer le token
    const token = jwt.sign(
      { id: student.id, matricule: student.matricule, nom: student.name, prenom: student.prenom,role: 'student', image_url: student.image_url, classe: student.classe, date_naissance: student.date_naissance },
      process.env.JWT_SECRET,
      { expiresIn: '02h' }
    );
    
    res.json({ nom: `${student.name}`, token: `${token}` });
  } catch (err) {
    console.error(err);
    res.status(500).json({ error: 'Erreur serveur' });
  }
}