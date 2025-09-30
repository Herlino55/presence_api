import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'dart:convert'; // Pour décoder la chaîne base64
import '../../services/api_service.dart';
import '../../core/app_styles.dart';
import '../../models/cours_model.dart'; // Importez le modèle de cours

class QrCodeGeneratorScreen extends StatefulWidget {
  const QrCodeGeneratorScreen({super.key});

  @override
  State<QrCodeGeneratorScreen> createState() => _QrCodeGeneratorScreenState();
}

class _QrCodeGeneratorScreenState extends State<QrCodeGeneratorScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  List<Course> _availableCourses = []; // Liste des cours de l'enseignant
  int? _selectedCourseId; // ID du cours sélectionné dans le Dropdown
  String? _selectedType; // Pour le sélecteur 'start'/'end'

  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  String? _qrCodeBase64; // Pour stocker l'image base64 du QR Code

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
    _fetchAvailableCourses(); // Charger les cours disponibles au démarrage
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Fonction pour récupérer les cours de l'enseignant
  Future<void> _fetchAvailableCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await AuthApi.getMyCourses();

    setState(() {
      _isLoading = false;
      if (response['success']) {
        _availableCourses = response['data'] as List<Course>;
        // Si des cours sont disponibles, présélectionner le premier (optionnel)
        if (_availableCourses.isNotEmpty) {
          _selectedCourseId = _availableCourses.first.id;
        }
        _errorMessage = null; // Effacer tout message d'erreur précédent
      } else {
        _errorMessage = response['message'];
      }
    });
  }

  Future<void> _generateQrCode() async {
    // Validation explicite avant l'appel API
    if (_selectedCourseId == null || _selectedType == null) {
      setState(() {
        _errorMessage = 'Veuillez sélectionner un cours et un type.';
        _successMessage = null;
        _qrCodeBase64 = null;
      });
      return; // Arrêter la fonction ici
    }

    setState(() {
      _isLoading = true;
      _errorMessage = null;
      _successMessage = null;
      _qrCodeBase64 = null; // Réinitialiser l'image QR Code
    });

    try {
      final response = await AuthApi.generateQrCode(
        courseId: _selectedCourseId!, // Utiliser l'ID du cours sélectionné (maintenant sûr qu'il n'est pas null)
        type: _selectedType!,
      );

      setState(() {
        _isLoading = false;
        if (response['success']) {
          _successMessage = response['message'];
          _qrCodeBase64 = response['data']['qr']; // Récupérer la chaîne base64 de l'API
          _errorMessage = null; // Effacer les erreurs précédentes
        } else {
          _errorMessage = response['message'];
        }
      });
    } catch (e) {
      // Capture les exceptions inattendues lors de l'appel API
      setState(() {
        _isLoading = false;
        _errorMessage = 'Une erreur inattendue est survenue: ${e.toString()}';
        print('Erreur lors de la génération du QR Code: $e'); // Pour le débogage en console
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Générer QR Code', style: TextStyle(color: Colors.white)),
        backgroundColor: AppStyles.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
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
                    child: Lottie.asset(
                      'assets/create_QR.json', // Animation Lottie pour le QR Code
                      height: 150,
                      repeat: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Générez un QR Code pour votre cours',
                    style: AppStyles.titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Sélectionnez le cours et le type d\'action (début/fin).',
                    style: AppStyles.subtitleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        // Affichage du Dropdown des cours
                        _isLoading && _availableCourses.isEmpty // Si on charge et qu'il n'y a pas de cours
                            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor)))
                            : _availableCourses.isEmpty && !_isLoading // Si pas de cours et qu'on ne charge plus
                            ? Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Text(
                            'Aucun cours disponible. Veuillez créer un cours d\'abord ou vérifier votre connexion.',
                            style: AppStyles.subtitleStyle.copyWith(color: AppStyles.errorColor),
                            textAlign: TextAlign.center,
                          ),
                        )
                            : DropdownButtonFormField<int>(
                          decoration: AppStyles.formFieldDecoration('Sélectionner un cours'),
                          value: _selectedCourseId,
                          hint: const Text('Choisir un cours'),
                          items: _availableCourses.map((course) {
                            return DropdownMenuItem<int>(
                              value: course.id,
                              child: Text('${course.name}'),
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedCourseId = newValue;
                              // Effacer les messages d'erreur liés à la sélection
                              _errorMessage = null;
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Veuillez sélectionner un cours';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        DropdownButtonFormField<String>(
                          decoration: AppStyles.formFieldDecoration('Type d\'action'),
                          value: _selectedType,
                          hint: const Text('Sélectionner le type'),
                          items: const [
                            DropdownMenuItem(value: 'start', child: Text('Début de cours')),
                            DropdownMenuItem(value: 'end', child: Text('Fin de cours')),
                          ],
                          onChanged: (String? newValue) {
                            setState(() {
                              _selectedType = newValue;
                              // Effacer les messages d'erreur liés à la sélection
                              _errorMessage = null;
                            });
                          },
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner un type';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor))
                            : ElevatedButton(
                          // Le bouton est désactivé si aucun cours n'est disponible ou si les sélections sont nulles
                          onPressed: (_availableCourses.isEmpty && !_isLoading) || _selectedCourseId == null || _selectedType == null
                              ? null
                              : _generateQrCode,
                          style: AppStyles.primaryButtonStyle(),
                          child: const Text('Générer le QR Code'),
                        ),
                        if (_errorMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              _errorMessage!,
                              style: const TextStyle(color: AppStyles.errorColor, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        if (_successMessage != null)
                          Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Text(
                              _successMessage!,
                              style: const TextStyle(color: AppStyles.successColor, fontSize: 16),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        const SizedBox(height: 30),
                        // Affichage du QR Code
                        if (_qrCodeBase64 != null)
                          Column(
                            children: [
                              Text(
                                'QR Code Généré:',
                                style: AppStyles.subtitleStyle.copyWith(fontWeight: FontWeight.bold),
                              ),
                              const SizedBox(height: 10),
                              Container(
                                padding: const EdgeInsets.all(8.0),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10.0),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.2),
                                      spreadRadius: 2,
                                      blurRadius: 5,
                                      offset: const Offset(0, 3),
                                    ),
                                  ],
                                ),
                                child: Image.memory(
                                  base64Decode(_qrCodeBase64!.split(',').last),  // Décode la chaîne base64 en image
                                  width: 200,
                                  height: 200,
                                  fit: BoxFit.contain,
                                  errorBuilder: (context, error, stackTrace) {
                                    return const Text('Impossible d\'afficher le QR Code.');
                                  },
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
