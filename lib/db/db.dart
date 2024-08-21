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
}

// class DatabaseService {
//   static final DatabaseService _instance = DatabaseService._internal();
//   MySqlConnection? _connection;

//   factory DatabaseService() {
//     return _instance;
//   }

//   DatabaseService._internal();

//   Future<MySqlConnection> get connection async {
//     if (_connection == null) {
//       final settings = ConnectionSettings(
//         host: 'recipeedb-2.mysql.database.azure.com',
//         port: 3306,
//         user: 'yuntech',
//         password: 'recipeDB@@',
//         db: 'recipedb',
//       );
//       _connection = await MySqlConnection.connect(settings);
//     }
//     return _connection!;
//   }

//   Future<void> closeConnection() async {
//     await _connection?.close();
//     _connection = null;
//   }
// }
