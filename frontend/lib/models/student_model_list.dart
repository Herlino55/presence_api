// lib/models/student_attendance_model.dart
class StudentAttendance {
  final int studentId;
  final String nom;
  final String prenom;
  final String? imageUrl; // Peut être null
  final String statut; // "Présent" ou "Absent"

  StudentAttendance({
    required this.studentId,
    required this.nom,
    required this.prenom,
    this.imageUrl,
    required this.statut,
  });

  factory StudentAttendance.fromJson(Map<String, dynamic> json) {
    return StudentAttendance(
      studentId: json['student_id'],
      nom: json['name'],
      prenom: json['prenom'],
      imageUrl: json['image_url'], // Assurez-vous que le nom de la clé correspond à l'API
      statut: json['statut'],
    );
  }
}
