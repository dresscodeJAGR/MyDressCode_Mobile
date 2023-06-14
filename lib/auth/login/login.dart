import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:mdc/auth/register/register.dart';

import '../../main.dart';

class Login extends StatefulWidget {
  const Login({Key? key}) : super(key: key);

  @override
  _LoginState createState() => _LoginState();
}

class _LoginState extends State<Login> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  String _response = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        title: const Text("Connexion" ),
      ),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Card(
                margin: const EdgeInsets.all(16.0),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                  side: BorderSide(color: Colors.grey.withOpacity(0.5)),
                ),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Connexion',
                        style: TextStyle(
                          fontSize: 24.0,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(
                        controller: _emailController,
                        labelText: 'Email',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Merci de rentrer votre email';
                          }
                          if (!value.contains('@')) {
                            return 'Rentrer un email valide';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        controller: _passwordController,
                        labelText: 'Mot de passe',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Merci d'entrer votre mot de passe";
                          }
                          if (value.length < 8) {
                            return 'Votre mot de passe est trop court';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              var url = Uri.parse('https://mdc.silvy-leligois.fr/api/login');
                              var response = await http.post(
                                url,
                                headers: <String, String>{
                                  'Content-Type': 'application/json; charset=UTF-8',
                                },
                                body: jsonEncode(<String, String>{
                                  'email': _emailController.text,
                                  'password': _passwordController.text,
                                }),
                              );

                              setState(() {
                                _response = response.statusCode.toString();
                              });

                              if (response.statusCode == 201) {
                                var jsonResponse = jsonDecode(response.body);
                                String token = jsonResponse['token'];

                                SharedPreferences prefs = await SharedPreferences.getInstance();
                                await prefs.setString('token', token);

                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MainWidget()),
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Mauvais identifiant ou mot de passe')),
                                );
                              }
                            }catch (e) {
                              print('Erreur lors de la connexion: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Une erreur s\'est produite lors de la connexion. Veuillez réessayer.')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromRGBO(79, 125, 88, 1),
                        ),
                        child: const Text("Se connecter"),
                      ),
                      TextButton(
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => Register()),
                          );
                        },
                        child: const Text(
                          "Créer un compte",
                          style: TextStyle(
                            color: Color.fromRGBO(79, 125, 88, 1),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    bool obscureText = false,
    required FormFieldValidator<String> validator,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      validator: validator,
      decoration: InputDecoration(
        labelText: labelText,
        enabledBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(79, 125, 88, 1)),
        ),
        focusedBorder: const OutlineInputBorder(
          borderSide: BorderSide(color: Color.fromRGBO(79, 125, 88, 1)),
        ),
        labelStyle: const TextStyle(
          color: Colors.black26,
        ),
      ),
      cursorColor: const Color.fromRGBO(79, 200, 88, 1),
    );
  }
}
