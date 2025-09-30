import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:presence_qr/screens/admin/admin_homepage.dart';
import 'package:shared_preferences/shared_preferences.dart';


class AdminLoginPage extends StatefulWidget {
  const AdminLoginPage({super.key}); // Add const constructor

  @override
  _AdminLoginPageState createState() => _AdminLoginPageState();
}

class _AdminLoginPageState extends State<AdminLoginPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  String email = '';
  String password = '';

  // Animation controllers
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeIn,
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2), // Start slightly below
      end: Offset.zero, // End at original position
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeOutCubic,
      ),
    );

    _animationController.forward(); // Start the animations when the page loads
  }

  @override
  void dispose() {
    _animationController.dispose(); // Don't forget to dispose the controller
    super.dispose();
  }

  // 🔐 Sauvegarde du token dans le stockage local
  Future<void> _saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('admin_token', token); // Le token est stocké sous la clé 'admin_token'
  }

  Future<void> submitLogin() async {
    if (!_formKey.currentState!.validate()) {
      return; // Stop if form is invalid
    }

    // Important: Replace with your actual backend IP address if not localhost
    // On a physical device, 'localhost' will refer to the device itself, not your computer.
    // Use your computer's local IP address (e.g., 192.168.1.X or 10.0.2.2 for Android emulator)
    final url = Uri.parse('https://presenceapi-production.up.railway.app/admin/login'); // Keep your existing IP

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      final data = jsonDecode(response.body);

      if (!mounted) return; // Check if the widget is still in the tree

      if (response.statusCode == 200) {
        // ✅ Sauvegarde du token JWT
        await _saveToken(data['token']);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Connexion réussie ! Redirection...', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 2),
          ),
        );
        // Navigate to the admin dashboard or home page after a short delay
        Future.delayed(const Duration(seconds: 1), () {
          if (!mounted) return;
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => AdminHomePage(mail: email)),
          ); // Replace with your admin dashboard route
        });
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(data['error'] ?? 'Email ou mot de passe incorrect.', style: TextStyle(color: Colors.white)),
            backgroundColor: Colors.redAccent,
            behavior: SnackBarBehavior.floating,
            duration: Duration(seconds: 4),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Impossible de se connecter au serveur. Vérifiez votre connexion: $e', style: TextStyle(color: Colors.white)),
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
      backgroundColor: Colors.blueGrey[50], // Consistent background
      appBar: AppBar(
        title: const Text(
          'Connexion Administrateur',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            letterSpacing: 1.2,
          ),
        ),
        backgroundColor: Colors.deepPurple, // Consistent school color
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
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        // School-themed icon for login
                        const Icon(
                          Icons.vpn_key_outlined, // A key icon suitable for login
                          size: 80,
                          color: Colors.deepPurple,
                        ),
                        const SizedBox(height: 25),

                        TextFormField(
                          decoration: _inputDecoration(
                            labelText: 'Email',
                            icon: Icons.person_outline,
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

                        TextFormField(
                          decoration: _inputDecoration(
                            labelText: 'Mot de passe',
                            icon: Icons.lock_open_outlined,
                          ),
                          obscureText: true,
                          validator: (val) {
                            if (val == null || val.isEmpty) {
                              return 'Veuillez entrer votre mot de passe';
                            }
                            return null;
                          },
                          onChanged: (val) => password = val,
                        ),
                        const SizedBox(height: 30),

                        Hero(
                          tag: 'loginButton', // Unique tag for hero animation
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                submitLogin();
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
                              'Se Connecter',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 10),
                        TextButton(
                          onPressed: () {
                            // Implement Forgot Password logic or navigate to a reset page
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Fonctionnalité "Mot de passe oublié" à implémenter.', style: TextStyle(color: Colors.white)),
                                backgroundColor: Colors.blueGrey,
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          },
                          style: TextButton.styleFrom(
                            foregroundColor: Colors.grey[600],
                          ),
                          child: const Text(
                            'Mot de passe oublié ?',
                            style: TextStyle(fontSize: 14),
                          ),
                        ),
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

  // Helper method for consistent input decoration
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