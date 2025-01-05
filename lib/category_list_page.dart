import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'recipe_list_page.dart';

class CategoryListPage extends StatefulWidget {
  @override
  _CategoryListPageState createState() => _CategoryListPageState();
}

class _CategoryListPageState extends State<CategoryListPage> {
  List<Map<String, dynamic>> categories = [];

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  // Fetch categories from the server
  Future<void> fetchCategories() async {
    try {
      final response = await http.get(
        Uri.parse('http://nourproj.atwebpages.com/get_categories.php'),
      );

      if (response.statusCode == 200) {
        print('Response Body: ${response.body}');

        List<dynamic> data = json.decode(response.body);
        setState(() {
          categories = data.map((category) => {
            'name': category['name'] ?? 'Unknown',
            'image': category['image'] ?? '',
            'id': int.tryParse(category['id'].toString()) ?? 0,  // Parse id to int
          }).toList();
        });
      } else {
        print('Failed to load categories, status code: ${response.statusCode}');
        throw Exception('Failed to load categories');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Categories')),
      body: categories.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: categories.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => RecipeListPage(
                    categoryId: categories[index]['id'] as int,  // No need to cast again, it's already an int
                    categoryName: categories[index]['name'] as String,  // Cast to String
                  ),
                ),
              );
            },
            child: Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    // Category image
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        categories[index]['image'] as String,  // Cast to String
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                    SizedBox(width: 16),
                    // Category name
                    Expanded(
                      child: Text(
                        categories[index]['name'] as String,  // Cast to String
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
