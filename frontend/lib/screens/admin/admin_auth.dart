import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class AdminAuthPage extends StatefulWidget {
  @override
  _AdminAuthPageState createState() => _AdminAuthPageState();
}

class _AdminAuthPageState extends State<AdminAuthPage> {
  final _formKey = GlobalKey<FormState>();
  bool isLogin = true; // Toggle entre login/inscription

  String email = '';
  String password = '';
  String confirmPassword = '';

  Future<void> submitForm() async {
    final url = isLogin
        ? Uri.parse('https://presenceapi-production.up.railway.app/admin/login')
        : Uri.parse('https://presenceapi-production.up.railway.app/admin/register');

    final response = await http.post(url,
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'email': email,
          'password': password,
        }));

    final data = jsonDecode(response.body);

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(isLogin ? 'Connexion réussie' : 'Inscription réussie'),
      ));
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text(data['error'] ?? 'Erreur inconnue'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Connexion Admin' : 'Inscription Admin')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            children: [
              TextFormField(
                decoration: InputDecoration(labelText: 'Email'),
                onChanged: (val) => email = val,
              ),
              TextFormField(
                decoration: InputDecoration(labelText: 'Mot de passe'),
                obscureText: true,
                onChanged: (val) => password = val,
              ),
              if (!isLogin)
                TextFormField(
                  decoration: InputDecoration(labelText: 'Confirmer le mot de passe'),
                  obscureText: true,
                  onChanged: (val) => confirmPassword = val,
                ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  if (!isLogin && password != confirmPassword) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                      content: Text('Les mots de passe ne correspondent pas'),
                    ));
                    return;
                  }
                  submitForm();
                },
                child: Text(isLogin ? 'Se connecter' : 'S’inscrire'),
              ),
              TextButton(
                onPressed: () {
                  setState(() {
                    isLogin = !isLogin;
                  });
                },
                child: Text(isLogin
                    ? 'Créer un compte admin'
                    : 'Déjà un compte ? Se connecter'),
              )
            ],
          ),
        ),
      ),
    );
  }
}
