import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import '../controller/auth.dart';
import 'page_map_bag.dart';
import 'page_map_pos.dart';
import 'page_map_pengguna.dart';
import 'page_map_petugas.dart';

class MapPage extends StatefulWidget {
  const MapPage({Key? key}) : super(key: key);

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  var db = FirebaseFirestore.instance;

  late Color _backgroundColor;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    _backgroundColor = Colors.blue; // Assign a default background color
    _preloadUserData(); // Preload user data
    super.initState();
  }

  void _preloadUserData() async {
    _userData = await Auth().getUserData();
    if (_userData != null) {
      final accountType = _userData!['accountType'];
      setState(() {
        if (accountType == 'pengguna') {
          _backgroundColor = Colors.teal;
        } else if (accountType == 'petugas') {
          _backgroundColor = Colors.orangeAccent;
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: FutureBuilder<Map<String, dynamic>?>(
          future: Auth().getUserData(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else {
              final userData = snapshot.data;
              final accountType = userData?['accountType'];

              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Pilih menu yang diinginkan',
                    style: TextStyle(fontSize: 30),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (accountType == 'pengguna')
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle button tap
                                _navigateToMappetugasPage(context);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(150, 150),
                                backgroundColor: _backgroundColor,
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.person_pin,
                                      size: 80, color: Colors.white),
                                  SizedBox(height: 8),
                                  Text('\nLokasi petugas',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (accountType == 'pengguna')
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle button tap
                                _navigateToMapPosPage(context);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(150, 150),
                                backgroundColor: _backgroundColor,
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.tour,
                                      size: 80, color: Colors.white),
                                  SizedBox(height: 8),
                                  Text('\nLokasi Pos',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (accountType == 'petugas')
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle button tap
                                _navigateToMapUserPage(context);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(150, 150),
                                backgroundColor: _backgroundColor,
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.hiking_outlined,
                                      size: 80, color: Colors.white),
                                  SizedBox(height: 8),
                                  Text('\nLokasi pengguna',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      if (accountType == 'petugas')
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle button tap
                                _navigateToMapPosPage(context);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(150, 150),
                                backgroundColor: _backgroundColor,
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.tour,
                                      size: 80, color: Colors.white),
                                  SizedBox(height: 8),
                                  Text('\nLokasi Pos',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (accountType == 'pengguna')
                        Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 8.0),
                            child: ElevatedButton(
                              onPressed: () {
                                // Handle button tap
                                _navigateToMapBagPage(context);
                              },
                              style: ElevatedButton.styleFrom(
                                minimumSize: const Size(150, 150),
                                backgroundColor: _backgroundColor,
                              ),
                              child: const Column(
                                children: [
                                  Icon(Icons.backpack,
                                      size: 80, color: Colors.white),
                                  SizedBox(height: 8),
                                  Text('\nLokasi Tas',
                                      textAlign: TextAlign.center,
                                      style: TextStyle(color: Colors.white)),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
                  ),
                ],
              );
            }
          },
        ),
      ),
    );
  }
}

void _navigateToMapBagPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MapBagPage()),
  );
}

void _navigateToMapUserPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MapUserPage()),
  );
}

void _navigateToMapPosPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MapPosPage()),
  );
}

void _navigateToMappetugasPage(BuildContext context) {
  Navigator.push(
    context,
    MaterialPageRoute(builder: (context) => const MappetugasPage()),
  );
}
