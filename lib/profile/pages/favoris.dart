import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class Favoris extends StatefulWidget {
  const Favoris({Key? key}) : super(key: key);

  @override
  _FavorisState createState() => _FavorisState();
}

class _FavorisState extends State<Favoris> {
  int _current = 0;
  List<Map<String, dynamic>> outfits = [];
  bool isLoading = true;
  List<bool> _favoriteStars = [];
  List<bool> _favoriteColors = [];

  @override
  void initState() {
    super.initState();
    fetchOutfits();
    _favoriteStars = List.generate(outfits.length, (index) => true);
    _favoriteColors = List.generate(outfits.length, (index) => true);
  }

  fetchOutfits() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/outfits');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      List<dynamic> outfitsList = jsonResponse['outfits'];
      List<Map<String, dynamic>> outfitsMaps = outfitsList.map((outfit) => Map<String, dynamic>.from(outfit)).toList();

      setState(() {
        outfits = outfitsMaps;
        _favoriteStars = List.generate(outfits.length, (index) => true);
        _favoriteColors = List.generate(outfits.length, (index) => true);
        isLoading = false;
      });
    } else {
      print('Failed to load outfits');
      setState(() {
        isLoading = false;
      });
    }
  }

  void removeFavoriteOutfit(int outfitId, int index) async {
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
        'action': 'remove',
      }),
    );

    if (response.statusCode == 200) {
      print('Outfit removed from favorites');
      setState(() {
        outfits.removeAt(index);
        _favoriteStars.removeAt(index);
        _favoriteColors.removeAt(index);
      });
    } else {
      print('Failed to remove outfit from favorites');
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
                style: TextButton.styleFrom(
                  primary: Colors.green, // Text color of "Yes" button
                ),
                onPressed: () {
                  removeFavoriteOutfit(outfits[index]['id'], index);  // Remove the outfit from favorites
                  setState(() {
                    _favoriteStars[index] = !_favoriteStars[index];
                    _favoriteColors[index] = !_favoriteColors[index];
                  });
                  Navigator.of(context).pop(); // Close the dialog box
                },
                child: const Text("Oui"),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  primary: Colors.red, // Text color of "No" button
                ),
                onPressed: () {
                  Navigator.of(context).pop(); // Close the dialog box
                },
                child: const Text("Non"),
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
        title: const Text("Outfits favoris"),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(79, 125, 88, 1)),)
          )
          : Column(
        children: [
          Expanded(
            child: LayoutBuilder(
              builder: (context, constraints) {
                return CarouselSlider.builder(
                  itemCount: outfits.length, // The number of outfits to display
                  itemBuilder: (context, index, realIndex) {
                    return _buildOutfit(constraints.maxHeight * 1, index); // Pass the index to the _buildOutfit function
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
              children: List.generate(outfits.length, (index) {
                return Container(
                  width: _current == index ? 16.0 : 12.0,
                  height: _current == index ? 16.0 : 12.0,
                  margin: const EdgeInsets.symmetric(horizontal: 3.0),
                  // Reduce the margin here
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
    double imageSize = height * 0.25; // 25% of the available height
    var outfit = outfits[index];
    var clothings = outfit['clothings'].cast<Map<String, dynamic>>();
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
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 16.0),
                Text(
                  outfit['name'],
                  style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 16.0),
                ...outfit['clothings'].map<Widget>((clothing) {
                  return Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Image.network(
                          clothing['real_url'],
                          width: imageSize * 0.9,  // 90% de la taille originale
                          height: imageSize * 0.9, // 90% de la taille originale
                          loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return SizedBox(
                              width: imageSize * 0.9,  // 90% de la taille originale
                              height: imageSize * 0.9, // 90% de la taille originale
                              child: Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(const Color.fromRGBO(79, 125, 88, 1)),
                                  value: loadingProgress.expectedTotalBytes != null
                                      ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                      : null,
                                ),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  );
                }).toList(),
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