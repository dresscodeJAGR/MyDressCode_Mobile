import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mdc/pages/editCloth.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'addCloth.dart';

class ClothData {
  final int id;
  final String name;
  final String categoryName;
  final String brandName;
  final String colorName;
  final String sizeName;

  ClothData({
    required this.id,
    required this.name,
    required this.categoryName,
    required this.brandName,
    required this.colorName,
    required this.sizeName,
  });
}

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
    var subCategoryList = <SubCategory>[];

    if (json.containsKey('category')) {
      var list = json['category'] as List<dynamic>;
      subCategoryList = list.map((item) => SubCategory.fromJson(item)).toList();
    }

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
      image: json['image'] ?? '',
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

  Cloth({
    required this.id,
    required this.name,
    required this.image,
    required this.isDirty,
    required this.userId,
    required this.colorId,
    required this.brandId,
    required this.categoryId,
    required this.createdAt,
    required this.updatedAt,
    required this.sizeId,
    required this.realUrl,
    required this.categoryName,
    required this.brandName,
    required this.colorName,
    required this.sizeName,
  });

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
  int? categoryId;
  int? subCategoryId;

  List<Category>? categories;
  List<SubCategory> subCategories = [];

  String? selectedCategory;

  String? selectedCategoryId;
  String? selectedSubCategoryId;

  bool isLoading = true;

  List<Cloth>? _clothes;

  @override
  void initState() {
    super.initState();
    fetchInitialData();
    print('init');
  }

  Future<void> fetchInitialData() async {
    try {
      await fetchCategories();
      print('try after fetchCategories');
      if (categories != null && categories!.isNotEmpty) {
        await fetchClothes(categories![0].id);
        setState(() {
          selectedCategoryId = categories![0].id.toString();
          categoryId = categories![0].id;
          subCategories = categories![0].subCategories;
          isLoading = false;
        });
      } else {
        setState(() {
          //initialise categorie avec des données de test
          categories = [];
          isLoading = false;
        });
      }
      print(categories);
    } catch (error) {
      print('Error fetching initial data: $error');
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchCategories() async {
    try {
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
        print('200 categories ');
        var jsonResponse = jsonDecode(response.body) as List<dynamic>?;
        if (jsonResponse != null) {
          setState(() {
            categories = jsonResponse.map((item) => Category.fromJson(item)).toList();
          });
        } else {
          print('Response body is null');
        }
      } else {
        print('Failed to load categories. Status code: ${response.statusCode}');
        print('Response body: ${response.body}');
      }
    } catch (error, stackTrace) {
      print('Error fetching categories: $error');
      print('Stack trace: $stackTrace');
    }
  }

  Future<List<Cloth>> fetchClothes(int categoryId) async {
    try {
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
        var data = jsonDecode(response.body);
        if (data['clothes'] != null) {
          var clothesList = data['clothes'] as List;
          _clothes = clothesList.map((i) => Cloth.fromJson(i)).cast<Cloth>().toList();
        }

        return _clothes!;
      } else {
        throw Exception('Failed to load clothes');
      }
    } catch (error) {
      print('Error fetching clothes: $error');
      throw Exception('Failed to load clothes');
    }
  }

  Future<List<Cloth>> fetchSubCategoryClothes(int subCategoryId) async {
    try {
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
        var data = jsonDecode(response.body);
        if (data['clothes'] != null) {
          var clothesList = data['clothes'] as List;
          _clothes = clothesList.map((i) => Cloth.fromJson(i)).cast<Cloth>().toList();
        }

        return _clothes!;
      } else {
        throw Exception('Failed to load sub-category clothes');
      }
    } catch (error) {
      print('Error fetching sub-category clothes: $error');
      throw Exception('Failed to load sub-category clothes');
    }
  }

  deleteCloth(int clothId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    print(clothId);
    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/outfits/$clothId');
    var response = await http.delete(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cloth deleted successfully.')),
      );
    } else {
      print('Failed to delete cloth' + response.statusCode.toString());
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
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddCloth()),
              ).then((_) async {
                await fetchInitialData();
                if (selectedCategoryId != null) {
                  await fetchClothes(int.parse(selectedCategoryId!));
                }
                if (selectedSubCategoryId != null) {
                  await fetchSubCategoryClothes(int.parse(selectedSubCategoryId!));
                }
              });
            },
          )
        ],
      ),
      body: isLoading
          ? Center(
        child: CircularProgressIndicator(),
      )
          : Column(
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
            spacing: 8.0,
            runSpacing: 4.0,
              children: categories?.map((category) {
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
                        categoryId = category.id;
                        subCategoryId = null;
                      });
                      selectedCategory = category.name.toLowerCase();
                    },
                    style: ElevatedButton.styleFrom(
                      primary: selectedCategoryId == category.id.toString()
                          ? Colors.white
                          : const Color.fromRGBO(79, 125, 88, 1),
                      onPrimary: selectedCategoryId == category.id.toString()
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
              }).toList() ?? []
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
              spacing: 8.0,
              runSpacing: 4.0,
              children: subCategories.map((subCategory) {
                return SizedBox(
                  width: 120.0,
                  height: 40.0,
                  child: ElevatedButton(
                    onPressed: () async {
                      List<Cloth> clothes =
                      await fetchSubCategoryClothes(subCategory.id);
                      setState(() {
                        _clothes = clothes;
                        selectedSubCategoryId = subCategory.id.toString();
                        subCategoryId = subCategory.id;
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      primary: selectedSubCategoryId == subCategory.id.toString()
                          ? Colors.white
                          : const Color.fromRGBO(79, 125, 88, 1),
                      onPrimary: selectedSubCategoryId == subCategory.id.toString()
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
                itemCount: _clothes?.length ?? 0,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  childAspectRatio: 1,
                ),
                itemBuilder: (BuildContext context, int index) {
                  return GestureDetector(
                    onTap: () {
                      showDialog(
                        context: context,
                        builder: (BuildContext context) {
                          ClothData clothData = ClothData(
                            id: _clothes![index].id,
                            name: _clothes![index].name,
                            categoryName: _clothes![index].categoryName,
                            brandName: _clothes![index].brandName,
                            colorName: _clothes![index].colorName,
                            sizeName: _clothes![index].sizeName,
                          );
                          return AlertDialog(
                            content: SingleChildScrollView(
                              child: Column(
                                children: <Widget>[
                                  Container(
                                    alignment: Alignment.centerRight,
                                    child: TextButton(
                                      child: const Icon(
                                        Icons.close,
                                        color: Color.fromRGBO(79, 125, 88, 1),
                                      ),
                                      onPressed: () {
                                        Navigator.of(context).pop();
                                      },
                                    ),
                                  ),
                                  Hero(
                                    tag: 'popupImage${_clothes![index].id}',
                                    child: Image.network(
                                      _clothes![index].realUrl,
                                      fit: BoxFit.cover,
                                    ),
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
                                  'Modifier',
                                  style: TextStyle(
                                    color: Color.fromRGBO(79, 125, 88, 1),
                                  ),
                                ),
                                onPressed: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => EditCloth(
                                        clothData: clothData,
                                      ),
                                    ),
                                  );
                                },
                              ),
                              TextButton(
                                child: const Text(
                                  'Supprimer',
                                  style: TextStyle(
                                    color: Colors.red,
                                  ),
                                ),
                                onPressed: () {
                                  deleteCloth(_clothes![index].id);
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
                          loadingBuilder: (BuildContext context, Widget child,
                              ImageChunkEvent? loadingProgress) {
                            if (loadingProgress == null) {
                              return child;
                            }
                            return Center(
                              child: CircularProgressIndicator(
                                value: loadingProgress.expectedTotalBytes != null
                                    ? loadingProgress.cumulativeBytesLoaded /
                                    loadingProgress.expectedTotalBytes!
                                    : null,
                                color: Color.fromRGBO(79, 125, 88, 1),
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
