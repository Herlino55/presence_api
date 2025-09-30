import 'package:flutter/material.dart';

class AppStyles {
  // Couleurs principales pour un thème violet universitaire
  static const Color primaryColor = Color(0xFF6A1B9A); // Violet foncé
  static const Color accentColor = Color(0xFFAB47BC); // Violet plus clair pour les accents
  static const Color textColor = Color(0xFF333333); // Texte sombre pour un bon contraste
  static const Color successColor = Color(0xFF4CAF50); // Vert pour le succès
  static const Color errorColor = Color(0xFFEF5350); // Rouge pour les erreurs

  // Décoration standard pour les champs de formulaire
  static InputDecoration formFieldDecoration(String labelText, {Widget? suffixIcon}) {
    return InputDecoration(
      labelText: labelText,
      labelStyle: TextStyle(color: primaryColor.withOpacity(0.8)), // Couleur du label
      filled: true,
      fillColor: Colors.white.withOpacity(0.9), // Fond blanc légèrement transparent
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0), // Bords arrondis
        borderSide: BorderSide.none, // Pas de bordure par défaut
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: primaryColor, width: 2.0), // Bordure violette plus épaisse au focus
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: BorderSide(color: primaryColor.withOpacity(0.5), width: 1.0), // Bordure violette plus claire
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: errorColor, width: 1.0), // Bordure rouge en cas d'erreur
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(10.0),
        borderSide: const BorderSide(color: errorColor, width: 2.0), // Bordure rouge plus épaisse en cas d'erreur au focus
      ),
      contentPadding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 20.0), // Espacement interne
      suffixIcon: suffixIcon, // Icône optionnelle à la fin du champ
    );
  }

  // Style de bouton principal
  static ButtonStyle primaryButtonStyle() {
    return ElevatedButton.styleFrom(
      backgroundColor: primaryColor, // Fond du bouton violet foncé
      foregroundColor: Colors.white, // Texte du bouton blanc
      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15), // Espacement interne
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10.0), // Bords arrondis
      ),
      textStyle: const TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // Style pour les titres
  static TextStyle titleStyle = const TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    color: primaryColor, // Couleur du titre violet foncé
  );

  // Style pour les sous-titres
  static TextStyle subtitleStyle = TextStyle(
    fontSize: 16,
    color: textColor.withOpacity(0.7), // Couleur du sous-titre légèrement transparente
  );
}
