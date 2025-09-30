import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../core/app_constants.dart';
import '../../core/app_styles.dart';
import '../QRcode/QRcodeScannerScreen.dart';
import '../acceuil.dart';
import 'Historique_student.dart'; // Pour revenir à l'écran d'accès après déconnexion

class StudentHomePage extends StatelessWidget {
  final String userName;
  final String? userImageUrl; // URL de l'image de profil (peut être null)

  const StudentHomePage({
    super.key,
    required this.userName,
    this.userImageUrl,
  });

  // Fonction pour gérer la déconnexion
  Future<void> _logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Supprime le token stocké
    await prefs.remove('userName');
    await prefs.remove('userImageUrl');
    await prefs.remove('userRole'); // Supprimer aussi le rôle
    // Naviguer vers l'écran d'accès et supprimer toutes les routes précédentes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AccessScreen()),
          (Route<dynamic> route) => false,
    );
  }
  String _getInitial() {
    if (userName.isNotEmpty) {
      final String nom = userName.split('')[0];
      return nom[0].toUpperCase();
    }
    return '?';
  }

  @override
  Widget build(BuildContext context) {
    final String? fullImageUrl = (userImageUrl != null && userImageUrl!.isNotEmpty)
        ? '${AppConstants.baseUrl}/${userImageUrl!}'
        : null;

    return Scaffold(
      appBar: AppBar(
        title: Text('', style: const TextStyle(color: Colors.white, fontSize: 15)), // Afficher le nom
        backgroundColor: AppStyles.primaryColor,
        actions: [
          // Affichage de la photo de profil ou de l'initiale

          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Déconnexion',
            onPressed: () => _logout(context),
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundColor: Colors.white,
              backgroundImage: fullImageUrl != null
                  ? NetworkImage(fullImageUrl) as ImageProvider<Object>?
                  : null,
              child: fullImageUrl == null
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
            Text(
              'Bienvenue \n $userName!',
              style: AppStyles.titleStyle,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            // Bouton pour scanner un QR Code
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const QrCodeScannerScreen()),
                );
              },
              style: AppStyles.primaryButtonStyle(),
              icon: const Icon(Icons.qr_code_scanner),
              label: const Text('Scanner un QR Code'),
            ),
            const SizedBox(height: 20),
            // Nouveau bouton pour voir l'historique de présence
            ElevatedButton.icon(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const StudentAttendanceHistoryScreen()),
                );
              },
              style: AppStyles.primaryButtonStyle(),
              icon: const Icon(Icons.history),
              label: const Text('Mon Historique de Présence'),
            ),
            const SizedBox(height: 20),
            Text(
              'Contenu de la page d\'accueil de l\'étudiant ici.',
              style: AppStyles.subtitleStyle,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
