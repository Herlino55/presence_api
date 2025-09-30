class User {
  final String matricule;
  final String nom;
  final String prenom;
  final String birthday;
  final String classe;
  final String? imageUrl;

  User({
    required this.matricule,
    required this.nom,
    required this.prenom,
    required this.birthday,
    required this.classe,
    this.imageUrl,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      matricule: json['matricule'],
      nom: json['nom'],
      prenom: json['prenom'],
      birthday: json['birthday'],
      classe: json['classe'],
      imageUrl: json['image_url'],
    );
  }
}