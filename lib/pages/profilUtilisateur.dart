import 'package:flutter/material.dart';

class ProfilUtilisateur extends StatefulWidget {
  final Map<String, dynamic> user;
  const ProfilUtilisateur({Key? key, required this.user}) : super(key: key);

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
          Padding(
            padding: const EdgeInsets.only(left: 10),
            child: Stack(
              children: [
                const Text(
                  "Mes outfits préférés",
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                Positioned(
                  top: 22, // Espacement entre le texte et le soulignement
                  left: 0,
                  child: Container(
                    width: 300, // Largeur du soulignement
                    height: 5, // Épaisseur du soulignement
                    color: const Color.fromRGBO(79, 125, 88, 1), // Couleur du soulignement
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ...(user['outfits'] ?? []).map<Widget>((outfit) {
            return Card(
              elevation: 5,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              child: Padding(
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

