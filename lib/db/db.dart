import 'package:mysql1/mysql1.dart';

Future<void> connectToDatabase() async {
  final settings = ConnectionSettings(
    host: 'recipe-database.cyg3ezxgvj0g.us-east-1.rds.amazonaws.com',
    port: 3306,
    user: 'admin',
    password: 'recipegpt',
    db: 'recipedb',
  );

  try {
    final conn = await MySqlConnection.connect(settings);
    var results =
        await conn.query('SELECT * recipedb.accounts where accountID =1');
    for (var row in results) {
      print('Row: $row');
    }
    await conn.close();
  } catch (e) {
    print('Failed to connect to the database: $e');
  }
}
