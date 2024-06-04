// this is chooseRecipes.dart

import 'package:flutter/material.dart';
import 'package:recipe_gpt/services/openai/chat_screen.dart';
import 'package:recipe_gpt/services/openai/chat_service.dart';

class RecipeListPage extends StatefulWidget {
  final String prompt;
  final int people;

  RecipeListPage({required this.prompt, required this.people});

  @override
  _RecipeListPageState createState() => _RecipeListPageState();
}

class _RecipeListPageState extends State<RecipeListPage> {
  List<String> recipes = [];

  @override
  void initState() {
    super.initState();
    _generateRecipeList();
  }

  Future<void> _generateRecipeList() async {
    String? response =
        await ChatService().requestRecipeList(widget.prompt, widget.people);
    if (response != null) {
      setState(() {
        recipes = response.split('\n');
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFFF1E9E6),
        title: Text('食譜列表'),
      ),
      body: recipes.isEmpty
          ? Center(child: CircularProgressIndicator())
          : ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                return Card(
                  color: Color(0xFFFFFAF5),
                  margin: EdgeInsets.all(8.0),
                  child: ListTile(
                    leading:
                        Icon(Icons.restaurant_menu, color: Color(0xFFF2B892)),
                    title: Text(recipes[index]),
                    trailing:
                        Icon(Icons.arrow_forward_ios, color: Color(0xFFF2B892)),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ChatPage(
                            recipe: recipes[index],
                            prompt: widget.prompt,
                            people: widget.people,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
    );
  }
}
