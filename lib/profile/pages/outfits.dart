import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../pages/outfitCreate.dart';

class Outfits extends StatefulWidget {
  const Outfits({Key? key}) : super(key: key);

  @override
  _OutfitsState createState() => _OutfitsState();
}

class _OutfitsState extends State<Outfits> {
  int _current = 0;
  List outfits = [];
  bool isLoading = true;
  Map<String, bool> retryImages = {};

  @override
  void initState() {
    super.initState();
    fetchOutfits();
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
      var outfitsList = jsonResponse['outfits'];
      setState(() {
        outfits = outfitsList;
        isLoading = false;
      });
    } else {
      print('Failed to load outfits');
      setState(() {
        isLoading = false;
      });
    }
  }

  void deleteOutfit(int outfitId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/outfits/$outfitId');
    var response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      print('Outfit deleted');
      fetchOutfits();
    } else {
      print('Failed to delete outfit');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        title: const Text("Mes outfits"),
      ),
        body: isLoading
            ? const Center(child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Color.fromRGBO(79, 125, 88, 1)),
        ))
            : outfits.isEmpty
            ? Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text("Vous n'avez pas encore de tenue, voulez-vous en créer une ?"),
              const SizedBox(height: 20.0),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromRGBO(79, 125, 88, 1),
                  onPrimary: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(32.0),
                  ),
                ),
                child: const Text('Créer une tenue'),
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const OutfitCreate(),
                    ),
                  );
                },
              ),
            ],
          ),
        )
            : Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return CarouselSlider.builder(
                    itemCount: outfits.length,
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
                children: outfits.map<Widget>((outfit) {
                  int index = outfits.indexOf(outfit);
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
                }).toList(),
              ),
            ),
          ],
        ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const OutfitCreate(),
            ),
          );
        },
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        child: const Icon(Icons.add),
      ),
    );
  }

  void confirmationSuppression(int index, String outfitName, int id) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Supprimer l'outfit $outfitName"),
          content: const Text("Êtes-vous sûr de vouloir supprimer cet outfit ?"),
          actions: [
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.green,
              ),
              onPressed: () {
                deleteOutfit(outfits[index]['id']);  // Delete the outfit
                Navigator.of(context).pop();  // Close the dialog box
              },
              child: const Text("Oui"),
            ),
            TextButton(
              style: TextButton.styleFrom(
                primary: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();  // Close the dialog box
              },
              child: const Text("Non"),
            ),
          ],
        );
      },
    );
  }

  Widget _buildOutfit(double height, int index) {
    double imageSize = height * 0.25; // 25% de la hauteur disponible
    var outfit = outfits[index];

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
                Text(
                  outfit['name'],
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                ...outfit['clothings'].map<Widget>((clothing) {
                  return Stack(
                    alignment: Alignment.center,
                    children: [
                      Container(
                        width: imageSize,
                        height: imageSize,
                        color: Colors.transparent,
                      ),
                      Image.network(
                        clothing['real_url'],
                        width: imageSize,
                        height: imageSize,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return SizedBox(
                            width: imageSize,
                            height: imageSize,
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
                        errorBuilder: (context, error, stackTrace) {
                          if (!retryImages.containsKey(clothing['real_url']) || !retryImages[clothing['real_url']]!) {
                            retryImages[clothing['real_url']] = true;
                            Future.delayed(const Duration(seconds: 2), () {
                              setState(() {});
                            });
                          }
                          return SizedBox(
                            width: imageSize,
                            height: imageSize,
                            child: const Icon(Icons.error),
                          );
                        },
                      ),
                    ],
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
            icon: const Icon(Icons.close),
            onPressed: () => confirmationSuppression(index, outfit['name'], outfit['id']),
          ),
        ),
      ],
    );
  }

}