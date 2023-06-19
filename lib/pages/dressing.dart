import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'addCloth.dart';

class Category {
  final int id;
  final String name;
  final String image;
  final String createdAt;
  final String updatedAt;
  final List<SubCategory> subCategories;

  Category({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.subCategories,
  });

  factory Category.fromJson(Map<String, dynamic> json) {
    var list = json['category'] as List;
    List<SubCategory> subCategoryList =
    list.map((i) => SubCategory.fromJson(i)).toList();

    return Category(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      subCategories: subCategoryList,
    );
  }
}

class SubCategory {
  final int id;
  final String name;
  final String image;
  final String createdAt;
  final String updatedAt;
  final int parentCategoryId;

  SubCategory({
    required this.id,
    required this.name,
    required this.image,
    required this.createdAt,
    required this.updatedAt,
    required this.parentCategoryId,
  });

  factory SubCategory.fromJson(Map<String, dynamic> json) {
    return SubCategory(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      createdAt: json['created_at'],
      updatedAt: json['updated_at'],
      parentCategoryId: json['parent_category_id'],
    );
  }
}

class Cloth {
  final int id;
  final String name;
  final String image;
  final bool isDirty;
  final int userId;
  final int colorId;
  final int brandId;
  final int categoryId;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int sizeId;
  final String realUrl;
  final String categoryName;
  final String brandName;
  final String colorName;
  final String sizeName;

  Cloth({required this.id, required this.name, required this.image, required this.isDirty, required this.userId, required this.colorId, required this.brandId, required this.categoryId, required this.createdAt, required this.updatedAt, required this.sizeId, required this.realUrl, required this.categoryName, required this.brandName, required this.colorName, required this.sizeName});

  factory Cloth.fromJson(Map<String, dynamic> json) {
    return Cloth(
      id: json['id'],
      name: json['name'],
      image: json['image'],
      isDirty: json['is_dirty'],
      userId: json['user_id'],
      colorId: json['color_id'],
      brandId: json['brand_id'],
      categoryId: json['category_id'],
      createdAt: DateTime.parse(json['created_at']),
      updatedAt: DateTime.parse(json['updated_at']),
      sizeId: json['size_id'],
      realUrl: json['real_url'],
      categoryName: json['category']?['name'] ?? 'Non spécifié',
      brandName: json['brand']?['name'] ?? 'Non spécifié',
      colorName: json['color']?['name'] ?? 'Non spécifié',
      sizeName: json['size']?['name'] ?? 'Non spécifié',
    );
  }
}

class Dressing extends StatefulWidget {
  const Dressing({Key? key}) : super(key: key);

  @override
  _DressingState createState() => _DressingState();
}

class _DressingState extends State<Dressing> {
  List<Category>? categories;
  List<SubCategory> subCategories = [];

  String? selectedCategory;

  String? selectedCategoryId;
  String? selectedSubCategoryId;

  bool isLoading = false;

  List<Cloth>? _clothes;

  File? _image;

  final _formKey = GlobalKey<FormState>();

  @override
  void initState() {
    super.initState();
    chercherCategories();
    print('init');
  }

  Future<void> chercherCategories() async {
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
    print(response.statusCode);
    if (response.statusCode == 200) {
      setState(() {
        isLoading = true;
      });
      print('200Dressing');
      var jsonResponse = jsonDecode(response.body);
      setState(() {
        categories = (jsonResponse as List)
            .map((item) => Category.fromJson(item))
            .toList();
      });
      setState(() {
        isLoading = false;
      });
    }  else {
      print('Failed to load categories');
    }
  }

  Future<List<Cloth>> fetchClothes(int categoryId) async {
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
      print('200Clothes');
      var data = jsonDecode(response.body);
      if (data['clothes'] != null) {
        var clothesList = data['clothes'] as List;
        _clothes = clothesList.map((i) => Cloth.fromJson(i)).cast<Cloth>().toList();
      }

      // Introduce an artificial delay
      await Future.delayed(const Duration(seconds: 2));

      return _clothes!;
    } else {
      throw Exception('Failed to load clothes');
    }
  }

  Future<List<Cloth>> fetchSubCategoryClothes(int subCategoryId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/clothes/sub-category/$subCategoryId');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      print('200SubCategoryClothes');
      var data = jsonDecode(response.body);
      if (data['clothes'] != null) {
        var clothesList = data['clothes'] as List;
        _clothes = clothesList.map((i) => Cloth.fromJson(i)).cast<Cloth>().toList();
      }

      // Introduce an artificial delay
      await Future.delayed(const Duration(seconds: 2));

      return _clothes!;
    } else {
      throw Exception('Failed to load sub-category clothes');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        title: const Text('Dressing'),
        actions: <Widget>[
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              // Ouvrir la page d'ajout de vêtement
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCloth()),
              );
            },
          )
        ],
      ),
      body: Column(
        children: <Widget>[
          const Padding(
            padding: EdgeInsets.all(8.0),
            child: Text(
              'Catégories',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Wrap(
            alignment: WrapAlignment.start,
            spacing: 8.0, // space between rows
            runSpacing: 4.0, // space between lines
            children: categories!.map((category) {
              return SizedBox(
                width: 120.0,
                height: 40.0,
                child: ElevatedButton(
                  onPressed: () async {
                    List<Cloth> clothes = await fetchClothes(category.id);
                    setState(() {
                      _clothes = clothes;
                      subCategories = category.subCategories;
                      selectedCategoryId = category.id.toString();
                      selectedSubCategoryId = null; // Reset the selected sub-category
                    });
                    selectedCategory = category.name.toLowerCase();
                  },
                  style: ElevatedButton.styleFrom(
                    primary: selectedCategoryId == category.id.toString() // Use toString() if id is int
                        ? Colors.white
                        : const Color.fromRGBO(79, 125, 88, 1),
                    onPrimary: selectedCategoryId == category.id.toString() // Use toString() if id is int
                        ? const Color.fromRGBO(79, 125, 88, 1)
                        : Colors.white,
                    side: const BorderSide(
                      color: Color.fromRGBO(79, 125, 88, 1),
                    ),
                  ),
                  child: Text(
                    category.name,
                    style: const TextStyle(fontSize: 16.0),
                  ),
                ),
              );
            }).toList(),
          ),
          const Padding(
            padding: EdgeInsets.all(8.0),
          ),
          const Divider(
            height: 10,
            thickness: 1.5,
            indent: 20,
            endIndent: 20,
          ),
          const Padding(padding: EdgeInsets.all(8.0)),
          if (subCategories.isNotEmpty)
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8.0, // space between rows
              runSpacing: 4.0, // space between lines
              children: subCategories.map((subCategory) {
                return SizedBox(
                  width: 120.0,
                  height: 40.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      List<Cloth> clothes = await fetchSubCategoryClothes(subCategory.id);
                      setState(() {
                        _clothes = clothes;
                        selectedSubCategoryId = subCategory.id.toString();
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: selectedSubCategoryId == subCategory.id.toString() // Use toString() if id is int
                          ? Colors.white
                          : const Color.fromRGBO(79, 125, 88, 1),
                      onPrimary: selectedSubCategoryId == subCategory.id.toString() // Use toString() if id is int
                          ? const Color.fromRGBO(79, 125, 88, 1)
                          : Colors.white,
                      side: const BorderSide(
                        color: Color.fromRGBO(79, 125, 88, 1),
                      ),
                    ),
                    child: Text(
                      subCategory.name,
                      style: const TextStyle(fontSize: 16.0),
                    ),
                  ),
                );
              }).toList(),
            ),
          const Padding(padding: EdgeInsets.all(8.0)),
          if (_clothes == null)
            const Expanded(
              child: Center(child: Text('Vous n\'avez pas sélectionné de catégorie')),
            )
          else if (_clothes!.isEmpty)
            const Expanded(
              child: Center(child: Text('Pas de vêtement dans cette catégorie')),
            )
          else
            Flexible(
              child: GridView.builder(
                itemCount: _clothes?.length ?? 0, // Nombre total d'éléments
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Nombre d'éléments par ligne
                  childAspectRatio: 1, // Ratio pour la taille des éléments
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          return AlertDialog(
                            content: SingleChildScrollView(
                              child: ListBody(
                                children: <Widget>[
                                  Hero(
                                    tag: 'popupImage${_clothes![index].id}',
                                    child: Image.network(_clothes![index].realUrl, fit: BoxFit.cover),
                                  ),
                                  SizedBox(height: 20),
                                  Text(
                                    'Nom : ${_clothes![index].name}',
                                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Catégorie : ${_clothes![index].categoryName}',
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Marque : ${_clothes![index].brandName}',
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Couleur : ${_clothes![index].colorName}',
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                  ),
                                  const SizedBox(height: 10),
                                  Text(
                                    'Taille : ${_clothes![index].sizeName}',
                                    style: TextStyle(fontSize: 16, color: Colors.grey[600]),
                                  ),
                                ],
                              ),
                            ),
                            actions: <Widget>[
                              TextButton(
                                child: const Text(
                                  'Fermer',
                                  style: TextStyle(
                                    color: Color.fromRGBO(79, 125, 88, 1),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ],
                          );
                        },
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Container(
                        decoration: BoxDecoration(
                          image: DecorationImage(
                            image: NetworkImage(_clothes![index].realUrl),
                            fit: BoxFit.cover,
                          ),
                        ),
                        child: Image.network(
                          _clothes![index].realUrl,
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
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }
}