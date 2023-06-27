import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class OutfitCreate extends StatefulWidget {
  const OutfitCreate({Key? key}) : super(key: key);

  @override
  _OutfitCreateState createState() => _OutfitCreateState();
}

class Category {
  final int id;
  final String name;

  Category({
    required this.id,
    required this.name,
  });
}

class ClotheForCat {
  final int id;
  final String image;

  ClotheForCat({
    required this.id,
    required this.image,
  });
}

class _OutfitCreateState extends State<OutfitCreate> {
  List<Category> steps = [];
  List<ClotheForCat> clotheForCat = [];
  int currentStep = 0;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    fetchCategory();
  }

  Future<void> fetchCategory() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/categories');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<Category> categories = [];
      for (var categoryData in jsonData) {
        int id = categoryData['id'];
        String name = categoryData['name'];
        categories.add(Category(id: id, name: name));
      }
      setState(() {
        steps = categories;
      });
      fetchClothe(steps[currentStep].id);
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> fetchClothe(int categoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/clothes/category/$categoryId');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      var jsonData = json.decode(response.body);
      List<ClotheForCat> fetchedClothes = [];
      for (var clotheData in jsonData['clothes']) {
        int id = clotheData['id'];
        String image = clotheData['real_url'];
        fetchedClothes.add(ClotheForCat(id: id, image: image));
      }
      setState(() {
        clotheForCat = fetchedClothes;
        isLoading = false;
      });
    } else {
      throw Exception('Failed to load clothe');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green), // Couleur verte
          backgroundColor: Colors.transparent, // Fond transparent
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        title: Text('Créer une tenue'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Text(
              steps[currentStep].name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
            ),
          ),
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: clotheForCat.length,
              itemBuilder: (context, index) {
                return Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        if (currentStep < steps.length - 1) {
                          setState(() {
                            currentStep++;
                            fetchClothe(steps[currentStep].id);
                          });
                        } else {
                          // Faites quelque chose avec la sélection finale, par exemple, revenez à la page précédente
                          Navigator.pop(context);
                        }
                      },
                      child: Image.network(
                        clotheForCat[index].image,
                        fit: BoxFit.cover,
                        loadingBuilder: (BuildContext context, Widget child, ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) {
                            return child;
                          }
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded / loadingProgress.expectedTotalBytes!
                                  : null,
                              color: Color.fromRGBO(79, 125, 88, 1), // Vert
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }

}
