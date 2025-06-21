const db = require('../config/db');


exports.startpresence = async (student_id, courses_id) => {
    try {
        const result = await db.query(
            'INSERT INTO presences (student_id,course_id,start_time) VALUES ($1, $2,  NOW()) RETURNING *',
            [student_id,courses_id]
        );
        return result.rows[0];
    } catch (error) {
        return 'Erreur lors de la création de la présence:', error;
    }
}


exports.endpresence = async (student_id, courses_id) => {
    try {
        const result = await db.query(
            `UPDATE presences
            SET end_time = NOW()
            WHERE student_id = $1 AND course_id = $2 AND end_time IS NULL
            RETURNING *`,
            [student_id, courses_id]
        );
        return result.rows[0];
    } catch (error) {
        console.error('Erreur lors de la mise à jour de la présence:', error);
        throw error;
    }
}


exports.getpresenceByStudent = async (student_id) => {
    try {
        const result = await db.query('SELECT * FROM presences student_id where id = $1', [student_id]);
        return result.rows[0];
    } catch (error) {
        return'Erreur lors de la récupération de la présence:', error;
    }
};

exports.getPresenceByStudentAndDateEnd = async (student_id, course_id) => {
  try {
    const result = await db.query(
      `SELECT * FROM presences
       WHERE student_id = $1
         AND course_id = $2
         AND DATE(end_time) = CURRENT_DATE`,
      [student_id, course_id]
    );

    return result.rows.length > 0 ? result.rows[0] : null;
  } catch (error) {
    console.error('Erreur lors de la vérification de la présence :', error);
    throw error;
  }
};

exports.getPresenceByStudentAndDateStart = async (student_id, course_id) => {
  try {
    const result = await db.query(
      `SELECT * FROM presences
       WHERE student_id = $1
         AND course_id = $2
         AND DATE(start_time) = CURRENT_DATE`,
      [student_id, course_id]
    );

    return result.rows.length > 0 ? result.rows[0] : null;
  } catch (error) {
    console.error('Erreur lors de la vérification de la présence :', error);
    throw error;
  }
};

exports.getStudentPresentByCoursEtDate = async (cours_id, date) => {

  try {
    const result = await db.query(
      'SELECT * FROM get_student_attendanceTest($1, $2)',
      [cours_id, date]
    );
    return result.rows;
  } catch (error) {
    console.error('Erreur lors de la récupération de la présence des étudiants :', error);
    throw error;
  }

}

exports.getStudentPresentByCoursEtDateImg = async (cours_id, date) => {

  try {
    const result = await db.query(
      'SELECT * FROM getstudentpresentbycoursetdateimg($1, $2)',
      [cours_id, date]
    );
    return result.rows;
  } catch (error) {
    console.error('Erreur lors de la récupération de la présence des étudiants :', error);
    throw error;
  }

}

exports.getStudentAttendanceHistory = async (studentId) => {
    try {
        const result = await db.query(
            'SELECT * FROM get_student_attendance_history($1)',
            [studentId]
        );
        return result.rows;
    } catch (error) {
        console.error('Erreur lors de la récupération de l\'historique de présence de l\'étudiant :', error);
        throw error;
    }
};


//   CREATE OR REPLACE FUNCTION getStudentPresentByCoursEtDateImg(course_id_input INT, date_input DATE)
// RETURNS TABLE (
//     nom TEXT,
//     statut TEXT
// ) AS $$
// BEGIN
//     RETURN QUERY
//     SELECT
//         s.nom,
//         CASE
//             WHEN p.end_time IS NOT NULL THEN 'Présent'
//             ELSE 'Absent'
//         END AS statut
//     FROM students s
//     LEFT JOIN presence p
//         ON s.id = p.student_id
//         AND p.course_id = course_id_input
//         AND p.date = date_input;
// END;
// $$ LANGUAGE plpgsql;


/*

CREATE OR REPLACE FUNCTION get_student_attendance_history(student_id_input INT)
RETURNS TABLE (
    course_id INT,
    title TEXT,
    attendance_date DATE,
    start_time TIME,
    end_time TIME,
    status TEXT
) AS $$
BEGIN
    RETURN QUERY
    SELECT
        p.course_id,
        c.title::TEXT AS title,
        p.start_time::date AS attendance_date, -- Extraction de la date à partir de start_time
		p.start_time::time AS start_time, -- cast explicite en TIME
        p.end_time::time AS end_time,          -- Extraction de l'heure à partir de end_time
        CASE
            WHEN p.start_time IS NOT NULL AND p.end_time IS NOT NULL THEN 'Présent'
            WHEN p.start_time IS NOT NULL AND p.end_time IS NULL THEN 'En cours'
            ELSE 'Absent' -- Ce cas pourrait ne pas être atteint si on ne sélectionne que les enregistrements de présence
        END AS status
    FROM presences p
    JOIN cours c ON p.course_id = c.id
    WHERE p.student_id = student_id_input
    ORDER BY p.start_time::date DESC, p.start_time DESC; -- Ordonner par date et heure de début
END;
$$ LANGUAGE plpgsql;
*/
