import 'package:flutter/material.dart';

import '../../main.dart';

class Register extends StatefulWidget {
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  final _formKey = GlobalKey<FormState>();

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

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
                      const SizedBox(height: 16.0),
                      _buildTextField(
                        controller: _passwordController,
                        labelText: 'Mot de passe',
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Merci de rentrer un mot de passe';
                          }
                          if (value.length < 6) {
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
                        onPressed: () {
                          if (_formKey.currentState!.validate()) {
                            // Add sign up logic here
                            Navigator.pushReplacement(
                              context,
                              MaterialPageRoute(builder: (context) => const MainWidget()),
                            );
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