import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:mdc/profile/pages/favoris.dart';
import 'package:mdc/profile/pages/outfits.dart';
import 'package:share_plus/share_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;

class PrincipalProfile extends StatefulWidget {
  const PrincipalProfile({super.key});

  @override
  _PrincipalProfileState createState() => _PrincipalProfileState();
}

class _PrincipalProfileState extends State<PrincipalProfile> {
  final double profileHeight = 144;
  String userName = "";

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
      });

      print('Username: $userName');
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
            onPressed: () => {

            },
          )
        ],
      ),
      body: Column(
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
    );
  }

  Widget buildImageProfile() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(0, 30, 0, 10),
        child: Container(
          height: 170,
          width: 170,
          decoration: BoxDecoration(
              image: const DecorationImage(
                image: AssetImage('assets/images/imgProfile.png'),
                fit: BoxFit.fill,
              ),
              borderRadius: BorderRadius.circular(20)),
        ),
      ),
    );
  }

  Widget buildName() {
    return SizedBox(
      width: MediaQuery.of(context).size.width,
      child: Text(
        userName,
        textAlign: TextAlign.center,
        style: TextStyle(
          color: Colors.black,
          letterSpacing: 1,
          fontSize: 28,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget buildButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color.fromRGBO(79, 125, 88, 1),
          ),
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const PrincipalProfile(),
              ),
            );
          },
          child: const Icon(Icons.edit_outlined),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color.fromRGBO(79, 125, 88, 1),
          ),
          onPressed: () async {
            // Remplacez par le message et le lien que vous voulez partager
            const String message = "Mon pseudonyme sur MyDressCode:";
            final String url = "Nom Prenom";

            await Share.share("$message $url");
          },
          child: const Icon(Icons.share_outlined),
        ),
      ],
    );
  }

  Widget buildButtonsRouting() {
    return Container(
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
                  builder: (context) => const Favoris(),
                ),
              ),
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
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
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: const [
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

}