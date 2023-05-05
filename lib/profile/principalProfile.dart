import 'package:flutter/material.dart';
import 'package:mdc/profile/pages/favoris.dart';
import 'package:mdc/profile/pages/outfits.dart';

class PrincipalProfile extends StatefulWidget {
  const PrincipalProfile({super.key});

  @override
  _PrincipalProfileState createState() => _PrincipalProfileState();
}

class _PrincipalProfileState extends State<PrincipalProfile> {
  final double profileHeight = 144;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        elevation: 15,
        backgroundColor: Colors.white,
        actions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.settings,
              color: Colors.black38,
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
      child: const Text(
        'Prénom Nom',
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
          onPressed: () => {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrincipalProfile(),
                ))
          },
          child: const Icon(
            Icons.edit_outlined
          ),
        ),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            primary: const Color.fromRGBO(79, 125, 88, 1),
          ),
          onPressed: () => {
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const PrincipalProfile(),
                ))
          },
          child: const Icon(
            Icons.share_outlined
          ),
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20,
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
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 20,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }




}