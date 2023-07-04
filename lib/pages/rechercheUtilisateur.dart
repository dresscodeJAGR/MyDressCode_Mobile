import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:mdc/pages/profilUtilisateur.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../home/home.dart';

class User {
  final int id;
  final String pseudo;
  final String email;
  final String profilePicture;

  User({required this.id, required this.pseudo, required this.email, required this.profilePicture});

  Map<String, String> toMap() {
    return {
      'id': this.id.toString(),
      'pseudo': this.pseudo,
      'email': this.email,
      'image': this.profilePicture,
    };
  }
}

class RechercheUtilisateur extends StatefulWidget {
  const RechercheUtilisateur({Key? key}) : super(key: key);

  @override
  _RechercheUtilisateurState createState() => _RechercheUtilisateurState();
}

class _RechercheUtilisateurState extends State<RechercheUtilisateur> {
  String searchQuery = '';
  List<Map<String, String>> userList = []; // Define the variable here

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    print('fetchUsers');
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/community/users');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body)['users'];
      List<Map<String, String>> users = [];
      for (var userData in jsonData) {
        int id = userData['id'];
        String pseudo = userData['pseudo'];
        String email = userData['email'];
        if (userData['real_profile_picture'] == null) {
          userData['real_profile_picture'] = 'assets/images/imgProfile.png';
        }
        String profilePicture = userData['real_profile_picture'];
        User user = User(id: id, pseudo: pseudo, email: email, profilePicture: profilePicture);
        users.add(user.toMap());
      }
      setState(() {
        userList = users; // Update userList
        print("userList: '$userList'");
      });
    } else {
      throw Exception('Failed to load users');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        title: const Text('Rechercher un utilisateur'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: (value) {
                setState(() {
                  searchQuery = value;
                });
              },
              cursorColor: const Color.fromRGBO(79, 125, 88, 1),
              style: const TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
              decoration: InputDecoration(
                labelText: 'Rechercher',
                labelStyle: const TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
                prefixIcon: const Icon(Icons.search, color: Color.fromRGBO(79, 125, 88, 1)),
                fillColor: const Color.fromRGBO(79, 125, 88, 0.1),
                filled: true,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color.fromRGBO(79, 125, 88, 1)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12.0),
                  borderSide: const BorderSide(color: Color.fromRGBO(79, 125, 88, 1)),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: userList.length,
              itemBuilder: (context, index) {
                if (searchQuery.isEmpty || userList[index]['pseudo']!.toLowerCase().contains(searchQuery.toLowerCase())) {
                  return _buildUserCard(userList[index]);
                } else {
                  return const SizedBox.shrink();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserCard(Map<String, String> user) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ProfilUtilisateur(
              userId: int.parse(user['id']!),
            ),
          ),
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
          height: 120.0,
          child: Row(
            children: [
              Container(
                width: 100.0,
                height: 100.0,
                decoration: BoxDecoration(
                  border: Border.all(
                    color: Color.fromRGBO(79, 125, 88, 1),
                    width: 5.0,
                  ),
                  borderRadius: BorderRadius.circular(50.0),
                  image: DecorationImage(
                    image: (user['image'] == 'assets/images/imgProfile.png'
                        ? AssetImage(user['image']!)
                        : NetworkImage(user['image']!)) as ImageProvider<Object>,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 16.0),
              Expanded(
                child: Center(
                  child: Text(
                    user['pseudo']!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
