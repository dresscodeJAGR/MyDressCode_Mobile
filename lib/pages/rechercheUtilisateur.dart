import 'package:flutter/material.dart';
import 'package:mdc/pages/profilUtilisateur.dart';

import '../home/home.dart';

class RechercheUtilisateur extends StatefulWidget {
  const RechercheUtilisateur({Key? key}) : super(key: key);

  @override
  _RechercheUtilisateurState createState() => _RechercheUtilisateurState();
}

class _RechercheUtilisateurState extends State<RechercheUtilisateur> {
  String searchQuery = '';

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
                if (searchQuery.isEmpty || userList[index]['name']!.toLowerCase().contains(searchQuery.toLowerCase())) {
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
                user: user,
              ),
            ),
          );
        },
    child: Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
        leading: CircleAvatar(
          backgroundImage: AssetImage(user['image']!),
          radius: 24.0,
          backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        ),
        title: Text(
          user['name']!,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    ),
    );
  }

  List<Map<String, String>> userList = [
    {
      'name': 'Alice Johnson',
      'image': 'assets/images/user1.jpg',
    },
    {
      'name': 'Bob Martin',
      'image': 'assets/images/user2.jpg',
    },
    {
      'name': 'Cathy Smith',
      'image': 'assets/images/user3.jpg',
    },
    {
      'name': 'David Brown',
      'image': 'assets/images/user4.jpg',
    },
    {
      'name': 'Eva Turner',
      'image': 'assets/images/user5.jpg',
    },
    {
      'name': 'Frank Adams',
      'image': 'assets/images/user6.jpg',
    },
    {
      'name': 'Grace Thompson',
      'image': 'assets/images/user7.jpg',
    },
    {
      'name': 'Henry White',
      'image': 'assets/images/user8.jpg',
    },
    {
      'name': 'Irene Walker',
      'image': 'assets/images/user9.jpg',
    },
    {
      'name': 'Jack Taylor',
      'image': 'assets/images/user10.jpg',
    },
    {
      'name': 'Katie Green',
      'image': 'assets/images/user11.jpg',
    },
    {
      'name': 'Luke Hall',
      'image': 'assets/images/user12.jpg',
    },
    {
      'name': 'Mia Scott',
      'image': 'assets/images/user13.jpg',
    },
    {
      'name': 'Nathan Young',
      'image': 'assets/images/user14.jpg',
    },
    {
      'name': 'Olivia King',
      'image': 'assets/images/user15.jpg',
    },
  ];

}
