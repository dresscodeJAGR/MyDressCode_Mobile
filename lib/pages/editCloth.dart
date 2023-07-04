import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:http/http.dart';
import 'package:http_parser/http_parser.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';

import 'dressing.dart';

class Category {
  final int id;
  final String name;
  final List<Category> subcategories;

  Category({required this.id, required this.name, required this.subcategories});

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Category &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}

class Subcategory {
  final int id;
  final String name;

  Subcategory({
    required this.id,
    required this.name,
  });

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;

    return other is Subcategory &&
        other.id == id &&
        other.name == name;
  }

  @override
  int get hashCode => id.hashCode ^ name.hashCode;
}


class ColorOption {
  final int id;
  final String name;

  ColorOption({
    required this.id,
    required this.name,
  });

  @override
  String toString() {
    return 'ColorOption{id: $id, name: $name}';
  }
}

class Brand {
  final int id;
  final String name;

  Brand({
    required this.id,
    required this.name,
  });

  @override
  String toString() {
    return 'Brand{id: $id, name: $name}';
  }
}

class Size {
  final int id;
  final String name;

  Size({
    required this.id,
    required this.name,
  });

  @override
  String toString() {
    return 'Size{id: $id, name: $name}';
  }
}

class EditCloth extends StatefulWidget {
  final ClothData clothData;

  EditCloth({required this.clothData});

  @override
  _EditClothState createState() => _EditClothState();
}

class _EditClothState extends State<EditCloth> {
  final _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();

  bool _hasImage = false;
  bool isImageChanged = false;
  bool _loading = true;

  List<Category> _categories = [];
  Category? _selectedCategory;
  Category? _selectedSubcategory;

  List<ColorOption> _colors = [];
  ColorOption? _selectedColorOption;

  List<Brand> _brands = [];
  Brand? _selectedBrand;

  List<Size> _sizes = [];
  Size? _selectedSize;

  final ImagePicker _imagePicker = ImagePicker();
  XFile? _selectedImage;

  @override
  void initState() {
    super.initState();
    String clothId = widget.clothData.id.toString();
    fetchInitialData(clothId);
  }

  Future<void> fetchInitialData(String clothId) async {
    await Future.wait([
      fetchCategories(),
      fetchBrands(),
      fetchSizes(),
      fetchColors(),
    ]);
    await fetchEditCloth(clothId);
    if(mounted) {
      setState(() {
        _loading = false;
      });
    }
  }

  Future<void> fetchEditCloth(clothId) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/clothes/$clothId');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      print('200EditCloth');
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['clothing'] != null) {
        setState(() {
          _nameController.text = jsonResponse['clothing']['name'];
          _selectedCategory = Category(
            id: jsonResponse['clothing']['category']['parent_category']['id'],
            name: jsonResponse['clothing']['category']['parent_category']['name'],
            subcategories: [
              Category(
                id: jsonResponse['clothing']['category']['id'],
                name: jsonResponse['clothing']['category']['name'],
                subcategories: [], // Pas de sous-sous-catégories
              ),
            ],
          );
          _selectedSubcategory = _selectedCategory?.subcategories[0]; // Et on défini _selectedSubcategory comme la première (et seule) sous-catégorie de _selectedCategory

          int selectedColorId = jsonResponse['clothing']['color']['id'];
          _selectedColorOption = _colors.firstWhere((colorOption) => colorOption.id == selectedColorId);

          int selectedBrandId = jsonResponse['clothing']['brand']['id'];
          _selectedBrand = _brands.firstWhere((brand) => brand.id == selectedBrandId);

          int selectedSizeId = jsonResponse['clothing']['size']['id'];
          _selectedSize = _sizes.firstWhere((size) => size.id == selectedSizeId);


          _selectedImage = XFile(
            jsonResponse['clothing']['real_url'],
          );
          _hasImage = true;
        });
      }
    } else {
      throw Exception('Failed to load editCloth');
    }
  }

  Future<void> fetchCategories() async {
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
      print('200 Categories');
      var jsonData = json.decode(response.body);
      List<Category> categories = [];
      for (var categoryData in jsonData) {
        List<Category> subcategories = [];
        for (var subcategoryData in categoryData['category']) {
          subcategories.add(Category(
            id: subcategoryData['id'],
            name: subcategoryData['name'],
            subcategories: [],
          ));
        }
        categories.add(Category(
          id: categoryData['id'],
          name: categoryData['name'],
          subcategories: subcategories,
        ));
      }
      setState(() {
        _categories = categories;
      });
    } else {
      throw Exception('Failed to load categories');
    }
  }

  Future<void> fetchColors() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/colors');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      print('200 Colors');
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['colors'] != null) {
        List<ColorOption> colors = [];
        for (var colorData in jsonResponse['colors']) {
          colors.add(ColorOption(
            id: colorData['id'],
            name: colorData['name'],
          ));
        }
        if (mounted) { // Vérifie si le widget est monté avant d'appeler setState
          setState(() {
            _colors = colors;
            if (_colors.isNotEmpty) {
              _selectedColorOption = _colors[0]; // Initialise avec la première option de couleur
            }
          });
        }
      }
    } else {
      throw Exception('Failed to load colors');
    }
  }

  Future<void> fetchBrands() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/brands');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      print('200 Brands');
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['brands'] != null) {
        List<Brand> brands = [];
        for (var brand in jsonResponse['brands']) {
          brands.add(Brand(
            id: brand['id'],
            name: brand['name'],
          ));
        }
        setState(() {
          _brands = brands;
        });
      }
    } else {
      throw Exception('Failed to load brands');
    }
  }

  Future<void> fetchSizes() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/sizes');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );
    if (response.statusCode == 200) {
      print('200 Sizes');
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['sizes'] != null) {
        List<Size> sizes = [];
        for (var size in jsonResponse['sizes']) {
          sizes.add(Size(
            id: size['id'],
            name: size['name'],
          ));
        }
        setState(() {
          _sizes = sizes;
        });
      }
    } else {
      throw Exception('Failed to load sizes');
    }
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double imageWidth = screenWidth * 0.6;
    final double imageHeight = imageWidth;

    if (_loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(
            backgroundColor: Color.fromRGBO(79, 125, 88, 1),
            color: Color.fromRGBO(79, 125, 88, 1),
          ),
        ),
      );
    }else{
      return Scaffold(
        appBar: AppBar(
          backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
          title: const Text('Modifier un vêtement'),
          actions: [
            if (_hasImage && _formKey.currentState?.validate() == true && _selectedImage != null)
              IconButton(
                onPressed: submitForm,
                icon: const Icon(Icons.check),
              ),
          ],
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    decoration: const InputDecoration(
                      labelText: 'Nom du vêtement',
                      labelStyle: TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromRGBO(79, 125, 88, 1)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                    style: const TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
                    validator: (value) {
                      if (value!.isEmpty) {
                        return 'Veuillez entrer un nom';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Category>(
                    value: _selectedCategory,
                    decoration: const InputDecoration(
                      labelText: 'Catégorie',
                      labelStyle: TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromRGBO(79, 125, 88, 1)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                    style: const TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
                    items: _categories
                        .map((category) => DropdownMenuItem<Category>(
                      value: category,
                      child: Text(category.name),
                    ))
                        .toList(),
                    validator: (value) {
                      if (value == null) {
                        return 'Veuillez sélectionner une catégorie';
                      }
                      return null;
                    },
                    onChanged: (value) {
                      setState(() {
                        _selectedCategory = value;
                        _selectedSubcategory = null;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  if (_selectedCategory != null)
                    DropdownButtonFormField<Category>(
                      value: _selectedSubcategory,
                      decoration: const InputDecoration(
                        labelText: 'Sous-catégorie',
                        labelStyle: TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
                        enabledBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Color.fromRGBO(79, 125, 88, 1)),
                        ),
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.green),
                        ),
                      ),
                      style: const TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
                      items: _selectedCategory!.subcategories
                          .map((subcategory) => DropdownMenuItem<Category>(
                        value: subcategory,
                        child: Text(subcategory.name),
                      ))
                          .toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedSubcategory = value;
                        });
                      },
                    ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<ColorOption>(
                    value: _selectedColorOption,
                    decoration: const InputDecoration(
                      labelText: 'Couleur',
                      labelStyle: TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Color.fromRGBO(79, 125, 88, 1)),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.green),
                      ),
                    ),
                    style: const TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
                    items: _colors.map((colorOption) {
                      return DropdownMenuItem<ColorOption>(
                        value: colorOption, // Use existing reference
                        child: Text(colorOption.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        _selectedColorOption = value;
                      });
                    },
                  ),
                  const SizedBox(height: 16),
                  DropdownButtonFormField<Brand>(
                  value: _selectedBrand,
                  decoration: const InputDecoration(
                    labelText: 'Marque',
                    labelStyle: TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(79, 125, 88, 1)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                  style: const TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
                  items: _brands.map((brand) {
                    return DropdownMenuItem<Brand>(
                      value: brand,
                      child: Text(brand.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedBrand = value;
                    });
                  },
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<Size>(
                  value: _selectedSize,
                  decoration: const InputDecoration(
                    labelText: 'Taille',
                    labelStyle: TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Color.fromRGBO(79, 125, 88, 1)),
                    ),
                    focusedBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Colors.green),
                    ),
                  ),
                  style: const TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
                  items: _sizes.map((size) {
                    return DropdownMenuItem<Size>(
                      value: size,
                      child: Text(size.name),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _selectedSize = value;
                    });
                  },
                ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      ElevatedButton(
                        onPressed: () {
                          selectImage(ImageSource.camera);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromRGBO(79, 125, 88, 1),
                        ),
                        child: const Text(
                          'Prendre une photo',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                      const SizedBox(width: 16),
                      ElevatedButton(
                        onPressed: () {
                          selectImage(ImageSource.gallery);
                        },
                        style: ElevatedButton.styleFrom(
                          primary: const Color.fromRGBO(79, 125, 88, 1),
                        ),
                        child: const Text(
                          'Choisir une image',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  if (_selectedImage != null)
                    Center(
                      child: SizedBox(
                        width: imageWidth,
                        height: imageHeight,
                        child: _selectedImage!.path.startsWith('http')
                            ? Image.network(
                          _selectedImage!.path,
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
                        )
                            : Image.file(
                          File(_selectedImage!.path),
                          fit: BoxFit.cover,
                          errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                            return const Text('Une erreur est survenue lors du chargement de l\'image.');
                          },
                        ),
                      ),
                    ),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ),
      );
    }
  }

  void submitForm() async {
    String name = _nameController.text;
    int? category = _selectedSubcategory?.id;
    int? color = _selectedColorOption?.id;
    int? brand = _selectedBrand?.id;
    int? size = _selectedSize?.id;
    String clothId = widget.clothData.id.toString();

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var url = Uri.parse('https://mdc.silvy-leligois.fr/api/clothes/'
          '$clothId?name=$name'
          '&category_id=$category'
          '&color_id=$color'
          '&brand_id=$brand'
          '&size_id=$size');

      var request = http.MultipartRequest('PUT', url)
        ..headers.addAll(<String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        });

      if (isImageChanged) {
        List<int> fileBytes = await File(_selectedImage!.path).readAsBytes();
        http.MultipartFile multipartFile = http.MultipartFile.fromBytes(
          'image',
          fileBytes,
          filename: 'image.jpg',
          contentType: MediaType('image', 'jpeg'),
        );
        request.files.add(multipartFile);
      }


      var response = await http.Response.fromStream(await request.send());

      if (response.statusCode == 200) {
        print('200 modifier');
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Le vêtement "$name" a bien été mis à jour.'),
            backgroundColor: Colors.green,
          ),
        );
      } else {
        print(response.statusCode);
      }
    } catch (e) {
      print(e.toString());
    }
  }


  Future<void> selectImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      setState(() {
        _selectedImage = pickedFile;
        _hasImage = true;
        isImageChanged = true;
      });
    } catch (e) {
      print('Image selection error: $e');
    }
  }

}