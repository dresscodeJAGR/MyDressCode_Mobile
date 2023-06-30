import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class ProfilUtilisateur extends StatefulWidget {
  final int userId;
  const ProfilUtilisateur({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilUtilisateurState createState() => _ProfilUtilisateurState();
}

class _ProfilUtilisateurState extends State<ProfilUtilisateur> {
  Map<String, dynamic> user = {};
  bool isLoading = true;
  int nbOutfits = 0;
  List<bool> _favoriteStars = [];

  @override
  void initState() {
    super.initState();
    getUserDatas().then((_) {
      _favoriteStars = List.generate(nbOutfits, (index) => false);
    });
  }

  Future<void> getUserDatas() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/community/users/${widget.userId}');

    try {
      final response = await http.get(url, headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token'
      });
      if (response.statusCode == 200) {
        var jsonData = json.decode(response.body)['user'];
        setState(() {
          user = Map<String, dynamic>.from(jsonData);
          isLoading = false;
          nbOutfits = user['outfits'].length;
        });
        print(user);
      } else {
        isLoading = false;
        throw Exception('Erreur de chargement des données de l\'utilisateur');
      }
    } catch (error) {
      throw Exception('Erreur lors de la requête HTTP : $error');
    }
  }

  void _toggleFavoriteStar(int index) {
    if (_favoriteStars[index]) {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Retirer des favoris"),
            content: const Text("Êtes-vous sûr de vouloir retirer cet outfit de vos favoris ?"),
            actions: [
              TextButton(
                child: const Text("Oui"),
                style: TextButton.styleFrom(
                  primary: Colors.green, // Couleur du texte du bouton "Oui"
                ),
                onPressed: () {
                  setState(() {
                    _favoriteStars[index] = !_favoriteStars[index];
                  });
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
              ),
              TextButton(
                child: const Text("Non"),
                style: TextButton.styleFrom(
                  primary: Colors.red, // Couleur du texte du bouton "Non"
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Fermer la boîte de dialogue
                },
              ),
            ],
          );
        },
      );
    } else {
      setState(() {
        _favoriteStars[index] = !_favoriteStars[index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 15,
        backgroundColor: Colors.white,
      ),
      body: isLoading
      ? Center(child: CircularProgressIndicator(),)
      : SingleChildScrollView(
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 30,
            ),
            buildImageProfile(),
            buildName(),
            const SizedBox(
              height: 50,
            ),
            buildOutfits(),
          ],
        ),
      ),
    );
  }

  Widget buildImageProfile() {
    String profilePicture = user['real_profile_picture'];

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
        child: Container(
          height: 170,
          width: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),),
            child: profilePicture.isNotEmpty
                ? Image.network(profilePicture, fit: BoxFit.contain)
                : Image.asset('assets/images/imgProfile.png', fit: BoxFit.contain),
          ),
        ),
      );
  }

  Widget buildName() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Text(
        '${user['pseudo'] ?? ''}',
        textAlign: TextAlign.center,
        style: const TextStyle(
          color: Colors.black,
          letterSpacing: 1,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildOutfits() {
    final outfits = user['outfits'] ?? [];
    final outfitsList = outfits is List ? outfits : [outfits];

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ...
          const SizedBox(height: 10),
          ...outfitsList
              .asMap()
              .entries
              .where((MapEntry<int, dynamic> entry) => entry.key < _favoriteStars.length)
              .map<Widget>((MapEntry<int, dynamic> entry) {
            int index = entry.key;
            Map<String, dynamic> outfit = entry.value;
            List<dynamic> clothings = outfit['clothings'] ?? [];

            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Stack(
                children: [
                  Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          outfit['name'] ?? '',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ...clothings
                                .map<Widget>((dynamic clothing) {
                              String imageUrl = clothing['real_url'] ?? '';
                              return _buildOutfitItem(imageUrl: imageUrl);
                            })
                                .toList(),
                          ],
                        ),
                        const SizedBox(height: 10),
                      ],
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(
                        _favoriteStars[index] ? Icons.star : Icons.star_border,
                        color: _favoriteStars[index] ? Colors.yellow : Colors.grey,
                      ),
                      onPressed: () => _toggleFavoriteStar(index),
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
          const SizedBox(height: 20),
        ],
      ),
    );
  }



  Widget _buildOutfitItem({required String imageUrl}) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}

