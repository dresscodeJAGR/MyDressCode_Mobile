import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../home/home.dart';


class User {
  final String id;
  final String pseudo;
  final String realProfilePicture;

  User({required this.id, required this.pseudo, required this.realProfilePicture});
}

class Utilisateurs extends StatefulWidget {
  @override
  _UtilisateursState createState() => _UtilisateursState();
}

class _UtilisateursState extends State<Utilisateurs> {
  List<User> users = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchUsers();
  }

  Future<void> fetchUsers() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/community/favorized/users');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body)['users'];
      setState(() {
        users = jsonResponse.map((item) => User(
          id: item['id'].toString(),
          pseudo: item['pseudo'],
          realProfilePicture: item['real_profile_picture'] ?? 'assets/images/imgProfile.png',
        )).toList();

      });
    } else {
      print('Failed to load users from API with status code: ${response.statusCode}');
    }
    setState(() {
      isLoading = false;
    });
  }

  Future<void> unfavUser(User user) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/community/favorize/user/${user.id}');

    var response = await http.post(  // CHANGE THIS LINE
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      setState(() {
        users.remove(user);
      });
    } else {
      throw Exception('Failed to unfavorite user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Utilisateurs favoris"),
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
      ),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(79, 125, 88, 1)),
        ),
      )
          : users.isEmpty
          ? Center(child: Text("Pas d'utilisateurs favoris pour le moment", style: TextStyle(fontSize: 18)))
          : ListView.builder(
        itemCount: users.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => Home()), // Assurez-vous d'importer votre HomePage
              );
            },
            child: Card(
              elevation: 3,
              margin: const EdgeInsets.all(10),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10.0),
              ),
              child: Padding(
                padding: EdgeInsets.all(10.0),
                child: ListTile(
                  leading: SizedBox(
                    width: 55,
                    height: 55,
                    child: Stack(
                      fit: StackFit.expand,
                      children: [
                        Container(
                          child: users[index].realProfilePicture != null
                              ? Image.network(
                            users[index].realProfilePicture,
                            fit: BoxFit.cover,
                            loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                              if (loadingProgress == null) return child;
                              return Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(const Color.fromRGBO(79, 125, 88, 1)),
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              );
                            },
                            errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                              return Image.asset('assets/images/imgProfile.png', fit: BoxFit.cover);
                            },
                          )
                              : Image.asset('assets/images/imgProfile.png', fit: BoxFit.cover),
                        ),
                        if (users[index].realProfilePicture == null)
                          const Center(child: CircularProgressIndicator()),
                      ],
                    ),
                  ),
                  title: Text(
                    users[index].pseudo,
                    style: const TextStyle(fontSize: 20),
                  ),
                  trailing: GestureDetector(
                    onTap: () => confirmationSuppression(users[index]),
                    child: const Icon(
                      Icons.favorite,
                      color: Colors.red,
                      size: 30,
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  void confirmationSuppression(User user) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Retirer des favoris " + user.pseudo),
          content: Text("Êtes-vous sûr de vouloir retirer cet utilisateur de vos favoris?"),
          actions: [
            TextButton(
              child: const Text("Oui"),
              style: TextButton.styleFrom(
                primary: Colors.green,
              ),
              onPressed: () {
                unfavUser(user);   // Retire l'utilisateur des favoris
                Navigator.of(context).pop();  // Ferme la boîte de dialogue
              },
            ),
            TextButton(
              child: const Text("Non"),
              style: TextButton.styleFrom(
                primary: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();  // Ferme la boîte de dialogue
              },
            ),
          ],
        );
      },
    );
  }
}

