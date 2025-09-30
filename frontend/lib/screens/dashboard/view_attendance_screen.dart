import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:intl/intl.dart'; // Pour le formatage de la date
import '../../services/api_service.dart';
import '../../core/app_styles.dart';
import '../../models/cours_model.dart';
import '../../models/student_model_list.dart'; // Importez le modèle de présence

class ViewAttendanceScreen extends StatefulWidget {
  const ViewAttendanceScreen({super.key});

  @override
  State<ViewAttendanceScreen> createState() => _ViewAttendanceScreenState();
}

class _ViewAttendanceScreenState extends State<ViewAttendanceScreen> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  List<Course> _availableCourses = [];
  int? _selectedCourseId;
  DateTime? _selectedDate;
  final TextEditingController _dateController = TextEditingController();

  List<StudentAttendance> _attendanceList = [];
  bool _isLoadingCourses = false;
  bool _isLoadingAttendance = false;
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
    _fetchAvailableCourses(); // Charger les cours disponibles au démarrage
  }

  @override
  void dispose() {
    _dateController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAvailableCourses() async {
    setState(() {
      _isLoadingCourses = true;
      _errorMessage = null;
    });

    final response = await AuthApi.getMyCourses(); // Récupère les cours de l'enseignant connecté

    setState(() {
      _isLoadingCourses = false;
      if (response['success']) {
        _availableCourses = response['data'] as List<Course>;
        if (_availableCourses.isNotEmpty) {
          _selectedCourseId = _availableCourses.first.id; // Présélectionner le premier cours
        }
      } else {
        _errorMessage = response['message'];
      }
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: AppStyles.primaryColor,
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
        _dateController.text = DateFormat('yyyy-MM-dd').format(picked);
        _errorMessage = null; // Effacer l'erreur de date
      });
    }
  }

  Future<void> _fetchAttendance() async {
    if (_formKey.currentState!.validate()) {
      if (_selectedCourseId == null || _selectedDate == null) {
        setState(() {
          _errorMessage = 'Veuillez sélectionner un cours et une date.';
          _attendanceList = []; // Vider la liste
        });
        return;
      }

      setState(() {
        _isLoadingAttendance = true;
        _errorMessage = null;
        _successMessage = null;
        _attendanceList = []; // Vider la liste avant le nouveau chargement
      });

      try {
        final response = await AuthApi.getStudentAttendanceByCourseAndDate(
          courseId: _selectedCourseId!,
          date: DateFormat('yyyy-MM-dd').format(_selectedDate!),
        );

        setState(() {
          _isLoadingAttendance = false;
          if (response['success']) {
            _attendanceList = response['data'] as List<StudentAttendance>;
            _successMessage = response['message'];
          } else {
            _errorMessage = response['message'];
          }
        });
      } catch (e) {
        setState(() {
          _isLoadingAttendance = false;
          _errorMessage = 'Une erreur inattendue est survenue: ${e.toString()}';
          print('Erreur lors de la récupération de la présence: $e');
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Voir la Présence', style: TextStyle(color: Colors.white)),
        backgroundColor: AppStyles.primaryColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Column( // La colonne principale prend tout l'espace disponible
            children: [
              // Section du formulaire (prend 1/3 de l'espace vertical)
              Expanded(
                flex: 1, // Donne 1 part de l'espace à cette section
                child: SingleChildScrollView( // Permet au formulaire de défiler si trop long
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Center(
                          child: Lottie.asset(
                            'assets/liste.json', // Animation Lottie pour la présence
                            height: 120,
                            repeat: true,
                          ),
                        ),
                        const SizedBox(height: 20),
                        Text(
                          'Consulter la présence des étudiants',
                          style: AppStyles.titleStyle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'Sélectionnez un cours et une date pour voir les présences.',
                          style: AppStyles.subtitleStyle,
                          textAlign: TextAlign.center,
                        ),
                        const SizedBox(height: 30),
                        Form(
                          key: _formKey,
                          child: Column(
                            children: [
                              // Dropdown pour les cours
                              _isLoadingCourses
                                  ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor)))
                                  : _availableCourses.isEmpty
                                  ? Padding(
                                padding: const EdgeInsets.only(bottom: 20.0),
                                child: Text(
                                  'Aucun cours disponible. Veuillez créer un cours d\'abord.',
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
                                    child: Text('${course.name} (ID: ${course.id})'),
                                  );
                                }).toList(),
                                onChanged: (int? newValue) {
                                  setState(() {
                                    _selectedCourseId = newValue;
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
                              // Champ de sélection de date
                              TextFormField(
                                controller: _dateController,
                                decoration: AppStyles.formFieldDecoration(
                                  'Date de présence',
                                  suffixIcon: IconButton(
                                    icon: const Icon(Icons.calendar_today, color: AppStyles.primaryColor),
                                    onPressed: () => _selectDate(context),
                                  ),
                                ),
                                readOnly: true,
                                validator: (value) {
                                  if (value == null || value.isEmpty) {
                                    return 'Veuillez sélectionner une date';
                                  }
                                  return null;
                                },
                                onTap: () => _selectDate(context),
                              ),
                              const SizedBox(height: 30),
                              _isLoadingAttendance
                                  ? const CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor))
                                  : ElevatedButton(
                                onPressed: (_availableCourses.isEmpty || _selectedCourseId == null || _selectedDate == null)
                                    ? null
                                    : _fetchAttendance,
                                style: AppStyles.primaryButtonStyle(),
                                child: const Text('Afficher la présence'),
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
              // Liste des étudiants et de leur statut de présence (prend 2/3 de l'espace vertical)
              Expanded(
                flex: 1, // Donne 2 parts de l'espace à cette section
                child: _isLoadingAttendance
                    ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor)))
                    : _attendanceList.isEmpty && _selectedCourseId != null && _selectedDate != null && !_isLoadingAttendance && _errorMessage == null
                    ? Center(
                  child: Text(
                    'Aucune présence enregistrée pour ce cours à cette date.',
                    style: AppStyles.subtitleStyle,
                    textAlign: TextAlign.center,
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  itemCount: _attendanceList.length,
                  itemBuilder: (context, index) {
                    final student = _attendanceList[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: AppStyles.accentColor.withOpacity(0.2),
                          backgroundImage: student.imageUrl != null && student.imageUrl!.isNotEmpty
                              ? NetworkImage(student.imageUrl!) as ImageProvider<Object>?
                              : null,
                          child: student.imageUrl == null || student.imageUrl!.isEmpty
                              ? Icon(Icons.person, color: AppStyles.primaryColor)
                              : null,
                        ),
                        title: Text(
                          '${student.nom} ${student.prenom}',
                          style: AppStyles.titleStyle.copyWith(fontSize: 18),
                        ),
                        subtitle: Text(
                          'Statut: ${student.statut}',
                          style: AppStyles.subtitleStyle.copyWith(
                            fontSize: 14,
                            color: student.statut == 'Présent' ? AppStyles.successColor : AppStyles.errorColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}