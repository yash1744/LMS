import 'package:mysql1/mysql1.dart';

class DatabaseManager {
  static final DatabaseManager _instance = DatabaseManager._();

  factory DatabaseManager() => _instance;

  static const String _host = 'database-1.cgqxrcork6eh.us-east-2.rds.amazonaws.com';
  static const int _port = 3306;
  static const String _user = 'admin';
  static const String _password = '12345678';
  static const String _databaseName = 'LMS';

  late MySqlConnection? _conn;
  bool _isConnected = false;

  DatabaseManager._();

  Future<void> init() async {
    if (_isConnected) return;
    await openConnection();
  }
  Future<void> openConnection() async {
    _conn = await MySqlConnection.connect(ConnectionSettings(
      host: _host,
      port: _port,
      user: _user,
      password: _password,
      db: _databaseName,
    ));
    _isConnected = true;
  }
  
  MySqlConnection? get connection => _conn;
  bool get isConnected => _isConnected;
  Future<void> closeConnection() async {
    if (_isConnected) {
      await _conn?.close();
      _isConnected = false;
    }
  }
}
