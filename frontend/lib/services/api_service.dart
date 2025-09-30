import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/app_constants.dart';
import '../models/My_attendance.dart';
import '../models/cours_model.dart';
import '../models/student_model_list.dart';
import '../models/teacher_model.dart';

class AuthApi {
  static Future<Map<String, dynamic>> register({
    required String matricule,
    required String nom,
    required String prenom,
    required String birthday,
    required String password,
    required String classe,
    File? image,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/admin/student/signup');

    // Récupérer le token de SharedPreferences
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token');

    if (token == null) {
      return {'success': false, 'message': 'Authentification requise : Token manquant'};
    }

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token'; // Ajout du token

    request.fields['matricule'] = matricule;
    request.fields['nom'] = nom;
    request.fields['prenom'] = prenom;
    request.fields['birthday'] = birthday;
    request.fields['password'] = password;
    request.fields['classe'] = classe;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image_url', image.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Étudiant créé avec succès', 'data': json.decode(response.body)};
      } else {
        final errorData = json.decode(response.body);
        return {'success': false, 'message': errorData['error'] ?? 'Erreur lors de l\'inscription'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}'};
    }
  }

  // Nouvelle méthode pour l'inscription des enseignants 
  static Future<Map<String, dynamic>> registerTeacher({
    required String name,
    required String email,
    required String password,
    File? image,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/admin/teacher/signup');

    // Récupérer le token de SharedPreferences (comme pour l'étudiant)
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token');

    if (token == null) {
      return {'success': false, 'message': 'Authentification requise : Token manquant'};
    }

    var request = http.MultipartRequest('POST', url);
    request.headers['Authorization'] = 'Bearer $token'; // Ajout du token

    request.fields['name'] = name;
    request.fields['email'] = email;
    request.fields['password'] = password;

    if (image != null) {
      request.files.add(await http.MultipartFile.fromPath('image_url', image.path));
    }

    try {
      final streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Enseignant créé avec succès', 'data': json.decode(response.body)};
      } else {
        final errorData = json.decode(response.body);
        return {'success': false, 'message': errorData['error'] ?? 'Erreur lors de l\'inscription de l\'enseignant'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}'};
    }
  }

  // Nouvelle méthode pour la connexion de l'étudiant
  static Future<Map<String, dynamic>> loginStudent({
    required String matricule,
    required String password,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/student/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'matricule': matricule,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Stocker le token si la connexion est réussie
        final String token = responseData['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);

        // Décoder le token pour extraire les informations de l'étudiant
        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        await prefs.setString('userName', '${decodedToken['nom']} ${decodedToken['prenom']}');
        await prefs.setString('userImageUrl', decodedToken['image_url'] ?? ''); // Stocker l'URL de l'image
        await prefs.setString('userRole', decodedToken['role'] ?? 'student'); // Stocker le rôle

        return {'success': true, 'message': 'Connexion réussie', 'data': responseData};
      } else {
        return {'success': false, 'message': responseData['error'] ?? 'Erreur de connexion'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}'};
    }
  }

  // Nouvelle méthode pour la connexion de l'enseignant
  static Future<Map<String, dynamic>> loginTeacher({
    required String email,
    required String password,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/teacher/login');

    try {
      final response = await http.post(
        url,
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'email': email,
          'password': password,
        }),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // Stocker le token si la connexion est réussie
        final String token = responseData['token'];
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', responseData['token']);
        // Vous pouvez aussi stocker d'autres informations utilisateur si nécessaire

        Map<String, dynamic> decodedToken = JwtDecoder.decode(token);
        await prefs.setString('userName', decodedToken['name'] ?? ''); // Stocker le nom de l'enseignant
        await prefs.setString('userImageUrl', decodedToken['image_url'] ?? ''); // Stocker l'URL de l'image
        await prefs.setString('userRole', decodedToken['role'] ?? 'teacher'); // Stocker le rôle

        return {'success': true, 'message': 'Connexion réussie', 'data': responseData};
      } else {
        return {'success': false, 'message': responseData['error'] ?? 'Erreur de connexion'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}'};
    }
  }

  // Nouvelle méthode pour la génération de QR Code
  static Future<Map<String, dynamic>> generateQrCode({
    required int? courseId,
    required String type,
  }) async {
    // L'endpoint de votre API est /getQRcode/:courseId/:type
    final url = Uri.parse('${AppConstants.baseUrl}/qrcode/generate/$courseId/$type');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {'success': false, 'message': 'Authentification requise : Token manquant'};
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Inclure le token d'authentification
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        return {'success': true, 'message': 'QR Code généré avec succès', 'data': responseData};
      } else {
        return {'success': false, 'message': responseData['error'] ?? 'Erreur lors de la génération du QR Code'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}'};
    }
  }

  // Nouvelle méthode pour créer un cours
  static Future<Map<String, dynamic>> createCourse({
    required String name,
    required int teacherId,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/cours/CreateCours');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token');

    if (token == null) {
      return {'success': false, 'message': 'Authentification requise : Token manquant'};
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Inclure le token d'authentification
        },
        body: json.encode({'name': name, 'teacherId': teacherId}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 201) {
        return {'success': true, 'message': 'Cours créé avec succès', 'data': responseData};
      } else {
        return {'success': false, 'message': responseData['error'] ?? 'Erreur lors de la création du cours'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}'};
    }
  }

  // Nouvelle méthode pour récupérer les cours de l'enseignant
  static Future<Map<String, dynamic>> getMyCourses() async {
    final url = Uri.parse('${AppConstants.baseUrl}/cours/ReadCours');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {'success': false, 'message': 'Authentification requise : Token manquant'};
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Inclure le token d'authentification
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) {
        // La réponse est une liste de cours
        List<Course> courses = (responseData as List)
            .map((courseJson) => Course.fromJson(courseJson))
            .toList();
        return {'success': true, 'message': 'Cours récupérés avec succès', 'data': courses};
      } else {
        return {'success': false, 'message': responseData['error'] ?? 'Erreur lors de la récupération des cours'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}'};
    }
  }

  // Nouvelle méthode pour enregistrer la présence au début du cours
  static Future<Map<String, dynamic>> recordStudentPresenceStart({
    required int coursesId,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/presence/start');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {'success': false, 'message': 'Authentification requise : Token manquant'};
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Inclure le token d'authentification de l'étudiant
        },
        body: json.encode({'courses_id': coursesId}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) { // L'API renvoie 200 OK pour le succès
        return {'success': true, 'message': responseData['message'] ?? 'Présence début enregistrée', 'data': responseData};
      } else {
        return {'success': false, 'message': responseData['error'] ?? 'Erreur lors de l\'enregistrement de la présence début (Code: ${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}'};
    }
  }

  // Nouvelle méthode pour enregistrer la présence à la fin du cours
  static Future<Map<String, dynamic>> recordStudentPresenceEnd({
    required int coursesId,
  }) async {
    final url = Uri.parse('${AppConstants.baseUrl}/presence/end');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      return {'success': false, 'message': 'Authentification requise : Token manquant'};
    }

    try {
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Inclure le token d'authentification de l'étudiant
        },
        body: json.encode({'courses_id': coursesId}),
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) { // L'API renvoie 200 OK pour le succès
        return {'success': true, 'message': responseData['message'] ?? 'Présence fin enregistrée', 'data': responseData};
      } else {
        return {'success': false, 'message': responseData['error'] ?? 'Erreur lors de l\'enregistrement de la présence fin (Code: ${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}'};
    }
  }

  // Nouvelle méthode pour récupérer tous les enseignants
  static Future<Map<String, dynamic>> getAllTeachers() async {
    final url = Uri.parse('${AppConstants.baseUrl}/admin/teacher/All');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('admin_token'); // L'admin doit être connecté

    if (token == null) {
      return {'success': false, 'message': 'Authentification requise : Token manquant'};
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Token de l'administrateur
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) { // Votre API renvoie 200 OK
        List<TeacherForDropdown> teachers = (responseData as List)
            .map((teacherJson) => TeacherForDropdown.fromJson(teacherJson))
            .toList();
        return {'success': true, 'message': 'Enseignants récupérés avec succès', 'data': teachers};
      } else {
        return {'success': false, 'message': responseData['error'] ?? 'Erreur lors de la récupération des enseignants (Code: ${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}'};
    }
  }

  // Nouvelle méthode pour récupérer la présence des étudiants par cours et date
  static Future<Map<String, dynamic>> getStudentAttendanceByCourseAndDate({
    required int courseId,
    required String date, // Format 'YYYY-MM-DD'
  }) async {
    // L'endpoint est /getPresenceParCoursEtDateImg/:courseId/:date
    final url = Uri.parse('${AppConstants.baseUrl}/presence/PresenceByCoursImg/$courseId/$date');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Le token de l'enseignant ou de l'admin

    if (token == null) {
      return {'success': false, 'message': 'Authentification requise : Token manquant'};
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Inclure le token d'authentification
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) { // Votre API renvoie 200 OK
        List<StudentAttendance> attendanceList = (responseData as List)
            .map((studentJson) => StudentAttendance.fromJson(studentJson))
            .toList();
        return {'success': true, 'message': 'Présence récupérée avec succès', 'data': attendanceList};
      } else {
        return {'success': false, 'message': responseData['message'] ?? 'Erreur lors de la récupération de la présence (Code: ${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}'};
    }
  }

  // Nouvelle méthode pour récupérer l'historique de présence d'un étudiant
  static Future<Map<String, dynamic>> getStudentAttendanceHistory() async {
    final url = Uri.parse('${AppConstants.baseUrl}/presence/MesHistoriques');

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token'); // Le token de l'étudiant

    if (token == null) {
      return {'success': false, 'message': 'Authentification requise : Token manquant'};
    }

    try {
      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Inclure le token d'authentification de l'étudiant
        },
      );

      final responseData = json.decode(response.body);

      if (response.statusCode == 200) { // L'API renvoie 200 OK
        List<StudentAttendanceHistory> historyList = (responseData as List)
            .map((itemJson) => StudentAttendanceHistory.fromJson(itemJson))
            .toList();
        return {'success': true, 'message': 'Historique de présence récupéré avec succès', 'data': historyList};
      } else {
        return {'success': false, 'message': responseData['error'] ?? 'Erreur lors de la récupération de l\'historique (Code: ${response.statusCode})'};
      }
    } catch (e) {
      return {'success': false, 'message': 'Erreur réseau: ${e.toString()}'};
    }
  }
}

// url_api: 'https://presenceapi-production.up.railway.app';