import 'package:flutter/material.dart';
import 'package:http/http.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart'; // Pour les animations Lottie
import '../../services/api_service.dart';
import '../../core/app_styles.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _matriculeController = TextEditingController();
  final TextEditingController _nomController = TextEditingController();
  final TextEditingController _prenomController = TextEditingController();
  final TextEditingController _birthdayController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _classeController = TextEditingController();

  File? _image;
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;
  DateTime? _selectedDate;

  // Animation controllers
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
    _matriculeController.dispose();
    _nomController.dispose();
    _prenomController.dispose();
    _birthdayController.dispose();
    _passwordController.dispose();
    _classeController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppStyles.primaryColor, // Couleur des en-têtes
            colorScheme: const ColorScheme.light(primary: AppStyles.primaryColor),
            buttonTheme: const ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
        _birthdayController.text = DateFormat('yyyy-MM-dd').format(picked);
      });
    }
  }

  Future<void> _submitForm() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
        _successMessage = null;
      });

      final response = await AuthApi.register(
        matricule: _matriculeController.text,
        nom: _nomController.text,
        prenom: _prenomController.text,
        birthday: _birthdayController.text,
        password: _passwordController.text,
        classe: _classeController.text,
        image: _image,
      );

      setState(() {
        _isLoading = false;
        if (response['success']) {
          _successMessage = response['message'];
          // Optionnel: Réinitialiser le formulaire
          _formKey.currentState!.reset();
          _matriculeController.clear();
          _nomController.clear();
          _prenomController.clear();
          _birthdayController.clear();
          _passwordController.clear();
          _classeController.clear();
          _image = null;
          _selectedDate = null;
        } else {
          _errorMessage = response['message'];
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Inscription Étudiant', style: TextStyle(color: Colors.white)),
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
                      'assets/Lottie Student.json', // Remplacez par le chemin de votre animation Lottie
                      height: 150,
                      repeat: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Rejoignez notre communauté étudiante !',
                    style: AppStyles.titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Veuillez remplir le formulaire ci-dessous pour vous inscrire.',
                    style: AppStyles.subtitleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _matriculeController,
                          decoration: AppStyles.formFieldDecoration('Matricule'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le matricule';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _nomController,
                          decoration: AppStyles.formFieldDecoration('Nom'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _prenomController,
                          decoration: AppStyles.formFieldDecoration('Prénom'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le prénom';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _birthdayController,
                          decoration: AppStyles.formFieldDecoration(
                            'Date de naissance',
                            suffixIcon: IconButton(
                              icon: const Icon(Icons.calendar_today, color: AppStyles.primaryColor),
                              onPressed: () => _selectDate(context),
                            ),
                          ),
                          readOnly: true, // Empêche la saisie manuelle
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez sélectionner une date de naissance';
                            }
                            return null;
                          },
                          onTap: () => _selectDate(context), // Ouvre le DatePicker au tap
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _passwordController,
                          decoration: AppStyles.formFieldDecoration('Mot de passe'),
                          obscureText: true,
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le mot de passe';
                            }
                            if (value.length < 6) {
                              return 'Le mot de passe doit contenir au moins 6 caractères';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        TextFormField(
                          controller: _classeController,
                          decoration: AppStyles.formFieldDecoration('Classe'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer la classe';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        GestureDetector(
                          onTap: _pickImage,
                          child: Container(
                            height: 100,
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(10.0),
                              border: Border.all(color: AppStyles.primaryColor.withOpacity(0.5)),
                            ),
                            child: _image == null
                                ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(Icons.camera_alt, size: 40, color: AppStyles.primaryColor.withOpacity(0.7)),
                                const SizedBox(height: 5),
                                Text('Sélectionner une photo', style: TextStyle(color: AppStyles.primaryColor.withOpacity(0.7))),
                              ],
                            )
                                : ClipRRect(
                              borderRadius: BorderRadius.circular(8.0),
                              child: Image.file(_image!, fit: BoxFit.cover),
                            ),
                          ),
                        ),
                        if (_image == null && _formKey.currentState != null && !_formKey.currentState!.validate())
                          Padding(
                            padding: const EdgeInsets.only(top: 8.0),
                            child: Text(
                              'Veuillez sélectionner une image',
                              style: TextStyle(color: AppStyles.errorColor, fontSize: 12),
                            ),
                          ),
                        const SizedBox(height: 30),
                        _isLoading
                            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor))
                            : ElevatedButton(
                          onPressed: _submitForm,
                          style: AppStyles.primaryButtonStyle(),
                          child: const Text('S\'inscrire'),
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