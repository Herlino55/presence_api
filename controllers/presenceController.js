const express = require('express');
const presenceModel = require('../models/presenceModel');

exports.start = async (req, res) => {
  const { courses_id } = req.body;
  const studentId = req.user.id;

  // Vérification du rôle
  if (req.user.role !== 'student') {
    return res.status(403).json({ error: 'Accès interdit. Seul un étudiant peut enregistrer sa présence.' });
  }

  try {
    // Vérifier si une présence existe déjà aujourd'hui
    const session = await presenceModel.getPresenceByStudentAndDateStart(studentId, courses_id);
    if (session) {
      return res.status(400).json({ error: "Présence a l'arrivee déjà enregistrée pour cette matière aujourd'hui" });
    }

    // Enregistrer la nouvelle présence
    const presence = await presenceModel.startpresence(studentId, courses_id);
    if (!presence) {
      return res.status(400).json({ error: 'Erreur lors de l\'enregistrement de la présence.' });
    }

    // Succès
    return res.status(200).json({ message: 'Présence début enregistrée', data: presence });

  } catch (err) {
    console.error('Erreur dans start():', err);
    return res.status(500).json({ error: 'Erreur interne du serveur.' });
  }
};

exports.end = async (req, res) => {
    const { courses_id } = req.body;
  const studentId = req.user.id;
  if(req.user.role !== 'student') {
    return res.status(403).json({ error: 'Accès interdit. Seul un étudiant peut enregistrer sa présence.' });
  }
  try {

    const session = await presenceModel.getPresenceByStudentAndDateEnd(studentId, courses_id);
    if (session) {
      return res.status(400).json({ error: "Présence déjà enregistrée pour cette matiere aujourd'hui" });
    }

    const presence = await presenceModel.endpresence(studentId, courses_id);
    if (!presence) {
       return res.status(400).json({ error: 'Aucune présence à mettre à jour ou déjà enregistrée.'});
    }else{
      return res.json({ message: 'Présence fin enregistrée', data: presence });
    }

  } catch (err) {
    return res.status(500).json({ error: 'Erreur enregistrement fin' });
  }
}

exports.getByStudent = async (req, res) => {
    const studentId = req.user.id;

  try {
    const presences = await presenceModel.getpresenceByStudent(studentId);
    res.json({ presences });
  } catch (err) {
    res.status(500).json({ error: 'Erreur récupération des présences' });
  }
}

exports.getPresenceParCoursEtDate = async (req,res) =>{
  const { courseId, date } = req.params;

  if (!courseId || !date) {
    return res.status(400).json({ message: 'courseId et date sont requis' });
  }

  try {
    const presence = await presenceModel.getStudentPresentByCoursEtDate(courseId, date);
    res.json(presence);
  } catch (error) {
    res.status(500).json({ message: 'Erreur interne du serveur' });
  }
}

exports.getPresenceParCoursEtDateImg = async (req,res) =>{
  const { courseId, date } = req.params;

  if (!courseId || !date) {
    return res.status(400).json({ message: 'courseId et date sont requis' });
  }

  try {
    const presence = await presenceModel.getStudentPresentByCoursEtDateImg(courseId, date);
    res.json(presence);
  } catch (error) {
    res.status(500).json({ message: 'Erreur interne du serveur' });
  }
}

exports.MesHistoriques = async (req,res) =>{
  
  if (req.user.role !== 'student') {
        return res.status(403).json({ error: 'Accès interdit. Seul un étudiant peut consulter son historique de présence.' });
    }

    const studentId = req.user.id; // L'ID de l'étudiant est extrait du token JWT par le middleware

    try {
        const history = await presenceModel.getStudentAttendanceHistory(studentId);
        res.status(200).json(history);
    } catch (error) {
        console.error('Erreur dans la route /myAttendance :', error);
        res.status(500).json({ error: 'Erreur interne du serveur lors de la récupération de l\'historique de présence.' });
    }
}