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
  List<int> idClothes = [];
  int currentStep = 0;
  bool isLoading = true;
  bool isFormVisible = false;
  String outfitName = '';
  int isPublic = 0;

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

  Future<void> postOutfit() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    final url = Uri.parse('https://mdc.silvy-leligois.fr/api/outfits');
    //print toutes les valeurs pour verif

    print(outfitName);
    print(isPublic);
    print(idClothes);

    final response = await http.post(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(<String, dynamic>{
        'name': outfitName,
        'is_public': 1,  // Conversion ici
        'clothing_ids': [1,2,3],
      }),
    );

    if (response.statusCode == 201) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Outfit créé avec succès!'),
          backgroundColor: Colors.black38,
        ),
      );

      Navigator.pop(context);
    } else {
      throw Exception('Failed to create outfit. Status code: ${response.statusCode} / $outfitName / $isPublic / $idClothes');
    }
  }


  @override
  Widget build(BuildContext context) {
    if (steps.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
          backgroundColor: Colors.transparent,
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        title: const Text('Créer une tenue'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (currentStep < steps.length)
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Text(
                steps[currentStep].name,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
            )
          else
            Expanded(
              child: Container(
                alignment: Alignment.center,
                padding: const EdgeInsets.all(16.0),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      //changer la taille du text
                      const Text(
                        'Donnez un nom à votre tenue et choisissez si vous voulez la rendre publique ou non.',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                      ),
                      const SizedBox(height: 16),
                      _buildForm(),
                    ],
                  ),
                ),
              ),
            ),
          if (currentStep < steps.length)
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
                              idClothes.add(clotheForCat[index].id); // Change ici
                              currentStep++;
                              fetchClothe(steps[currentStep].id);
                            });
                          } else {
                            setState(() {
                              idClothes.add(clotheForCat[index].id); // Change ici
                              currentStep++;
                            });
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
                                color: const Color.fromRGBO(79, 125, 88, 1), // Vert
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

  Widget _buildForm() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Theme(
          data: ThemeData(
            primaryColor: const Color.fromRGBO(79, 125, 88, 1), // Vert
            hintColor: const Color.fromRGBO(79, 125, 88, 1), // Vert
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                onChanged: (value) => outfitName = value,
                cursorColor: const Color.fromRGBO(79, 125, 88, 1), // Vert
                decoration: InputDecoration(
                  labelText: 'Nom',
                  labelStyle: const TextStyle(
                    color: Color.fromRGBO(79, 125, 88, 1), // Vert
                  ),
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(79, 125, 88, 1), // Vert
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(79, 125, 88, 1), // Vert
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(
                      color: Color.fromRGBO(79, 125, 88, 1), // Vert
                    ),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
              ),
              ListTile(
                title: const Text('Publique?'),
                leading: Radio(
                  activeColor: const Color.fromRGBO(79, 125, 88, 1), // Vert
                  value: 1,
                  groupValue: isPublic,
                  onChanged: (int? value) => setState(() => isPublic = value!),
                ),
              ),
              ListTile(
                title: const Text('Non-Publique?'),
                leading: Radio(
                  activeColor: const Color.fromRGBO(79, 125, 88, 1), // Vert
                  value: 0,
                  groupValue: isPublic,
                  onChanged: (int? value) => setState(() => isPublic = value!),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: const Color.fromRGBO(79, 125, 88, 1), // Vert
                ),
                onPressed: () {
                  if (outfitName.isNotEmpty && idClothes.length == 3) { // Assurez-vous que le nom de la tenue est défini et que 3 vêtements ont été sélectionnés
                    postOutfit();
                  } else {
                    print('Please fill in the outfit name and select 3 clothes before submitting.'); // Remplacez ceci par votre gestionnaire d'erreurs de choix
                  }
                },
                child: const Text(
                  'Créer la tenue',
                  style: TextStyle(color: Colors.white),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }


  // Méthode pour construire la sélection de vêtements
  Widget buildClotheSelection() {
    return GridView.builder(
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
                idClothes.add(clotheForCat[index].id);
                if (currentStep < steps.length - 1) {
                  setState(() {
                    currentStep++;
                    fetchClothe(steps[currentStep].id);
                  });
                } else {
                  // Afficher le formulaire lorsque les 3 vêtements ont été sélectionnés
                  if (idClothes.length == 3) {
                    setState(() {
                      isFormVisible = true;
                    });
                  }
                  // Faites quelque chose avec la sélection finale, par exemple, revenez à la page précédente
                  else {
                    Navigator.pop(context);
                  }
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
                      color: const Color.fromRGBO(79, 125, 88, 1),
                    ),
                  );
                },
              ),
            ),
          ],
        );
      },
    );
  }
}
