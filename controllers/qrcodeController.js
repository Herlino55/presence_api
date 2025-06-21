const express = require('express');
const { generateQRCode } = require('../utils/qrcode');
const coursModel = require('../models/courseModel');
const teacherModel = require('../models/teacherModel')

exports.getQRcode = async (req, res) => {
   const { courseId, type } = req.params;
   const teacher_id = req.user.id;

   if (!courseId || isNaN(courseId)) {
    return res.status(400).json({ error: 'ID de cours invalide.' });
   }
   const appartenir = await coursModel.CoursAppartientAteacher(courseId, teacher_id);
   const cours = await coursModel.getCoursesByid(courseId);
   const teacher = await teacherModel.getTeacherById(teacher_id);
   if (!appartenir) {
    return res.status(403).json({ error: 'Accès interdit. Ce cours ne vous appartient pas.' });
   }

   if(req.user.role !== 'teacher') {
    return res.status(403).json({ error: 'Accès interdit. Seul un enseignant peut générer un QR code.' });  
   }

  if (!['start', 'end'].includes(type)) {
    return res.status(400).json({ error: 'Type invalide. Utilisez start ou end.' });
  }
 console.log(cours.title);
 console.log(teacher.name);
  try {
    const qrData = {
      teacher_id,
      courseId,
      name : teacher.name,
      cours: cours.title,
      type,
      date: new Date().toISOString().split('T')[0] // Format YYYY-MM-DD
    };

    const qr = await generateQRCode(qrData);
    res.json({ teacher: req.user.name, qr }); // image base64 à afficher côté client
  } catch (err) {
    res.status(500).json({ error: 'Erreur génération QR code' });
  }
}