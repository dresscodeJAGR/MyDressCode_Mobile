import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mdc/profile/pages/choiceFav.dart';
import 'package:mdc/profile/pages/favoris.dart';
import 'package:mdc/profile/pages/outfits.dart';
import 'package:mdc/profile/pages/settings.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';

class PrincipalProfile extends StatefulWidget {
  const PrincipalProfile({super.key});

  @override
  _PrincipalProfileState createState() => _PrincipalProfileState();
}

class _PrincipalProfileState extends State<PrincipalProfile> {
  final double profileHeight = 144;
  String userName = "";
  String userImageUrl = "";
  bool loadError = false;
  int key = 0;
  String newPseudo = "";

  bool isEditing = false;
  final TextEditingController nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchUser();
  }

  fetchUser() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/user');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var user = jsonResponse;
      setState(() {
        userName = user['pseudo'];
        userImageUrl = user['real_profile_picture'];
        nameController.text = userName;
      });
    } else {
      // Handle error case
      print('Failed to load user');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        title: const Text('Profil'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.white,
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Settings(),
                ),
              );
            },
          )
        ],
      ),
      body: SingleChildScrollView(  // wrap Column with SingleChildScrollView
        child: Column(
          children: <Widget>[
            const SizedBox(
              height: 30,
            ),
            Container(
              child: buildImageProfile(),
            ),
            Container(
              child: buildName(),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
              child: buildButtons(),
            ),
            Container(
              margin: const EdgeInsets.fromLTRB(0, 50, 0, 0),
              child: buildButtonsRouting(),
            ),
          ],
        ),
      ),
    );
  }

  Widget buildImageProfile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
        child: GestureDetector(
          onTap: () {
            setState(() {
              key = key + 1;
            });
          },
          child: SizedBox(
            key: Key(key.toString()),
            height: 200,
            width: 200,
            child: ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: userImageUrl.isNotEmpty
                  ? Image.network(
                userImageUrl,
                fit: BoxFit.contain,
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
                errorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
                  fetchUser();
                  return Container(); // Return an empty container
                },
              )
                  : Image.asset('assets/images/imgProfile.png', fit: BoxFit.contain),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildName() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          isEditing
              ? Flexible(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.8,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      cursorColor: const Color.fromRGBO(79, 125, 88, 1),
                      style: const TextStyle(
                        color: Colors.black,
                        letterSpacing: 1,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                      controller: nameController,
                      onSubmitted: (_) => editPseudo(),
                      decoration: InputDecoration(
                        labelText: 'Changer de pseudo',
                        labelStyle: TextStyle(color: Color.fromRGBO(79, 125, 88, 1)),
                        border: OutlineInputBorder(),
                        enabledBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromRGBO(79, 125, 88, 1), width: 2.0),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderSide: BorderSide(color: Color.fromRGBO(79, 125, 88, 1), width: 2.0),
                        ),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.check),
                    onPressed: editPseudo,
                  ),
                ],
              ),
            ),
          )
              : Text(
            userName,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.black,
              letterSpacing: 1,
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          if (!isEditing)
            IconButton(
              icon: Icon(Icons.edit),
              onPressed: startEditing,
            ),
        ],
      ),
    );
  }

  Widget buildButtons() {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: MediaQuery.of(context).size.width * 0.05),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(right: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white, // Fond blanc
                  onPrimary: const Color.fromRGBO(79, 125, 88, 1), // Texte en vert
                  minimumSize: const Size(0, 40), // Ajuster la hauteur des boutons
                  side: const BorderSide(
                    color: const Color.fromRGBO(79, 125, 88, 1),// Bordure verte
                  ),
                ),
                onPressed: () => pickImage(),
                child: const Text(
                  'Modifier',
                  style: TextStyle(
                    fontSize: 16, // Augmenter la taille de la police
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            flex: 1,
            child: Padding(
              padding: const EdgeInsets.only(left: 10),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  primary: Colors.white, // Fond blanc
                  onPrimary: const Color.fromRGBO(79, 125, 88, 1),// Texte en vert
                  minimumSize: const Size(0, 40), // Ajuster la hauteur des boutons
                  side: const BorderSide(
                    color: const Color.fromRGBO(79, 125, 88, 1), // Bordure verte
                  ),
                ),
                onPressed: () async {
                  // Remplacez par le message et le lien que vous voulez partager
                  const String message = "Mon pseudonyme sur MyDressCode:";
                  final String url = userName;

                  await Share.share("$message $url");
                },
                child: const Text(
                  'Partager profil',
                  style: TextStyle(
                    fontSize: 16, // Augmenter la taille de la police
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget buildButtonsRouting() {
    return SizedBox(
      width: MediaQuery.of(context).size.width * 0.8,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: const Color.fromRGBO(79, 125, 88, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChoiceFav(),
                ),
              ),
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Favoris",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 30,
                ),
              ],
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              primary: const Color.fromRGBO(79, 125, 88, 1),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              padding: const EdgeInsets.symmetric(vertical: 12),
            ),
            onPressed: () => {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const Outfits(),
                ),
              ),
            },
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                SizedBox(
                  width: 8,
                ),
                Text(
                  "Outfits",
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 30,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Future<void> pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      await uploadImage(pickedFile.path);
    }
  }

  Future<void> uploadImage(String imagePath) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/user');

    var request = http.MultipartRequest('PUT', url)
      ..headers.addAll(<String, String>{
        'Content-Type': 'multipart/form-data',
        'Authorization': 'Bearer $token',
      })
      ..files.add(
        await http.MultipartFile.fromPath('image', imagePath),
      );

    var response = await request.send();
    if (response.statusCode == 201) {
      print('Uploaded!');
      fetchUser();
    } else {
      print('Failed to upload image' + response.statusCode.toString());
    }
  }

  void startEditing() {
    setState(() {
      isEditing = true;
    });
  }


  Future<void> editPseudo() async {
    // Obtenir le SharedPreferences pour accéder au token
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

      String newPseudo = nameController.text;

      if (newPseudo.isNotEmpty) {
      var url = Uri.parse('https://mdc.silvy-leligois.fr/api/user');

      var response = await http.put(
        url,
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(<String, String>{
          'pseudo': newPseudo,
        }),
      );

      if (response.statusCode == 201) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Pseudonyme modifié'),
            backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
          ),
        );
        setState(() {
          userName = newPseudo;
          isEditing = false;
        });
      } else {
        print('Failed to update pseudonym. Status code: ' + response.statusCode.toString());
      }
    }
  }
}