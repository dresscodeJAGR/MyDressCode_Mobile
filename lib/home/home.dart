import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:mdc/pages/rechercheUtilisateur.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';


class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  _HomeState createState() => _HomeState();
}

class _HomeState extends State<Home> {
  String userName = "";
  var dailyOutfit = [];
  bool isLoading = false;

  @override
  void initState() {
    super.initState();
    fetchUser();
    fetchDailyOutfit();
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
    } else {
      // Handle error case
      print('Failed to load user');
    }
  }

  fetchDailyOutfit() async {
    setState(() {
      isLoading = true;
    });

    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';

    var url = Uri.parse('https://mdc.silvy-leligois.fr/api/outfits/daily');
    var response = await http.get(
      url,
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      var jsonResponse = jsonDecode(response.body);
      var outfit = jsonResponse['outfit']['clothings'];
      setState(() {
        dailyOutfit = outfit;
        isLoading = false;   // Stop the loading indicator
      });

      print('Daily Outfit: $dailyOutfit');
    } else {
      // Handle error case
      print('Failed to load daily outfit');
    }
  }


  Row buildOutfitRow() {
    if (isLoading) {
      // Show loading indicator while the images are loading
      return Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          CircularProgressIndicator(
            color: Color.fromRGBO(79, 125, 88, 1),
          ),
        ],
      );
    } else {
      // Show the images when they have loaded
      List<Widget> items = [];
      for (var item in dailyOutfit) {
        items.add(_buildOutfitItem(imageUrl: item['real_url']));
      }
      return Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: items,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color.fromRGBO(79, 125, 88, 1),
        title: const Text('Accueil'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              RichText(
                text: TextSpan(
                  children: [
                    const TextSpan(
                      text: 'Bonjour ',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    TextSpan(
                      text: userName,
                      style: const TextStyle(
                        color: Color.fromRGBO(79, 125, 88, 1),
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const TextSpan(
                      text: ', comment allez-vous ?',
                      style: TextStyle(
                        color: Colors.black,
                        fontSize: 26,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              buildDailyOutfitCard(),  // Here we use the updated Card widget
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _navigateToRechercheUtilisateur,
                  style: ElevatedButton.styleFrom(
                    primary: const Color.fromRGBO(79, 125, 88, 1),
                    textStyle: const TextStyle(fontSize: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12.0),
                    ),
                  ),
                  child: const Text('Rechercher un utilisateur'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _navigateToRechercheUtilisateur() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const RechercheUtilisateur()),
    );
  }

  Widget _buildOutfitItem({required String imageUrl}) {
    return Flexible(
      child: Padding(
        padding: const EdgeInsets.all(4.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(16.0),
              child: AspectRatio(
                aspectRatio: 1,
                child: Image.network(
                  imageUrl,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Card buildDailyOutfitCard() {
    return Card(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      elevation: 4.0,
      child: Stack(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Sélection du jour',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                buildOutfitRow(),
              ],
            ),
          ),
          Positioned(
            top: 10,
            right: 10,
            child:
            IconButton(
              icon: const Icon(Icons.refresh),
              onPressed: _refreshDailyOutfit,
              color: const Color.fromRGBO(79, 125, 88, 1),
            ),
          ),
        ],
      ),
    );
  }


  void _refreshDailyOutfit() {
    setState(() {
      fetchDailyOutfit();
    });
  }
}
