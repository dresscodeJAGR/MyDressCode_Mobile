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
                  return Image.asset(
                    parentCategories[selectedParentCategory]![selectedChildCategory]![index],
                    fit: BoxFit.cover,
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  final Map<String, Map<String, List<String>>> parentCategories = {
    'Haut': {
      'T-shirts': [
        'assets/images/tshirt1.png',
        'assets/images/tshirt2.png',
        'assets/images/tshirt3.png',
        'assets/images/tshirt3.png',
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