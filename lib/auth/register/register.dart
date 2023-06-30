import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../main.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pseudoController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _response = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        title: const Text("S'enregistrer"),
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
                        'Enregistrement',
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
                            return "Merci de rentrer un email";
                          }
                          if (!value.contains('@')) {
                            return "Merci de rentrer un email valide";
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 20.0),
                      _buildTextField(
                        controller: _pseudoController,
                        labelText: 'Pseudo',
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return "Merci de rentrer un pseudo";
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
                            return 'Merci de rentrer un mot de passe';
                          }
                          if (value.length < 8) {
                            return 'Votre mot de passe doit faire minimum 6 caractères';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        controller: _confirmPasswordController,
                        labelText: 'Confirmer le mot de passe',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Merci de confirmer le mot de passe';
                          }
                          if (value != _passwordController.text) {
                            return 'Les mots de passe ne correspondent pas';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16.0),
                      ElevatedButton(
                        onPressed: () async {
                          if (_formKey.currentState!.validate()) {
                            try {
                              var url = Uri.parse('https://mdc.silvy-leligois.fr/api/register');
                              var response = await http.post(
                                url,
                                headers: <String, String>{
                                  'Content-Type': 'application/json; charset=UTF-8',
                                },
                                body: jsonEncode(<String, String>{
                                  'email': _emailController.text,
                                  'pseudo': _pseudoController.text,
                                  'password': _passwordController.text,
                                  'password_confirmation': _confirmPasswordController.text,
                                  'description': _descriptionController.text,
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

                                Navigator.pushAndRemoveUntil(
                                  context,
                                  MaterialPageRoute(builder: (context) => const MainWidget()),
                                      (Route<dynamic> route) => false,
                                );
                              } else {
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Une erreur est survenue. Veuillez réessayer.')),
                                );
                              }
                            }catch (e) {
                              print('Erreur lors de l\'enregistrement: $e');
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Une erreur s\'est produite lors de l\'enregistrement. Veuillez réessayer.')),
                              );
                            }
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromRGBO(79, 125, 88, 1),
                        ),
                        child: const Text("S'enregistrer"),
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