import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'recipe_details_page.dart';

class RecipeListPage extends StatefulWidget {
  final int categoryId;
  final String categoryName;

  const RecipeListPage({
    required this.categoryId,
    required this.categoryName,
    Key? key,
  }) : super(key: key);

  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  List<Map<String, dynamic>> recipes = [];

  @override
  void initState() {
    super.initState();
    fetchRecipes();
  }

  Future<void> fetchRecipes() async {
    try {
      final response = await http.get(
        Uri.parse('http://nourproj.atwebpages.com/get_recipes.php?category_id=${widget.categoryId}'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);
        setState(() {
          recipes = data.map((recipe) => {
            'name': recipe['name'] ?? 'Unknown Recipe',
            'image': recipe['image'] ?? '',
            'instructions': recipe['instructions'] ?? 'No instructions available',
            'ingredients': recipe['ingredients'] ?? 'No ingredients available',
          }).toList();
        });
      } else {
        print('Failed to load recipes');
        throw Exception('Failed to load recipes');
      }
    } catch (error) {
      print('Error: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Recipes for ${widget.categoryName}')),
      body: recipes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
        itemCount: recipes.length,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () {
              final recipe = recipes[index];
              final recipeName = recipe['name'] ?? 'Unknown Recipe';
              final recipeImage = recipe['image'] ?? '';
              final recipeInstructions = recipe['instructions'] ?? 'No instructions available';
              final recipeIngredients = recipe['ingredients'] ?? 'No ingredients available';

              if (recipeName.isNotEmpty && recipeImage.isNotEmpty) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => RecipeDetailsPage(
                      recipeName: recipeName,
                      recipeImage: recipeImage,
                      recipeInstructions: recipeInstructions,
                      recipeIngredients: recipeIngredients,
                    ),
                  ),
                );
              } else {
                print("Invalid recipe data detected!");
              }
            },
            child: Card(
              elevation: 4,
              margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    ClipRRect(
                      borderRadius: BorderRadius.circular(8),
                      child: Image.network(
                        recipes[index]['image']!,
                        width: 100,
                        height: 100,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.broken_image, size: 100),
                      ),
                    ),
                    SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            recipes[index]['name']!,
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 8),

                          SizedBox(height: 8),

                        ],
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
