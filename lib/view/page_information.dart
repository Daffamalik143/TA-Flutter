import 'package:flutter/material.dart';
import '../model/menu_item.dart';
import 'page_infoItem.dart'; // Import the MenuItem class

class InformationPage extends StatefulWidget {
  const InformationPage({Key? key}) : super(key: key);

  @override
  State<InformationPage> createState() => _InformationPageState();
}

class _InformationPageState extends State<InformationPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Informasi terkait pendakian gunung di Indonesia:',
              style: TextStyle(fontSize: 18),
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: (menuItems.length / 3)
                  .ceil(), // Calculate the number of pages
              itemBuilder: (context, pageIndex) {
                final start = pageIndex * 3;
                final end = (pageIndex + 1) * 3;
                final pageItems = menuItems.sublist(start, end);

                return Column(
                  children: pageItems.map((menuItem) {
                    return InkWell(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                MenuItemPage(menuItem: menuItem),
                          ),
                        );
                      },
                      child: Container(
                        margin: EdgeInsets.all(8.0),
                        color: Colors.teal,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Image.asset(
                              menuItem.imagePath,
                              width: double.infinity,
                              height:
                                  150.0, // Adjust the image height as needed
                              fit: BoxFit.cover,
                            ),
                            Container(
                              padding: EdgeInsets.all(8.0),
                              child: Text(
                                menuItem.title,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 16.0,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
