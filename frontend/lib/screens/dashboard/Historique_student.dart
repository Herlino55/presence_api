import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
// import 'package:intl/intl.dart'; // Pour le formatage de la date
import '../../models/My_attendance.dart';
import '../../services/api_service.dart';
import '../../core/app_styles.dart'; // Importez le modèle

class StudentAttendanceHistoryScreen extends StatefulWidget {
  const StudentAttendanceHistoryScreen({super.key});

  @override
  State<StudentAttendanceHistoryScreen> createState() => _StudentAttendanceHistoryScreenState();
}

class _StudentAttendanceHistoryScreenState extends State<StudentAttendanceHistoryScreen> with SingleTickerProviderStateMixin {
  List<StudentAttendanceHistory> _attendanceHistory = [];
  bool _isLoading = false;
  String? _errorMessage;

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
    _fetchAttendanceHistory(); // Charger l'historique au démarrage
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _fetchAttendanceHistory() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    final response = await AuthApi.getStudentAttendanceHistory();

    setState(() {
      _isLoading = false;
      if (response['success']) {
        _attendanceHistory = response['data'] as List<StudentAttendanceHistory>;
      } else {
        _errorMessage = response['message'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Mon Historique de Présence', style: TextStyle(color: Colors.white)),
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
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Center(
                      child: Lottie.asset(
                        'assets/historique.json', // Animation Lottie pour l'historique
                        height: 120,
                        repeat: true,
                      ),
                    ),
                    const SizedBox(height: 20),
                    Text(
                      'Consultez vos enregistrements de présence',
                      style: AppStyles.titleStyle,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Voici la liste de toutes vos présences enregistrées.',
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
                  ],
                ),
              ),
              Expanded(
                child: _isLoading
                    ? const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor)))
                    : _attendanceHistory.isEmpty
                    ? Center(
                  child: Text(
                    'Aucun historique de présence trouvé.',
                    style: AppStyles.subtitleStyle,
                    textAlign: TextAlign.center,
                  ),
                )
                    : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
                  itemCount: _attendanceHistory.length,
                  itemBuilder: (context, index) {
                    final record = _attendanceHistory[index];
                    return Card(
                      elevation: 3,
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        leading: CircleAvatar(
                          backgroundColor: AppStyles.accentColor.withOpacity(0.2),
                          child: Icon(
                            record.status == 'Présent' ? Icons.check_circle : Icons.cancel,
                            color: record.status == 'Présent' ? AppStyles.successColor : AppStyles.errorColor,
                          ),
                        ),
                        title: Text(
                          record.courseName,
                          style: AppStyles.titleStyle.copyWith(fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Utilisation du nouveau champ attendanceDate
                            Text('Date: ${record.attendanceDate.split('T')[0]}', style: AppStyles.subtitleStyle.copyWith(fontSize: 14)),
                            if (record.startTime != null)
                              Text('Arrivée: ${record.startTime?.split('.')[0]}', style: AppStyles.subtitleStyle.copyWith(fontSize: 14)),
                            if (record.endTime != null)
                              Text('Départ: ${record.endTime?.split('.')[0]}', style: AppStyles.subtitleStyle.copyWith(fontSize: 14)),
                            Text(
                              'Statut: ${record.status}',
                              style: AppStyles.subtitleStyle.copyWith(
                                fontSize: 14,
                                color: record.status == 'Présent' ? AppStyles.successColor : AppStyles.errorColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
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
