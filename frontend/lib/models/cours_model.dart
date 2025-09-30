class Course {
  final int id;
  final String name;
  final int teacherId; // L'ID de l'enseignant qui a créé le cours

  Course({
    required this.id,
    required this.name,
    required this.teacherId,
  });

  factory Course.fromJson(Map<String, dynamic> json) {
    return Course(
      id: json['id'],
      name: json['title'],
      teacherId: json['teacher_id'],
    );
  }
}