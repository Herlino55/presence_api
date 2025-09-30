import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Déclaration d'un widget avec état pour la page d'inscription de l'administrateur
class AdminRegisterPage extends StatefulWidget {
  const AdminRegisterPage({super.key});

  @override
  _AdminRegisterPageState createState() => _AdminRegisterPageState();
}

class _AdminRegisterPageState extends State<AdminRegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>(); // Clé pour valider le formulaire
  String email = '';
  String password = '';
  String confirmPassword = '';

  // Déclaration des contrôleurs d’animation
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Initialisation du contrôleur d’animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    // Animation de fondu (opacité)
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    // Animation de glissement (déplacement vertical)
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // Commence légèrement en bas
      end: Offset.zero, // Se termine à la position d’origine
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    // Démarrer les animations au chargement de la page
    _animationController.forward();
  }

  @override
  void dispose() {
    // Libération des ressources du contrôleur d’animation
    _animationController.dispose();
    super.dispose();
  }

  // Méthode asynchrone pour envoyer les données du formulaire d’inscription
  Future<void> submitRegister() async {
    // Vérification si le formulaire est valide
    if (!_formKey.currentState!.validate()) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('formulaire invalide', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Vérifie si les mots de passe sont identiques
    if (password != confirmPassword) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Les mots de passe ne correspondent pas', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.redAccent,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 3),
        ),
      );
      return;
    }

    // Adresse de l’API pour l’inscription
    final url = Uri.parse('https://presenceapi-production.up.railway.app/admin/signup');
    try {
      // Envoi des données au serveur
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      // Décodage de la réponse JSON
      final data = jsonDecode(response.body);

      // Si la réponse est positive (200 OK)
      if (response.statusCode == 201) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Inscription réussie ! Bienvenue.', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 3),
          ),
        );
        if (!mounted) return;
        // Petite pause pour lire le message avant de rediriger
        Future.delayed(const Duration(seconds: 1), () {
          Navigator.pushReplacementNamed(context, '/login'); // Redirection vers la page de connexion
        });
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Erreur lors de l\'inscription. Veuillez réessayer.', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.orange,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      // En cas d’erreur de connexion
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de se connecter au serveur : $e', style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 5),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.blueGrey[50], // Couleur de fond apaisante
      appBar: AppBar(
        title: const Text(
          'Inscription Administrateur',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.deepPurple, // Couleur dominante
        elevation: 0,
        centerTitle: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            bottom: Radius.circular(20),
          ),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(25),
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: Card(
                elevation: 10,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 40),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      mainAxisSize: MainAxisSize.min, // Adapter la carte au contenu
                      children: [
                        // Icône symbolisant l’éducation
                        const Icon(
                          Icons.school_outlined,
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 25),

                        // Champ Email
                        TextFormField(
                          decoration: _inputDecoration(
                            labelText: 'Email institutionnel',
                            icon: Icons.email_outlined,
                          ),
                          keyboardType: TextInputType.emailAddress,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Veuillez entrer votre email';
                            }
                            if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(val)) {
                              return 'Veuillez entrer un email valide';
                            }
                            return null;
                          },
                          onChanged: (val) => email = val,
                        ),
                        const SizedBox(height: 20),

                        // Champ mot de passe
                        TextFormField(
                          decoration: _inputDecoration(
                            labelText: 'Mot de passe',
                            icon: Icons.lock_outline,
                          ),
                          obscureText: true,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Veuillez entrer un mot de passe';
                            }
                            if (val.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                          onChanged: (val) => password = val,
                        ),
                        const SizedBox(height: 20),

                        // Champ confirmation du mot de passe
                        TextFormField(
                          decoration: _inputDecoration(
                            labelText: 'Confirmer le mot de passe',
                            icon: Icons.check_circle_outline,
                          ),
                          obscureText: true,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Veuillez confirmer votre mot de passe';
                            }
                            if (val != password) {
                              return 'Les mots de passe ne correspondent pas';
                            }
                            return null;
                          },
                          onChanged: (val) => confirmPassword = val,
                        ),
                        const SizedBox(height: 30),

                        // Bouton de création de compte avec animation Hero
                        Hero(
                          tag: 'registerButton',
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                submitRegister();
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              foregroundColor: Colors.white,
                              backgroundColor: Colors.deepPurple,
                              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(30),
                              ),
                              elevation: 5,
                            ),
                            child: const Text(
                              'Créer un compte',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        // const SizedBox(height: 15),
                        //
                        // // Lien vers la page de connexion
                        // TextButton(
                        //   onPressed: () {
                        //     Navigator.pushReplacementNamed(context, '/login'); // Navigation vers la page de connexion
                        //   },
                        //   style: TextButton.styleFrom(
                        //     foregroundColor: Colors.deepPurpleAccent,
                        //   ),
                        //   child: const Text(
                        //     'Déjà un compte ? Se connecter',
                        //     style: TextStyle(fontSize: 16),
                        //   ),
                        // ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  // Méthode d’aide pour styliser les champs de saisie de manière uniforme
  InputDecoration _inputDecoration({required String labelText, required IconData icon}) {
    return InputDecoration(
      labelText: labelText,
      prefixIcon: Icon(icon, color: Colors.deepPurple.withOpacity(0.7)),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: const BorderSide(color: Colors.deepPurple, width: 2),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10),
        borderSide: BorderSide(color: Colors.deepPurple.withOpacity(0.5)),
      ),
      labelStyle: TextStyle(color: Colors.deepPurple.withOpacity(0.8)),
      filled: true,
      fillColor: Colors.white.withOpacity(0.9),
    );
  }
}
