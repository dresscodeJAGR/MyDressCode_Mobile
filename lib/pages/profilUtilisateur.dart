import 'package:flutter/material.dart';

class ProfilUtilisateur extends StatefulWidget {
  final int userId; // Définir userId comme variable de la classe
  const ProfilUtilisateur({Key? key, required this.userId}) : super(key: key);

  @override
  _ProfilUtilisateurState createState() => _ProfilUtilisateurState();
  }

class _ProfilUtilisateurState extends State<ProfilUtilisateur> {
  Map<String, dynamic> user = {
    "id": "123",
    "firstName": "Prénom",
    "lastName": "Nom",
    "email": "prenom.nom@example.com",
    "profileImage": "assets/images/imgProfile.png",
    "favorites": [
      {
        "id": "1",
        "title": "Article préféré 1",
        "description": "Description de l'article préféré 1",
      },
      {
        "id": "2",
        "title": "Article préféré 2",
        "description": "Description de l'article préféré 2",
      },
    ],
    "outfits": [
      {
        "id": "1",
        "title": "Outfit 1",
        "description": "Description de l'outfit 1",
        "images": [
          "assets/images/tshirt.png",
          "assets/images/pantalon.png",
          "assets/images/chaussures.png",
        ],
      },
      {
        "id": "2",
        "title": "Outfit 2",
        "description": "Description de l'outfit 2",
        "images": [
          "assets/images/tshirt.png",
          "assets/images/pantalon.png",
          "assets/images/chaussures.png",
        ],
      },
      {
        "id": "3",
        "title": "Outfit 3",
        "description": "Description de l'outfit 3",
        "images": [
          "assets/images/tshirt.png",
          "assets/images/pantalon.png",
          "assets/images/chaussures.png",
        ],
      },
    ],
  };

  List<bool> _favoriteStars = List.generate(3, (index) => false);

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
      body: SingleChildScrollView(
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
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
        child: Container(
          height: 170,
          width: 170,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage(
                  '${user['profileImage']}' ?? 'assets/images/imgProfile.png'),
              fit: BoxFit.fill,
            ),
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }

  Widget buildName() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Text(
        '${user['firstName'] ?? ''} ${user['lastName'] ?? ''}',
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
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ...
          const SizedBox(height: 10),
          ...(user['outfits'] ?? []).asMap().entries.map<Widget>((entry) {
            int index = entry.key;
            Map<String, dynamic> outfit = entry.value;
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
                          outfit['title'] ?? '',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            ...(outfit['images'] ?? []).map<Widget>((imageUrl) {
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
                        _favoriteStars[index] ? Icons.favorite : Icons.favorite_border,
                        color: _favoriteStars[index] ? Colors.red : Colors.grey,
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
                child: Image.asset(
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

