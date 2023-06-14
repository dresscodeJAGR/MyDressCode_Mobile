import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:http/http.dart' as http;
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

  @override
  void initState() {
    super.initState();
    fetchOutfits();
  }

  fetchOutfits() async {
    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/outfits');
    var response = await http.get(url);

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var outfitsList = jsonResponse['outfits'];
      setState(() {
        outfits = outfitsList;
        isLoading = false;
      });
    } else {
      print('Failed to load outfits');
    }
  }

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
                primary: Colors.green,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text("Non"),
              style: TextButton.styleFrom(
                primary: Colors.red,
              ),
              onPressed: () {
                Navigator.of(context).pop();
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
      body: isLoading
          ? Center(child: CircularProgressIndicator())
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
        child: const Icon(Icons.add),
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
      ),
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
              children: outfit['clothings'].map<Widget>((clothing) {
                return Image.network(
                  clothing['real_url'],
                  width: imageSize,
                  height: imageSize,
                );
              }).toList(),
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => confirmationSuppression(index),
          ),
        ),
      ],
    );
  }
}