import 'package:flutter/material.dart';
import '../controller/auth.dart';
import 'page_map.dart';
import 'page_panic.dart';
import 'page_information.dart';
import 'page_message.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  late int _selectedIndex;
  late Color _backgroundColor;
  late Color _appBarColor;
  Map<String, dynamic>? _userData;

  final List<Widget> _widgetOptionspengguna = <Widget>[
    const InformationPage(),
    const MapPage(),
    const PanicPage(),
  ];

  final List<Widget> _widgetOptionspetugas = <Widget>[
    const MessagePage(),
    const MapPage(),
  ];

  List<Widget> get _widgetOptions {
    if (_userData != null) {
      final accountType = _userData!['accountType'];
      if (accountType == 'pengguna') {
        return _widgetOptionspengguna;
      } else if (accountType == 'petugas') {
        return _widgetOptionspetugas;
      }
    }
    // Default options if _userData is null or accountType is not recognized
    return _widgetOptionspengguna;
  }

  @override
  void initState() {
    _selectedIndex = 0; // Default page
    _backgroundColor = Colors.white70; // Default background color
    _appBarColor = Colors.white70; // Default app bar color
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
          _appBarColor = Colors.teal;
        } else if (accountType == 'petugas') {
          _backgroundColor = Colors.orangeAccent;
          _appBarColor = Colors.orangeAccent;
        }
      });
    }
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _title() {
    return const Text('Flutter TA');
  }

  Widget _signOutButton() {
    return IconButton(
      onPressed: signOut,
      icon: const Icon(Icons.logout),
    );
  }

  void signOut() async {
    await Auth().signOut();
    // Perform additional logout logic
    // ...
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: _title(),
        backgroundColor: _appBarColor,
        actions: [_signOutButton()],
      ),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: _backgroundColor,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        items: _userData != null && _userData!['accountType'] == 'petugas'
            ? const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.message),
                  label: "Message",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: "Map",
                ),
              ]
            : const [
                BottomNavigationBarItem(
                  icon: Icon(Icons.book),
                  label: "Informasi",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.map),
                  label: "Map",
                ),
                BottomNavigationBarItem(
                  icon: Icon(Icons.dangerous),
                  label: "Panic",
                ),
              ],
      ),
    );
  }
}
