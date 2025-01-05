import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'recipe_details_page.dart';

class SearchRecipesPage extends StatefulWidget {
  const SearchRecipesPage({Key? key}) : super(key: key);

  @override
  _SearchRecipesPageState createState() => _SearchRecipesPageState();
}

class _SearchRecipesPageState extends State<SearchRecipesPage> {
  List<Map<String, dynamic>> categories = [];
  List<Map<String, dynamic>> recipes = [];
  String? selectedCategory;
  String? selectedRecipe;
  bool isLoading = false;
  String errorMessage = '';

  @override
  void initState() {
    super.initState();
    fetchCategories();
  }

  Future<void> fetchCategories() async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://nourproj.atwebpages.com/get_categories.php'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          setState(() {
            categories = List<Map<String, dynamic>>.from(
              data.map((category) {
                category['id'] = int.tryParse(category['id'].toString()) ?? 0;
                return category;
              }),
            );
          });
        } else {
          setState(() {
            errorMessage = 'No categories found';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch categories. Please try again later.';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> fetchRecipes(int categoryId) async {
    setState(() {
      isLoading = true;
      errorMessage = '';
    });

    try {
      final response = await http.get(
        Uri.parse('http://nourproj.atwebpages.com/get_recipes.php?category_id=$categoryId'),
      );

      if (response.statusCode == 200) {
        List<dynamic> data = json.decode(response.body);

        if (data.isNotEmpty) {
          setState(() {
            recipes = List<Map<String, dynamic>>.from(
              data.map((recipe) {
                return {
                  'name': recipe['name'] ?? 'Unknown Recipe',
                  'image': recipe['image'] ?? '',
                  'instructions': recipe['instructions'] ?? 'No instructions available',
                  'ingredients': recipe['ingredients'] ?? 'No ingredients available',
                };
              }),
            );
          });
        } else {
          setState(() {
            errorMessage = 'No recipes found for selected category.';
          });
        }
      } else {
        setState(() {
          errorMessage = 'Failed to fetch recipes. Please try again later.';
        });
      }
    } catch (error) {
      setState(() {
        errorMessage = 'An error occurred: $error';
      });
    } finally {
      setState(() {
        isLoading = false;
      });
    }
  }

  void handleCategoryChange(String? categoryName, int categoryId) {
    setState(() {
      selectedCategory = categoryName;
      selectedRecipe = null;
    });
    fetchRecipes(categoryId);
  }

  void handleRecipeChange(String? recipeName) {
    setState(() {
      selectedRecipe = recipeName;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.orangeAccent,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('Search Recipes'),
            if (isLoading)
              CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                strokeWidth: 3,
              ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Category and Recipe Dropdowns
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                color: Colors.grey[200],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // Category dropdown
                  Expanded(
                    child: DropdownButton<String>(
                      hint: const Text("Select Category"),
                      value: selectedCategory,
                      onChanged: (categoryName) {
                        final selectedCategoryData = categories.firstWhere(
                              (category) => category['name'] == categoryName,
                          orElse: () => {},
                        );
                        if (selectedCategoryData.isNotEmpty) {
                          handleCategoryChange(categoryName, selectedCategoryData['id']);
                        }
                      },
                      items: categories.map<DropdownMenuItem<String>>((category) {
                        return DropdownMenuItem<String>(
                          value: category['name'],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(category['name']),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Recipe dropdown
                  Expanded(
                    child: DropdownButton<String>(
                      hint: const Text("Select Recipe"),
                      value: selectedRecipe,
                      onChanged: selectedCategory != null
                          ? (recipeName) {
                        handleRecipeChange(recipeName);
                      }
                          : null,
                      items: selectedCategory != null && recipes.isNotEmpty
                          ? recipes.map<DropdownMenuItem<String>>((recipe) {
                        return DropdownMenuItem<String>(
                          value: recipe['name'],
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            child: Text(recipe['name']),
                          ),
                        );
                      }).toList()
                          : [],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // Display Error or Message
            if (errorMessage.isNotEmpty)
              Text(
                errorMessage,
                style: const TextStyle(color: Colors.red, fontSize: 16),
                textAlign: TextAlign.center,
              )
            else if (selectedRecipe != null)
              Expanded(
                child: ListView.builder(
                  itemCount: recipes.length,
                  itemBuilder: (context, index) {
                    final recipe = recipes[index];
                    if (recipe['name'] == selectedRecipe) {
                      return GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => RecipeDetailsPage(
                                recipeName: recipe['name'] ?? 'Unknown Recipe',
                                recipeImage: recipe['image'] ?? '',
                                recipeInstructions: recipe['instructions'] ?? 'No instructions available',
                                recipeIngredients: recipe['ingredients'] ?? 'No ingredients available',
                              ),
                            ),
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(vertical: 8),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 6,
                          child: ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: Image.network(
                                recipe['image']!,
                                width: 60,
                                height: 60,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image, size: 60),
                              ),
                            ),
                            title: Text(recipe['name']!),
                            subtitle: Text('Tap to view details', style: TextStyle(color: Colors.grey[600])),
                          ),
                        ),
                      );
                    }
                    return const SizedBox();
                  },
                ),
              )
            else
              const Text(
                'Start by selecting a category to view recipes',
                style: TextStyle(fontSize: 16),
              ),
          ],
        ),
      ),
    );
  }
}
