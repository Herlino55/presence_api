// lib/models/student_attendance_history_model.dart
class StudentAttendanceHistory {
  final int courseId;
  final String courseName;
  final String attendanceDate; // Renommé pour correspondre à la fonction PostgreSQL
  final String? startTime; // Heure de début de présence (peut être null si absent ou non enregistré)
  final String? endTime; // Heure de fin de présence (peut être null si absent ou non enregistré)
  final String status; // "Présent", "Absent", "En cours"

  StudentAttendanceHistory({
    required this.courseId,
    required this.courseName,
    required this.attendanceDate, // Renommé ici aussi
    this.startTime,
    this.endTime,
    required this.status,
  });

  factory StudentAttendanceHistory.fromJson(Map<String, dynamic> json) {
    return StudentAttendanceHistory(
      courseId: json['course_id'],
      courseName: json['title'],
      attendanceDate: json['attendance_date'], // Assurez-vous que le nom de la clé correspond à l'API
      startTime: json['start_time'],
      endTime: json['end_time'],
      status: json['status'],
    );
  }
}
