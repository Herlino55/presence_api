// lib/models/teacher_for_dropdown_model.dart
class TeacherForDropdown {
  final int id;
  final String name; // Utile pour l'affichage ou le débogage

  TeacherForDropdown({required this.id, required this.name});

  factory TeacherForDropdown.fromJson(Map<String, dynamic> json) {
    return TeacherForDropdown(
      id: json['id'],
      name: json['name'],// Assurez-vous que votre API renvoie l'email
    );
  }
}
