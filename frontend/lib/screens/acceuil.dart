import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart'; // Pour les animations Lottie
import '../../core/app_styles.dart';

// --- Écrans de connexion (placeholders - à remplacer par vos vrais écrans) ---
// Assurez-vous que ces chemins d'importation sont corrects pour votre projet
import './admin/login_admin.dart'; // Pour l'Admin (utilisé précédemment)
// Créez ces fichiers si vous ne les avez pas encore
import './login/login_student.dart';
import './login/login_teacher.dart';
// -------------------------------------------------------------------------

class AccessScreen extends StatefulWidget {
  const AccessScreen({super.key});

  @override
  State<AccessScreen> createState() => _AccessScreenState();
}

class _AccessScreenState extends State<AccessScreen> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOutCubic,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeIn,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('QRMANAGER', style: TextStyle(color: Colors.white)),
        backgroundColor: AppStyles.primaryColor,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    // Animation Lottie pour le thème QR code
                    // Assurez-vous d'avoir un fichier Lottie 'qr_code_animation.json' dans votre dossier assets
                    child: Lottie.asset(
                      'assets/Lottie QRcode.json',
                      height: 200,
                      repeat: true,
                    ),
                  ),
                  const SizedBox(height: 30),
                  Text(
                    'Bienvenue sur notre plateforme !',
                    style: AppStyles.titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 15),
                  Text(
                    'Veuillez sélectionner votre type d\'utilisateur pour vous connecter.',
                    style: AppStyles.subtitleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 50),
                  // Bouton pour le login de l'admin
                  _buildAccessButton(
                    context,
                    'Admin',
                    Icons.security,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const AdminLoginPage()), // Utilise l'écran de login admin existant
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Bouton pour le login de l'enseignant
                  _buildAccessButton(
                    context,
                    'Enseignant',
                    Icons.person_outline,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const TeacherLoginScreen()),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  // Bouton pour le login de l'étudiant
                  _buildAccessButton(
                    context,
                    'Étudiant',
                    Icons.school,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const StudentLoginScreen()),
                      );
                    },
                  ),

                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Widget utilitaire pour construire les boutons d'accès
  Widget _buildAccessButton(BuildContext context, String label, IconData icon, VoidCallback onPressed) {
    return ElevatedButton.icon(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppStyles.primaryColor, // Couleur de fond violette
        foregroundColor: Colors.white, // Couleur du texte et de l'icône
        padding: const EdgeInsets.symmetric(vertical: 18),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        textStyle: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        elevation: 5, // Ajoute une légère ombre
      ),
      icon: Icon(icon, size: 28),
      label: Text(label),
    );
  }
}
