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
        host: 'recipe-database.cyg3ezxgvj0g.us-east-1.rds.amazonaws.com',
        port: 3306,
        user: 'admin',
        password: 'recipegpt',
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
