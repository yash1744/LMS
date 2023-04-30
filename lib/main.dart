import 'package:flutter/material.dart';
import 'package:my_app/page1.dart';
import 'package:my_app/page3.dart';
import 'package:my_app/page4.dart';
import 'package:my_app/page5.dart';
import 'package:my_app/page2.dart';
import 'package:my_app/page6a.dart';
import 'package:my_app/page6b.dart';
import 'package:mysql1/mysql1.dart';

// import 'package:mysql1/mysql1.dart';
// import 'dart:async';
Future main() async {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(title: 'Library Management System'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  MyHomePage({super.key, required this.title});

  final String title;
  final connSettings = ConnectionSettings(
    host: 'database-1.cgqxrcork6eh.us-east-2.rds.amazonaws.com',
    port: 3306,
    user: 'admin',
    password: '12345678',
    db: 'LMS',
  );
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> with WidgetsBindingObserver {
  bool _isLoading = true;
  final bool _isDatabaseOpen = false;
  late MySqlConnection? _connection;

  void _connectToDatabase() async {
    try {
      final settings = ConnectionSettings(
        host: 'database-1.cgqxrcork6eh.us-east-2.rds.amazonaws.com',
        port: 3306,
        user: 'admin',
        password: '12345678',
        db: 'LMS',
      );

      _connection = await MySqlConnection.connect(settings);
      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print('Error connecting to database: $e');
    }
  }

  void _closeDatabase() async {
    try {
      await _connection?.close();
    } catch (e) {
      print('Error closing database: $e');
    }
  }

  @override
  void initState() {
    super.initState();
    _connectToDatabase();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
    print("app closed");
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    super.didChangeAppLifecycleState(state);
    if (state == AppLifecycleState.paused) {
      print("db paused");
      _closeDatabase();
    } else if (state == AppLifecycleState.resumed) {
      _connectToDatabase();
      print("db resumed");
    }
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: ListView(
        children: <Widget>[
          _isLoading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : const Center(
                  child: Text('Database Connected!'),
                ),
          ListTile(
            title: const Text('1) Check out a Book'),
            subtitle: const Text(
                'User checks out a book, add it to Book_Loan, the number of copies needs to be updated in the Book_Copies table.'),
            onTap: () {
              // handle onTap event
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Page1(databaseConnection: _connection)),
              );
            },
          ),
          const SizedBox(height: 16.0),
          ListTile(
            title: const Text('2) Add a new Borrower'),
            subtitle: const Text(
                'Add information about a new Borrower. Do not provide the CardNo in your query. Output the card number as if you are giving a new library card. '),
            onTap: () {
              // handle onTap event
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Page2(databaseConnection: _connection)),
              );
            },
          ),
          const SizedBox(height: 16.0),
          ListTile(
            title: const Text('3) Add a new Book'),
            subtitle: const Text(
                'Add a new Book with publisher (use can use a publisher that already exists) and author information toall 5 branches with 5 copies for each branch'),
            onTap: () {
              // handle onTap event
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Page3(databaseConnection: _connection)),
              );
            },
          ),
          const SizedBox(height: 16.0),
          ListTile(
            title: const Text('4) Get number of copies loaned out per branch'),
            subtitle: const Text(
                'Given a book title list the number of copies loaned out per branch.'),
            onTap: () {
              // handle onTap event
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Page4(databaseConnection: _connection)),
              );
            },
          ),
          const SizedBox(height: 16.0),
          ListTile(
            title: const Text('5) Get Book_Loans that were returned late '),
            subtitle: const Text(
                'Given any due date range list the Book_Loans that were returned late and how many days they were late.'),
            onTap: () {
              // handle onTap event
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Page5(databaseConnection: _connection)),
              );
            },
          ),
          const SizedBox(height: 16.0),
          ListTile(
            title: const Text('6a) Check late fees for a borrower'),
            subtitle: const Text(
                """List for every borrower the ID, name, and if there is any lateFee balance. The user has the right to search either by a borrower ID, name, part of the name, or to run the query with no filters/criteria. T"""),
            onTap: () {
              // handle onTap event
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Page6a(databaseConnection: _connection)),
              );
            },
          ),
          const SizedBox(height: 16.0),
          ListTile(
            title: const Text('6b) Check late fees for a Book'),
            subtitle: const Text(
                'List book information in the view. The user has the right either to search by the book id, books title, part of book title, or to run the query with no filters/criteria.'),
            onTap: () {
              // handle onTap event
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        Page6b(databaseConnection: _connection)),
              );
            },
          ),
        ],
      ),
    );
  }
}
