import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Cours/AdminManageCoursesScreen.dart';
import '../acceuil.dart';
import '../register/student_register.dart';
import '../register/teacher_register.dart';
import 'register_admin.dart';
// import 'login_admin.dart';

class AdminHomePage extends StatelessWidget {
  final String mail;

  const AdminHomePage({super.key, required this.mail});



  String getInitial() => mail.isNotEmpty ? mail[0].toUpperCase() : '?';
  Future<void> _logout(BuildContext context) async {
    // Supprimer le token (ou toute autre donnée d'authentification) de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('admin_token'); // Supprime le token stocké
    // Vous pouvez ajouter d'autres clés à supprimer si nécessaire, par exemple:
    // await prefs.remove('userId');
    // await prefs.remove('userRole');

    // Naviguer vers l'écran de connexion et supprimer toutes les routes précédentes
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const AccessScreen()), // Remplacez par votre écran de connexion
          (Route<dynamic> route) => false, // Supprime toutes les routes du stack
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Accueil Admin'),
        backgroundColor: Colors.deepPurple,
        actions: [
          CircleAvatar(
            backgroundColor: Colors.white,
            child: Text(
              getInitial(),
              style: const TextStyle(
                color: Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Bouton de déconnexion
          IconButton(
            icon: const Icon(Icons.logout, color: Colors.white),
            tooltip: 'Déconnexion',
            onPressed: () => _logout(context), // Appel de la fonction de déconnexion
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ElevatedButton(
              child: const Text('Enregistrer un admin'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminRegisterPage()),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Enregistrer un enseignant'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterTeacherScreen()),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              child: const Text('Enregistrer un etudiant'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const RegisterScreen()),
              ),
            ),
            const SizedBox(height: 16),
            // Nouveau bouton pour gérer les cours (pour l'admin)
            ElevatedButton(
              child: const Text('Gérer les cours'),
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AdminManageCoursesScreen()),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String label, VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: Colors.deepPurple,
        padding: const EdgeInsets.symmetric(vertical: 16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
      child: Text(
        label,
        style: const TextStyle(fontSize: 16, color: Colors.white),
      ),
    );
  }
}
