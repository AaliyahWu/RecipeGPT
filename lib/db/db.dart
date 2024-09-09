import 'package:mysql1/mysql1.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  MySqlConnection? _connection;

  factory DatabaseService() {
    return _instance;
  }

  DatabaseService._internal();

  Future<MySqlConnection> get connection async {
    if (_connection == null) {
      final settings = ConnectionSettings(
        host: 'recipe.mysql.database.azure.com',
        port: 3306,
        user: 'recipe',
        password: '112_RGPT',
        db: 'recipedb',
      );
      _connection = await MySqlConnection.connect(settings);
    }
    return _connection!;
  }

  Future<void> closeConnection() async {
    await _connection?.close();
    _connection = null;
  }
  // Fetch recipes by account ID
//   Future<List<Map<String, dynamic>>> fetchRecipes(int accountId) async {
//     var conn = await connection;
    
//     // Use accountId in the query to fetch only that user's recipes
//     var results = await conn.query(
//         'SELECT imageUrl, title, description, rating FROM recipes WHERE account_id = ?', 
//         [accountId]
//     );

//     List<Map<String, dynamic>> recipes = [];
//     for (var row in results) {
//       recipes.add({
//         'imageUrl': row[0],
//         'title': row[1],
//         'description': row[2],
//         'rating': row[3],
//       });
//     }
//     return recipes;
//   }
}