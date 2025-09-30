const db = require('../config/db');

exports.createCourse = async (name, teacherId) => {
  const result = await db.query(
    'INSERT INTO cours (title, teacher_id) VALUES ($1, $2) RETURNING *',
    [name, teacherId]
  );
  return result.rows[0];
};

exports.getCoursesByTeacher = async (teacherId) => {
  const result = await db.query(
    'SELECT * FROM cours WHERE teacher_id = $1',
    [teacherId]
  );
  return result.rows;
};

exports.getCoursesByid = async (id) => {
  const result = await db.query(
    'SELECT * FROM cours WHERE id = $1',
    [id]
  );
  return result.rows[0];
};

exports.CoursAppartientAteacher= async (courseId, teacherId) => {
  const result = await db.query(
    'SELECT * FROM cours WHERE id = $1 AND teacher_id = $2',
    [courseId, teacherId]
  );
  return result.rows.length > 0; // Retourne true si le cours appartient à l'enseignant
};