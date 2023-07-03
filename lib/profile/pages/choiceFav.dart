import 'package:flutter/material.dart';
import 'package:mdc/profile/pages/favoris.dart';
import 'package:mdc/profile/pages/outfits.dart';
import 'package:mdc/profile/pages/utilisateurs.dart';

class ChoiceFav extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Favoris"),
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to User Favourite Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => Utilisateurs()),
                );
              },
              icon: const Icon(Icons.favorite, color: Colors.red),
              label: const Text("Utilisateur"),
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                minimumSize: const Size(250, 60), // Set button width and height here
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to Outfit Favourite Page
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const Favoris()),
                );
              },
              icon: const Icon(Icons.star, color: Colors.yellow),
              label: const Text("Outfits"),
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(32.0),
                ),
                minimumSize: const Size(250, 60), // Set button width and height here
              ),
            ),
          ],
        ),
      ),
    );
  }

}
