const jwt = require('jsonwebtoken');

module.exports = (req, res, next) => {
  // Récupère le token depuis les headers
  const authHeader = req.headers.authorization;

  if (!authHeader || !authHeader.startsWith('Bearer ')) { 
    return res.status(401).json({ error: 'Accès non autorisé,Veuillez-vous connecter' });
    // return res.status(401).json({ error: 'Accès non autorisé, token manquant' });
  }

  const token = authHeader.split(' ')[1];

  try {
    // Vérifie le token
    const decoded = jwt.verify(token, process.env.JWT_SECRET);

    // Stocke les infos dans la requête pour les utiliser dans la route
    req.user = decoded;

    next(); // Passe à la suite (la route protégée) 
  } catch (err) {
    return res.status(403).json({ error: 'Token invalide ou expiré' });
  }
};
