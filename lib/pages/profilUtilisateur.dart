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
  List<Map<String, dynamic>> outfits = [];
  List<bool> _favoriteStars = [];
  List<bool> _favoriteOutfits = [];
  bool _isUserFavorized = false;


  @override
  void initState() {
    super.initState();
    getUserDatas().then((_) {
      setState(() {
        _favoriteStars = List.generate(nbOutfits, (index) => false);
      });
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
        user = Map<String, dynamic>.from(jsonData);
        setState(() {
          outfits = List<Map<String, dynamic>>.from((user['outfits'] as List).map((outfit) => Map<String, dynamic>.from(outfit)));
          isLoading = false;
          nbOutfits = user['outfits'].length;
          _favoriteOutfits = List<bool>.from(outfits.map((outfit) => outfit['is_favorized'] ?? false));
          _isUserFavorized = user['is_favorized'] ?? false;
        });
      } else {
        setState(() {
          isLoading = false;
        });
        throw Exception('Erreur de chargement des données de l\'utilisateur');
      }
    } catch (error) {
      throw Exception('Erreur lors de la requête HTTP : $error');
    }
  }

  Future<void> toggleFavoriteOutfit(int outfitId, int index) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/community/favorize/outfit/$outfitId');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'action': _favoriteStars[index] ? 'remove' : 'add',
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _favoriteStars[index] = !_favoriteStars[index];
      });
    } else if (response.statusCode == 404) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('L\'outfit n\'a pas été trouvé')),
      );
    }
    else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une erreur est survenue')),
      );
    }
  }

  void _toggleFavoriteStar(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Ajouter/Retirer des favoris"),
          content: _favoriteOutfits[index]
              ? const Text("Êtes-vous sûr de vouloir retirer cet outfit de vos favoris ?")
              : const Text("Êtes-vous sûr de vouloir ajouter cet outfit à vos favoris ?"),
          actions: [
            TextButton(
              child: const Text("Oui"),
              style: TextButton.styleFrom(
                primary: Colors.green, // Couleur du texte du bouton "Oui"
              ),
              onPressed: () {
                setState(() {
                  toggleFavoriteOutfit(outfits[index]['id'], index); // Toggle favorite outfit
                  _favoriteOutfits[index] = !_favoriteOutfits[index]; // Mettre à jour l'état du favori
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
  }

  void toggleFavoriteUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/community/favorize/user/${widget.userId}');
    var response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'action': _isUserFavorized ? 'remove' : 'add',
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _isUserFavorized = !_isUserFavorized;
      });
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Une erreur est survenue')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: buildAppBar(),
      body: isLoading
          ? const Center(
        child: CircularProgressIndicator(
          backgroundColor: Color.fromRGBO(79, 125, 88, 1),
          color: Color.fromRGBO(79, 125, 88, 1),
        ),
      )
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

  PreferredSizeWidget? buildAppBar() {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: AppBar(
        title: const Text(' Profil utilisateur '),
        elevation: 15,
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        actions: [
          IconButton(
            icon: Icon(
              _isUserFavorized ? Icons.favorite : Icons.favorite_border,
              color: _isUserFavorized ? Colors.red : Colors.white,
            ),
            onPressed: toggleFavoriteUser,
          ),
        ],
      ),
    );
  }



  Widget buildImageProfile() {
    String? profilePicture = user['real_profile_picture'];

    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
        child: Container(
          height: 170,
          width: 170,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
          ),
          child: profilePicture != null
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
                            ...clothings.map<Widget>((dynamic clothing) {
                              String imageUrl = clothing['real_url'] ?? '';
                              return _buildOutfitItem(imageUrl: imageUrl);
                            }).toList(),
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
                        _favoriteOutfits[index] ? Icons.star : Icons.star_border,
                        color: _favoriteOutfits[index] ? Colors.yellow : Colors.grey,
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
                  loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
                        color: const Color.fromRGBO(79, 125, 88, 1),
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
