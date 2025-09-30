const Course = require('../models/courseModel');

exports.createCourse = async (req, res) => {
  const { name,teacherId } = req.body;
  const adminId = req.user.id; // récupéré depuis le JWT

  if(!name) {
    return res.status(400).json({ error: 'Le nom du cours est requis.' });
  } 

  if(req.user.role !== 'admin') {
    return res.status(403).json({ error: 'Accès interdit. Seul un responsable peut créer un cours.' });
  }
  const course = await Course.createCourse(name, teacherId);
  res.status(201).json(course);
};

exports.getMyCourses = async (req, res) => {
  const teacherId = req.user.id;

  if(req.user.role !== 'teacher') {
    return res.status(403).json({ error: 'Accès interdit. Seul un enseignant peut recuperer un cours.' });
  }
  
  const courses = await Course.getCoursesByTeacher(teacherId);
  res.status(200).json(courses);
};


