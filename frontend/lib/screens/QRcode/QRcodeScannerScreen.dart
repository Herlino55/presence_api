import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'dart:convert'; // Pour décoder la chaîne JSON
import 'package:lottie/lottie.dart'; // Pour les animations Lottie
import '../../core/app_styles.dart'; // Pour le thème violet
import '../../services/api_service.dart'; // Importez l'API pour les appels de présence

class QrCodeScannerScreen extends StatefulWidget {
  const QrCodeScannerScreen({super.key});

  @override
  State<QrCodeScannerScreen> createState() => _QrCodeScannerScreenState();
}

class _QrCodeScannerScreenState extends State<QrCodeScannerScreen> with SingleTickerProviderStateMixin {
  MobileScannerController cameraController = MobileScannerController();
  String? _scannedDataDisplay; // Pour l'affichage formaté des données
  String? _errorMessage;

  bool _isLoading = false;
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
    cameraController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _onQrCodeDetect(BarcodeCapture capture) {
    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final String? rawValue = barcodes.first.rawValue;
      if (rawValue != null) {
        try {
          // Tente de décoder la chaîne comme un JSON
          final decodedJson = json.decode(rawValue) as Map<String, dynamic>;
          setState(() {
            _scannedDataDisplay = 'Données du QR Code :\n${JsonEncoder.withIndent('  ').convert(decodedJson)}';
            _errorMessage = null;
          });
          // Arrêter le scan après la détection pour éviter des scans multiples
          cameraController.stop();
          _showScannedDataDialog(decodedJson); // Afficher les données dans un dialogue avec options d'action
        } catch (e) {
          setState(() {
            _scannedDataDisplay = null;
            _errorMessage = 'Erreur de décodage JSON du QR Code : ${e.toString()}';
          });
        }
      } else {
        setState(() {
          _scannedDataDisplay = null;
          _errorMessage = 'Aucune donnée trouvée dans le QR Code.';
        });
      }
    }
  }

  // Nouvelle fonction pour enregistrer la présence via l'API
  Future<void> _recordPresence(int courseId, String type) async {
    Navigator.pop(context); // Fermer le dialogue après l'action

    setState(() {
      _isLoading = true; // Utiliser un état de chargement local si nécessaire
      _errorMessage = null;
    });

    Map<String, dynamic> response;
    if (type == 'start') {
      response = await AuthApi.recordStudentPresenceStart(coursesId: courseId);
    } else if (type == 'end') {
      response = await AuthApi.recordStudentPresenceEnd(coursesId: courseId);
    } else {
      setState(() {
        _errorMessage = 'Type d\'action invalide.';
        _isLoading = false;
      });
      return;
    }

    setState(() {
      _isLoading = false;
      if (response['success']) {
        _scannedDataDisplay = 'Succès: ${response['message']}';
        _errorMessage = null;
      } else {
        _errorMessage = response['message'];
        _scannedDataDisplay = null; // Effacer l'affichage si erreur
      }
    });

    // Redémarrer le scan après un court délai pour permettre à l'utilisateur de voir le message
    Future.delayed(const Duration(seconds: 2), () {
      cameraController.start();
      setState(() {
        _scannedDataDisplay = null; // Réinitialiser l'affichage après redémarrage
        _errorMessage = null;
      });
    });
  }


  void _showScannedDataDialog(Map<String, dynamic> data) {
    final int? courseId = data['coursId'] is int ? data['courseId'] : int.tryParse(data['courseId'].toString());
    final String? title = data['cours'] as String?;
    final String? type = data['type'] as String?;
    // final String? teacherName = data['teacherId'] as String?;
    final String? name = data['name'] as String?;
    final String? date = data['date'] as String?;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('QR Code Scanné', style: AppStyles.titleStyle.copyWith(fontSize: 22)),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Cours: ${title ?? 'N/A'}', style: AppStyles.subtitleStyle),
                Text('Type: ${type ?? 'N/A'}', style: AppStyles.subtitleStyle),
                Text('Enseignant: ${name ?? 'N/A'}', style: AppStyles.subtitleStyle),
                Text('Date: ${date ?? 'N/A'}', style: AppStyles.subtitleStyle),
                const SizedBox(height: 15),
                Text('Confirmez votre action:', style: AppStyles.subtitleStyle.copyWith(fontWeight: FontWeight.bold)),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Fermer le dialogue
                cameraController.start(); // Redémarrer le scan
              },
              child: Text('Annuler', style: TextStyle(color: AppStyles.errorColor)),
            ),
            if (courseId != null && type == 'start')
              ElevatedButton(
                onPressed: () => _recordPresence(courseId, 'start'),
                style: AppStyles.primaryButtonStyle().copyWith(
                  backgroundColor: MaterialStateProperty.all(AppStyles.successColor),
                ),
                child: const Text('Enregistrer l\'arrivée'),
              ),
            if (courseId != null && type == 'end')
              ElevatedButton(
                onPressed: () => _recordPresence(courseId, 'end'),
                style: AppStyles.primaryButtonStyle().copyWith(
                  backgroundColor: MaterialStateProperty.all(AppStyles.primaryColor),
                ),
                child: const Text('Enregistrer le départ'),
              ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        title: const Text('Scanner QR Code', style: TextStyle(color: Colors.white)),
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
              Expanded(
                flex: 3,
                child: Stack(
                  children: [
                    MobileScanner(
                      controller: cameraController,
                      onDetect: _onQrCodeDetect,
                    ),
                    Center(
                      child: Container(
                        width: 200,
                        height: 200,
                        decoration: BoxDecoration(
                          border: Border.all(color: AppStyles.accentColor, width: 4),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Lottie.asset(
                          'assets/scan.json', // Animation Lottie pour le scan
                          fit: BoxFit.contain,
                          repeat: true,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              Expanded(
                flex: 2,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'Scannez le QR Code de présence',
                        style: AppStyles.titleStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      Text(
                        'Pointez la caméra vers le QR Code pour enregistrer votre présence.',
                        style: AppStyles.subtitleStyle,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 20),
                      // Affichage des messages de succès/erreur ou des données scannées
                      if (_isLoading)
                        const Center(child: CircularProgressIndicator(valueColor: AlwaysStoppedAnimation<Color>(AppStyles.primaryColor)))
                      else if (_errorMessage != null)
                        Text(
                          _errorMessage!,
                          style: const TextStyle(color: AppStyles.errorColor, fontSize: 16),
                          textAlign: TextAlign.center,
                        )
                      else if (_scannedDataDisplay != null)
                          Expanded(
                            child: SingleChildScrollView(
                              child: Text(
                                _scannedDataDisplay!,
                                style: const TextStyle(fontSize: 14, color: AppStyles.textColor),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: () {
                          cameraController.start(); // Redémarrer le scan manuellement
                          setState(() {
                            _scannedDataDisplay = null;
                            _errorMessage = null;
                          });
                        },
                        style: AppStyles.primaryButtonStyle(),
                        icon: const Icon(Icons.refresh),
                        label: const Text('Recommencer le scan'),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
