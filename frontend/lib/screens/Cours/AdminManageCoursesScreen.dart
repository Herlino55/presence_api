import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../models/teacher_model.dart';
import '../../services/api_service.dart';
import '../../core/app_styles.dart';
// import '../../models/cours_model.dart'; // Pour afficher les cours si nécessaire

// Modèle simple pour un enseignant (pour le dropdown)
class TeacherOption {
  final int id;
  final String name;

  TeacherOption({required this.id, required this.name});
}

class AdminManageCoursesScreen extends StatefulWidget {
  const AdminManageCoursesScreen({super.key});

  @override
  State<AdminManageCoursesScreen> createState() => _AdminManageCoursesScreenState();
}

class _AdminManageCoursesScreenState extends State<AdminManageCoursesScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _courseNameController = TextEditingController();
  int? _selectedTeacherId; // Pour le dropdown des enseignants

  bool _isLoadingTeachers = false; // Nouvel état de chargement pour les enseignants
  bool _isLoadingCourseCreation = false; // État de chargement pour la création de cours
  String? _errorMessage;
  String? _successMessage;

  List<TeacherForDropdown> _teachers = []; // Liste réelle des enseignants

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
    _fetchTeachers(); // Appeler la fonction pour récupérer les enseignants
  }

  @override
  void dispose() {
    _courseNameController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  // Fonction pour récupérer la liste des enseignants
  Future<void> _fetchTeachers() async {
    setState(() {
      _isLoadingTeachers = true;
      _errorMessage = null; // Réinitialiser les messages d'erreur
    });

    final response = await AuthApi.getAllTeachers();

    setState(() {
      _isLoadingTeachers = false;
      if (response['success']) {
        _teachers = response['data'] as List<TeacherForDropdown>;
        // Optionnel: présélectionner le premier enseignant si la liste n'est pas vide
        if (_teachers.isNotEmpty) {
          _selectedTeacherId = _teachers.first.id;
        }
      } else {
        _errorMessage = response['message'];
      }
    });
  }

  Future<void> _createCourse() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedTeacherId == null) {
        setState(() {
          _errorMessage = 'Veuillez sélectionner un enseignant.';
          _successMessage = null;
        });
        return;
      }

      setState(() {
        _isLoadingCourseCreation = true; // Utiliser le nouvel état de chargement
        _errorMessage = null;
        _successMessage = null;
      });

      final response = await AuthApi.createCourse(
        name: _courseNameController.text,
        teacherId: _selectedTeacherId!,
      );

      setState(() {
        _isLoadingCourseCreation = false; // Mettre à jour le nouvel état de chargement
        if (response['success']) {
          _successMessage = response['message'];
          _courseNameController.clear();
          _selectedTeacherId = null; // Réinitialiser la sélection
          // Optionnel: rafraîchir la liste des enseignants ou des cours si affichée
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
        title: const Text('Gestion des Cours (Admin)', style: TextStyle(color: Colors.white)),
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
                      'assets/Lottie Lego.json', // Animation Lottie pour l'admin
                      height: 150,
                      repeat: true,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Créer et attribuer des cours',
                    style: AppStyles.titleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Utilisez ce formulaire pour ajouter de nouveaux cours et les attribuer à des enseignants.',
                    style: AppStyles.subtitleStyle,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 30),
                  Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: _courseNameController,
                          decoration: AppStyles.formFieldDecoration('Nom du cours'),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Veuillez entrer le nom du cours';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 20),
                        _isLoadingTeachers // Afficher un indicateur pendant le chargement des enseignants
                            ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor)))
                            : _teachers.isEmpty && !_isLoadingTeachers // Si aucun enseignant trouvé
                            ? Padding(
                          padding: const EdgeInsets.only(bottom: 20.0),
                          child: Text(
                            'Aucun enseignant trouvé. Assurez-vous d\'avoir enregistré des enseignants.',
                            style: AppStyles.subtitleStyle.copyWith(color: AppStyles.errorColor),
                            textAlign: TextAlign.center,
                          ),
                        )
                            : DropdownButtonFormField<int>(
                          decoration: AppStyles.formFieldDecoration('Attribuer à l\'enseignant'),
                          value: _selectedTeacherId,
                          hint: const Text('Sélectionner un enseignant'),
                          items: _teachers.map((teacher) {
                            return DropdownMenuItem<int>(
                              value: teacher.id,
                              child: Text(teacher.name), // Afficher nom et email
                            );
                          }).toList(),
                          onChanged: (int? newValue) {
                            setState(() {
                              _selectedTeacherId = newValue;
                              _errorMessage = null; // Effacer l'erreur de sélection
                            });
                          },
                          validator: (value) {
                            if (value == null) {
                              return 'Veuillez sélectionner un enseignant';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 30),
                        _isLoadingCourseCreation // Utiliser le bon état de chargement
                            ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor))
                            : ElevatedButton(
                          onPressed: (_teachers.isEmpty && !_isLoadingTeachers) || _selectedTeacherId == null
                              ? null // Désactiver le bouton si pas d'enseignants ou pas de sélection
                              : _createCourse,
                          style: AppStyles.primaryButtonStyle(),
                          child: const Text('Créer le cours'),
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
