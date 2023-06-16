import 'package:flutter/material.dart';

class AccountManagementPage extends StatefulWidget {
  @override
  _AccountManagementPageState createState() => _AccountManagementPageState();
}

class _AccountManagementPageState extends State<AccountManagementPage> {
  final _passwordController = TextEditingController();
  final _newPasswordController = TextEditingController();
  final _usernameController = TextEditingController();
  String dropdownValue = 'Male';

  @override
  void dispose() {
    _passwordController.dispose();
    _newPasswordController.dispose();
    _usernameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Gestion du compte'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              TextFormField(
                controller: _usernameController,
                decoration: const InputDecoration(
                  labelText: 'Pseudo',
                ),
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                value: dropdownValue,
                onChanged: (String? newValue) {
                  setState(() {
                    dropdownValue = newValue!;
                  });
                },
                items: <String>['Male', 'Female', 'Prefer not to say']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                decoration: const InputDecoration(
                  labelText: 'Sexe',
                ),
              ),

              const SizedBox(height: 16.0),
              TextFormField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Mot de passe actuel',
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _newPasswordController,
                obscureText: true,
                decoration: const InputDecoration(
                  labelText: 'Nouveau mot de passe',
                ),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Implementez la logique de modification du mot de passe ici
                },
                child: const Text('Modifier le mot de passe'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Implementez la logique de suppression du compte ici
                },
                child: const Text('Supprimer le compte'),
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  // Implementez la logique d'exportation des données ici
                },
                child: const Text('Exporter les informations personnelles'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
