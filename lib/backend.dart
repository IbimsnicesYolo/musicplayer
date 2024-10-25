class Database {
  static final Database _instance = Database._internal();

  factory Database() {
    return _instance;
  }

  Database._internal();

  Future<void> initialize() async {
    // Simulate a delay for database initialization
    await Future.delayed(Duration(seconds: 5));
  }
}
