import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

import '../../pages/outfitCreate.dart';

class Outfits extends StatefulWidget {
  const Outfits({Key? key}) : super(key: key);

  @override
  _OutfitsState createState() => _OutfitsState();
}

class _OutfitsState extends State<Outfits> {
  int _current = 0;

  void confirmationSuppression(int index) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text("Supprimer l'outfit"),
          content: const Text("Êtes-vous sûr de vouloir supprimer cet outfit ?"),
          actions: [
            TextButton(
              child: const Text("Oui"),
              style: TextButton.styleFrom(
                primary: Colors.green, // Couleur du texte du bouton "Oui"
              ),
              onPressed: () {
                // Supprimer l'outfit ici
                // par exemple: outfits.removeAt(index);
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


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        title: const Text("Outfits"),
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CarouselSlider.builder(
                  itemCount: 5,
                  itemBuilder: (context, index, realIndex) {
                    return _buildOutfit(constraints.maxHeight * 1, index);
                  },
                  options: CarouselOptions(
                    height: constraints.maxHeight * 0.9,
                    viewportFraction: 0.65,
                    enlargeCenterPage: false,
                    enableInfiniteScroll: true,
                    autoPlay: false,
                    onPageChanged: (index, reason) {
                      setState(() {
                        _current = index;
                      });
                    },
                  ),
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.only(bottom: 30.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(5, (index) {
                return Container(
                  width: _current == index ? 16.0 : 12.0,
                  height: _current == index ? 16.0 : 12.0,
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index
                        ? const Color.fromRGBO(79, 125, 88, 1)
                        : const Color.fromRGBO(79, 125, 88, 0.4),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
      // ...
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OutfitCreate(),
            ),
          );
        },
        child: const Icon(Icons.add),
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
      ),
    );
  }
  Widget _buildOutfit(double height, int index) {
    double imageSize = height * 0.25; // 25% de la hauteur disponible
    return Stack(
      children: [
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 8.0),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: Colors.grey.withOpacity(0.5)),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Image.asset('assets/images/tshirt.png', width: imageSize, height: imageSize),
                Image.asset('assets/images/pantalon.png', width: imageSize, height: imageSize),
                Image.asset('assets/images/chaussures.png', width: imageSize, height: imageSize),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(
              Icons.close
            ),
            onPressed: () => confirmationSuppression(index),
          ),
        ),
      ],
    );
  }

}
