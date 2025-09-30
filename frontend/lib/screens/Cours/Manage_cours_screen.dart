import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import '../../services/api_service.dart';
import '../../models/cours_model.dart';
import '../../core/app_styles.dart';
import '../QRcode/qr_code_generator_screen.dart'; // Pour naviguer vers la génération de QR

class ManageCoursesScreen extends StatefulWidget {
  const ManageCoursesScreen({super.key});

  @override
  State<ManageCoursesScreen> createState() => _ManageCoursesScreenState();
}

class _ManageCoursesScreenState extends State<ManageCoursesScreen> with SingleTickerProviderStateMixin {
  List<Course> _courses = [];
  bool _isLoading = false;
  String? _errorMessage;
  String? _successMessage;

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
    _fetchCourses(); // Charger les cours au démarrage de l'écran
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchCourses() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await AuthApi.getMyCourses();

    setState(() {
      _isLoading = false;
      if (response['success']) {
        _courses = response['data'] as List<Course>;
        _successMessage = response['message'];
      } else {
        _errorMessage = response['message'];
      }
    });
  }

  // Les fonctions _showCreateCourseDialog et _createCourse sont supprimées de cet écran

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mes Cours', style: TextStyle(color: Colors.white)),
        backgroundColor: AppStyles.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Center(
                      child: Lottie.asset(
                        'assets/qrcode.json', // Animation Lottie pour la gestion des cours
                        height: 120,
                        repeat: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Voici la liste de vos cours',
                      style: AppStyles.titleStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Vous pouvez générer des QR codes pour chaque cours.',
                      style: AppStyles.subtitleStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    if (_errorMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppStyles.errorColor, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    if (_successMessage != null)
                      Padding(
                        padding: const EdgeInsets.only(bottom: 10.0),
                        child: Text(
                          _successMessage!,
                          style: const TextStyle(color: AppStyles.successColor, fontSize: 16),
                          textAlign: TextAlign.center,
                        ),
                      ),
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor)))
                    : _courses.isEmpty
                    ? Center(
                  child: Text(
                    'Aucun cours trouvé. Contactez l\'administrateur pour l\'attribution des cours.',
                    style: AppStyles.subtitleStyle,
                    textAlign: TextAlign.center,
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  itemCount: _courses.length,
                  itemBuilder: (context, index) {
                    final course = _courses[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: AppStyles.accentColor.withOpacity(0.2),
                          child: Icon(Icons.book, color: AppStyles.primaryColor),
                        ),
                        title: Text(
                          course.name,
                          style: AppStyles.titleStyle.copyWith(fontSize: 18),
                        ),
                        subtitle: Text(
                          'ID du cours: ${course.id}',
                          style: AppStyles.subtitleStyle.copyWith(fontSize: 14),
                        ),
                        trailing: IconButton(
                          icon: Icon(Icons.qr_code_2, color: AppStyles.primaryColor),
                          tooltip: 'Générer QR Code',
                          onPressed: () {
                            // Naviguer vers l'écran de génération de QR code
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const QrCodeGeneratorScreen(),
                              ),
                            );
                          },
                        ),
                        onTap: () {
                          // Optionnel: Afficher les détails du cours ou d'autres actions
                        },
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      // FloatingActionButton est supprimé car la création de cours est maintenant pour l'admin
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _showCreateCourseDialog,
      //   label: const Text('Ajouter un cours'),
      //   icon: const Icon(Icons.add),
      //   backgroundColor: AppStyles.accentColor,
      //   foregroundColor: AppStyles.primaryColor,
      //   shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      // ),
      // floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
    );
  }
}
