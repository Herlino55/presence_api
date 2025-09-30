import 'package:flutter/material.dart';
import 'package:presence_qr/screens/dashboard/view_attendance_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_styles.dart';
import '../acceuil.dart';
import '../QRcode/qr_code_generator_screen.dart'; // Importez le nouvel écran
import '../Cours/Manage_cours_screen.dart'; // Importez le nouvel écran

class TeacherHomePage extends StatelessWidget {
  final String userName;
  final String? userImageUrl; // URL de l'image de profil (peut être null)

  const TeacherHomePage({
    super.key,
    required this.userName,
    this.userImageUrl,
  });

  // Fonction pour obtenir l'initiale du nom si aucune image n'est disponible
  String _getInitial() {
    if (userName.isNotEmpty) {
      return userName[0].toUpperCase();
    }
    return '?';
  }

  // Fonction pour gérer la déconnexion
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Supprime le token stocké
    await prefs.remove('userName');
    await prefs.remove('userImageUrl');
    await prefs.remove('userRole');
    // Naviguer vers l'écran d'accès et supprimer toutes les routes précédentes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AccessScreen()),
          (Route<dynamic> route) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Bonjour, $userName', style: const TextStyle(color: Colors.white)), // Afficher le nom
        backgroundColor: AppStyles.primaryColor,
        actions: [
          // Affichage de la photo de profil ou de l'initiale
          CircleAvatar(
            backgroundColor: Colors.white,
            backgroundImage: userImageUrl != null && userImageUrl!.isNotEmpty
                ? NetworkImage(userImageUrl!) as ImageProvider<Object>?
                : null,
            child: userImageUrl == null || userImageUrl!.isEmpty
                ? Text(
              _getInitial(),
              style: const TextStyle(
                color: AppStyles.primaryColor,
                fontWeight: FontWeight.bold,
              ),
            )
                : null,
          ),
          const SizedBox(width: 16),
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Déconnexion',
            onPressed: () => _logout(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                'Bienvenue dans votre espace enseignant !',
                style: AppStyles.titleStyle,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 30),
              // Bouton pour générer le QR Code
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const QrCodeGeneratorScreen()), // Pas besoin de passer initialCourseId
                  );
                },
                style: AppStyles.primaryButtonStyle(),
                icon: const Icon(Icons.qr_code_2),
                label: const Text('Générer un QR Code'),
              ),
              const SizedBox(height: 20),
              // Nouveau bouton pour gérer les cours
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ManageCoursesScreen()),
                  );
                },
                style: AppStyles.primaryButtonStyle(),
                icon: const Icon(Icons.library_books),
                label: const Text('Gérer mes cours'),
              ),
              const SizedBox(height: 20),
              // Nouveau bouton pour voir la présence
              ElevatedButton.icon(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const ViewAttendanceScreen()),
                  );
                },
                style: AppStyles.primaryButtonStyle(),
                icon: const Icon(Icons.checklist),
                label: const Text('Voir la Présence'),
              ),
              const SizedBox(height: 20),
              Text(
                'Contenu de la page d\'accueil de l\'enseignant ici.',
                style: AppStyles.subtitleStyle,
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
