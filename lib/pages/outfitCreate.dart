import 'package:flutter/material.dart';

class OutfitCreate extends StatefulWidget {
  const OutfitCreate({Key? key}) : super(key: key);

  @override
  _OutfitCreateState createState() => _OutfitCreateState();
}


class _OutfitCreateState extends State<OutfitCreate> {
  List<String> steps = ['Hauts :', 'Bas :', 'Chaussures :'];
  int currentStep = 0;

  final List<String> hauts = [
    'assets/images/tshirt.png',
    'assets/images/tshirt.png',
    'assets/images/tshirt.png',
    'assets/images/tshirt.png',
    'assets/images/tshirt.png',
    'assets/images/tshirt.png',
    'assets/images/tshirt.png',
    'assets/images/tshirt.png',
    'assets/images/tshirt.png',
    'assets/images/tshirt.png',
    'assets/images/tshirt.png',
    'assets/images/tshirt.png',
    'assets/images/tshirt.png',
    'assets/images/tshirt.png',
    // ...
  ];

  final List<String> bas = [
    'assets/images/pantalon.png',
    'assets/images/pantalon.png',
    'assets/images/pantalon.png',
    // ...
  ];

  final List<String> chaussures = [
    'assets/images/chaussures.png',
    'assets/images/chaussures.png',
    'assets/images/chaussures.png',
    // ...
  ];

  int _getItemCount() {
    switch (currentStep) {
      case 0:
        return hauts.length;
      case 1:
        return bas.length;
      case 2:
        return chaussures.length;
      default:
        return 0;
    }
  }

  String _getImagePath(int index) {
    switch (currentStep) {
      case 0:
        return hauts[index];
      case 1:
        return bas[index];
      case 2:
        return chaussures[index];
      default:
        return '';
    }
  }

  @override
  Widget build(BuildContext context) {
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
              steps[currentStep],
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
              itemCount: _getItemCount(),
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    if (currentStep < steps.length - 1) {
                      setState(() {
                        currentStep++;
                      });
                    } else {
                      // Faites quelque chose avec la sélection finale, par exemple, revenez à la page précédente
                      Navigator.pop(context);
                    }
                  },
                  child: Image.asset(
                    _getImagePath(index),
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
}
