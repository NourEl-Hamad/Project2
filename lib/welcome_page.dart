import 'package:flutter/material.dart';
import 'search_page.dart';  
import 'category_list_page.dart';

class WelcomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand, 
        children: [
          // Background image
          Image.network(
            "https://media.istockphoto.com/id/1457433817/photo/group-of-healthy-food-for-flexitarian-diet.jpg?s=2048x2048&w=is&k=20&c=rRlOrFqCQn8kBDwvZnN75XFxiD0CA6S2LkgVKQRYJ3k=", // Use high-resolution image
            fit: BoxFit.cover, 
          ),
          // Centered buttons
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => CategoryListPage()),
                    );
                  },
                  child: Text(
                    "WELCOME",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                SizedBox(height: 20),  
      ElevatedButton(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => SearchRecipesPage()), // Provide a valid categoryId
          );
        },
        child: Text(
          "SEARCH",
          style: TextStyle(fontSize: 20),
        ),
      ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
