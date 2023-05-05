import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';

class Favoris extends StatefulWidget {
  const Favoris({Key? key}) : super(key: key);

  @override
  _FavorisState createState() => _FavorisState();
}

class _FavorisState extends State<Favoris> {
  int _current = 0;
  List<bool> _favoriteStars = List.generate(3, (index) => true);
  List<bool> _favoriteColors = List.generate(3, (index) => true);

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
                    _favoriteColors[index] = !_favoriteColors[index];
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
        _favoriteColors[index] = !_favoriteColors[index];
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        title: const Text("Favoris"),
      ),
      body: Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CarouselSlider.builder(
                  itemCount: 3, // Le nombre d'outfits à afficher
                  itemBuilder: (context, index, realIndex) {
                    return _buildOutfit(constraints.maxHeight * 1,
                        index); // Passez l'index à la fonction _buildOutfit
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
              children: List.generate(3, (index) {
                return Container(
                  width: _current == index ? 16.0 : 12.0,
                  height: _current == index ? 16.0 : 12.0,
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  // Réduisez la marge ici
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _current == index
                        ? Color.fromRGBO(79, 125, 88, 1)
                        : Color.fromRGBO(79, 125, 88, 0.4),
                  ),
                );
              }),
            ),
          ),
        ],
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
                Image.asset('assets/images/tshirt.png', width: imageSize,
                    height: imageSize),
                Image.asset('assets/images/pantalon.png', width: imageSize,
                    height: imageSize),
                Image.asset('assets/images/chaussures.png', width: imageSize,
                    height: imageSize),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: Icon(
              _favoriteStars[index] ? Icons.star : Icons.star_border,
              color: _favoriteColors[index] ? Colors.yellow : null,
            ),
            onPressed: () => _toggleFavoriteStar(index),
          ),
        ),
      ],
    );
  }
}