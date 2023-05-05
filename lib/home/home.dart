import 'package:flutter/material.dart';
import 'package:mdc/pages/rechercheUtilisateur.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userName = "Guilhem";

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        title: const Text('Accueil'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Bonjour ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: userName,
                      style: const TextStyle(
                        color: Color.fromRGBO(79, 125, 88, 1),
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const TextSpan(
                      text: ', comment allez-vous ?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 16),
              Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16.0),
                ),
                elevation: 4.0,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Sélection du jour',
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          _buildOutfitItem( imageUrl: 'assets/images/tshirt.png' ),
                          _buildOutfitItem( imageUrl: 'assets/images/pantalon.png' ),
                          _buildOutfitItem( imageUrl: 'assets/images/chaussures.png' ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToRechercheUtilisateur,
                  child: const Text('Rechercher un utilisateur'),
                  style: ElevatedButton.styleFrom(
                    primary: Color.fromRGBO(79, 125, 88, 1),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRechercheUtilisateur() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RechercheUtilisateur()),
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
