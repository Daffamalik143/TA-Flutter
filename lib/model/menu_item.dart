class MenuItem {
  final String title;
  final String imagePath;
  final String description;

  MenuItem({
    required this.title,
    required this.imagePath,
    required this.description,
  });
}

List<MenuItem> menuItems = [
  MenuItem(
    title: "Item 1",
    imagePath: "assets/item1.jpg",
    description: "Description for Item 1",
  ),
  MenuItem(
    title: "Item 2",
    imagePath: "assets/item2.jpg",
    description: "Description for Item 2",
  ),
  MenuItem(
    title: "Item 3",
    imagePath: "assets/item3.jpg",
    description: "Description for Item 3",
  ),
  // Add more menu items as needed
];
