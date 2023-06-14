import 'package:flutter/material.dart';

class Dressing extends StatefulWidget {
  const Dressing({Key? key}) : super(key: key);

  @override
  _DressingState createState() => _DressingState();
}

class _DressingState extends State<Dressing> {
  String? selectedParentCategory;
  String? selectedChildCategory;

  @override
  void initState() {
    super.initState();
    selectedParentCategory = null;
    selectedChildCategory = null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        title: const Text('Dressing'),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Wrap(
              spacing: 8,
              runSpacing: 8,
              children: parentCategories.keys.map((parentCategory) {
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      selectedParentCategory = parentCategory;
                      selectedChildCategory = null;
                    });
                  },
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 80),
                    child: Card(
                      elevation: 2,
                      color: selectedParentCategory == parentCategory
                          ? Colors.green[400]
                          : Colors.grey[150],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: selectedParentCategory == parentCategory
                              ? Colors.green[400]!
                              : Colors.transparent,
                          width: 2,
                        ),
                      ),
                      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                        child: Center(
                          child: Text(
                            parentCategory,
                            style: const TextStyle(
                              fontWeight: FontWeight.w600,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),

          if (selectedParentCategory != null)
            Container(
              margin: EdgeInsets.only(left: MediaQuery.of(context).size.width * 0.05),
              width: MediaQuery.of(context).size.width * 0.4,
              child: const Divider(height: 24, thickness: 1, color: Colors.grey),
            ),

          if (selectedParentCategory != null)
            Padding(
              padding: const EdgeInsets.only(left: 8, bottom: 8, right: 8, top: 0),
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: parentCategories[selectedParentCategory]!
                    .keys
                    .map((childCategory) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        selectedChildCategory = childCategory;
                      });
                    },
                    child: Container(
                      constraints: const BoxConstraints(maxWidth: 120),
                      child: Card(
                        elevation: 2,
                        color: Colors.white,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(
                            color: selectedChildCategory == childCategory
                                ? Colors.green[400]!
                                : Colors.transparent,
                            width: 2,
                          ),
                        ),
                        margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                          child: Center(
                            child: Text(
                              childCategory,
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
            ),
          ),
          selectedChildCategory == null
              ? const Expanded(
            child: Center(
              child: Text("Vous n'avez pas sélectionné de catégorie"),
            ),
          ) : Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(8),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 0.8,
              ),
              itemCount: parentCategories[selectedParentCategory]![selectedChildCategory]!.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () => _openDialog(
                      context,
                      parentCategories[selectedParentCategory]![selectedChildCategory]![index],
                      'name',
                      'brand',
                      'category',
                      'color',
                      'cleanliness'
                  ),
                  child: Image.asset(
                    parentCategories[selectedParentCategory]![selectedChildCategory]![index],
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _openDialog(BuildContext context, String imageUrl, String name, String brand, String category, String color, String cleanliness) {
    final nameController = TextEditingController(text: name);
    final brandController = TextEditingController(text: brand);
    final categoryController = TextEditingController(text: category);
    final colorController = TextEditingController(text: color);
    final cleanlinessController = TextEditingController(text: cleanliness);

    bool isEditing = false;  // <-- Initialize it outside of the builder

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setState) {
            return AlertDialog(
              contentPadding: EdgeInsets.zero,
              content: Stack(
                children: [
                  Padding(
                    padding: EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          AspectRatio(
                            aspectRatio: 1.0,
                            child: Image.asset(imageUrl, fit: BoxFit.cover),
                          ),
                          SizedBox(height: 10),
                          if (isEditing)
                            TextFormField(
                              controller: nameController,
                              decoration: const InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.green)
                                  )
                              ),
                            )
                          else
                            Text('Nom: $name'),
                          if (isEditing)
                            TextFormField(
                              controller: brandController,
                              decoration: const InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.green)
                                  )
                              ),
                            )
                          else
                            Text('Marque: $brand'),
                          if (isEditing)
                            TextFormField(
                              controller: categoryController,
                              decoration: const InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.green)
                                  )
                              ),
                            )
                          else
                            Text('Catégorie: $category'),
                          if (isEditing)
                            TextFormField(
                              controller: colorController,
                              decoration: const InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.green)
                                  )
                              ),
                            )
                          else
                            Text('Couleur: $color'),
                          if (isEditing)
                            TextFormField(
                              controller: cleanlinessController,
                              decoration: const InputDecoration(
                                  focusedBorder: UnderlineInputBorder(
                                      borderSide: BorderSide(color: Colors.green)
                                  )
                              ),
                            )
                          else
                            Text('État de propreté: $cleanliness'),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 0,
                    right: 0,
                    child: IconButton(
                      icon: Icon(isEditing ? Icons.check : Icons.edit),
                      onPressed: () {
                        setState(() {
                          if (isEditing) {
                            name = nameController.text;
                            brand = brandController.text;
                            category = categoryController.text;
                            color = colorController.text;
                            cleanliness = cleanlinessController.text;
                            // Implement your update logic here
                          }
                          isEditing = !isEditing;
                        });
                      },
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }



  final Map<String, Map<String, List<String>>> parentCategories = {
    'Haut': {
      'T-shirts': [
        'assets/images/tshirt.png',
        'assets/images/tshirt.png',
        'assets/images/tshirt.png',
        'assets/images/tshirt.png',
      ],
      'Vestes': [
        'assets/images/tshirt1.png',
        'assets/images/tshirt2.png',
        'assets/images/tshirt3.png',
        'assets/images/tshirt3.png',
      ],
      'Chemises': [
        'assets/images/chemise1.png',
        'assets/images/chemise2.png',
        'assets/images/chemise3.png',
      ],
      'Polos': [
        'assets/images/polo1.png',
        'assets/images/polo2.png',
        'assets/images/polo3.png',
      ],
    },
    'Bas': {
      'Pantalons': [
        'assets/images/pantalon1.png',
        'assets/images/pantalon2.png',
        'assets/images/pantalon3.png',
      ],
      'Jeans': [
        'assets/images/jean1.png',
        'assets/images/jean2.png',
        'assets/images/jean3.png',
      ],
    }
  };

}