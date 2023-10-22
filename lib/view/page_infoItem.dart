import 'package:flutter/material.dart';
import '../model/menu_item.dart';

class MenuItemPage extends StatelessWidget {
  final MenuItem menuItem;

  const MenuItemPage({Key? key, required this.menuItem}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(menuItem.title),
        backgroundColor: Colors.teal,
      ),
      body: ListView(
        children: [
          Image.asset(menuItem.imagePath),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              menuItem.description,
              style: const TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }
}
