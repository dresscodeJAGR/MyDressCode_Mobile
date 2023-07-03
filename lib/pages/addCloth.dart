import 'dart:io';

import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mdc/pages/dressing.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http_parser/http_parser.dart';
import 'package:fluttertoast/fluttertoast.dart';

class Category {
  final int id;
  final String name;
  final List<Category> subcategories;

  Category({
    required this.id,
    required this.name,
    required this.subcategories,
  });
}

class Subcategory {
  final int id;
  final String name;

  Subcategory({
    required this.id,
    required this.name,
  });
}

class ColorOption {
  final int id;
  final String name;

  ColorOption({
    required this.id,
    required this.name,
  });
}

class Brand {
  final int id;
  final String name;

  Brand({
    required this.id,
    required this.name,
  });
}

class Size {
  final int id;
  final String name;

  Size({
    required this.id,
    required this.name,
  });
}

class AddCloth extends StatefulWidget {
  @override
  _AddClothState createState() => _AddClothState();
}

class _AddClothState extends State<AddCloth> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TextEditingController _nameController = TextEditingController();

  bool _hasImage = false;

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
    fetchCategories();
    fetchColors();
    fetchBrands();
    fetchSizes();
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
      print('200Categories');
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
      print('200Colors');
      var jsonResponse = json.decode(response.body);
      if (jsonResponse['colors'] != null) {
        List<ColorOption> colors = [];
        for (var colorData in jsonResponse['colors']) {
          colors.add(ColorOption(
            id: colorData['id'],
            name: colorData['name'],
          ));
        }
        setState(() {
          _colors = colors;
        });
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        title: const Text('Ajouter un vêtement'),
        actions: [
          if (_hasImage && _formKey.currentState != null && _formKey.currentState!.validate() && _selectedImage != null)

            IconButton(
              onPressed: submitForm,
              icon: Icon(Icons.check),
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
                      value: colorOption,
                      child: Text(colorOption.name),
                    );
                  }).toList(),
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner une couleur';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner une marque';
                    }
                    return null;
                  },
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
                  validator: (value) {
                    if (value == null) {
                      return 'Veuillez sélectionner une taille';
                    }
                    return null;
                  },
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
                      child: Image.file(
                        File(_selectedImage!.path),
                        fit: BoxFit.cover,
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


  void submitForm() async {
    // Effectuer la soumission du formulaire
    String name = _nameController.text;

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    try {
      var request = http.MultipartRequest('POST', Uri.parse('https://mdc.silvy-leligois.fr/api/clothes'));
      request.headers['Content-Type'] = 'application/json; charset=UTF-8';
      request.headers['Authorization'] = 'Bearer $token';

      request.fields['name'] = name;
      request.fields['is_dirty'] = '0';
      request.fields['color_id'] = _selectedColorOption!.id.toString();
      request.fields['brand_id'] = _selectedBrand!.id.toString();
      request.fields['category_id'] = _selectedSubcategory!.id.toString();
      request.fields['size_id'] = _selectedSize!.id.toString();

      if (_selectedImage != null) {
        var file = await http.MultipartFile.fromPath('image', _selectedImage!.path, contentType: MediaType('image', 'jpeg'));
        request.files.add(file);
      }

      var response = await request.send();

      if (response.statusCode == 201) {
        // Success
        print('Cloth added successfully');

        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Succès'),
              content: Text('Le vêtement "$name" a bien été ajouté.'),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context); // Ferme la boîte de dialogue
                    Navigator.pop(context); // Revient en arrière d'une page
                  },
                  child: Text('OK'),
                ),
              ],
            );
          },
        );




        // Reset the form
        _formKey.currentState!.reset();
        _nameController.clear();
        setState(() {
          _selectedCategory = null;
          _selectedSubcategory = null;
          _selectedColorOption = null;
          _selectedImage = null;
          _selectedBrand = null;
          _selectedSize = null;
        });
      }   else {
        // Erreur
        print('Échec de l\'ajout du vêtement. Erreur: ${response.reasonPhrase}');

        // Afficher un message d'erreur à l'utilisateur
        showDialog(
          context: context,
          builder: (context) {
            return AlertDialog(
              title: Text('Erreur'),
              content: Text('Échec de l\'ajout du vêtement. Veuillez réessayer.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: Text('OK'),
                ),
              ],
            );
          },
        );
      }
    } catch (e) {
      // Exception
      print('Échec de l\'ajout du vêtement. Exception: $e');

      // Afficher un message d'erreur à l'utilisateur
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Erreur'),
            content: Text('Échec de l\'ajout du vêtement. Veuillez réessayer.'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }

  Future<void> selectImage(ImageSource source) async {
    try {
      final pickedFile = await _imagePicker.pickImage(source: source);
      setState(() {
        _selectedImage = pickedFile;
        _hasImage = true;
      });
    } catch (e) {
      print('Image selection error: $e');
    }
  }

}
