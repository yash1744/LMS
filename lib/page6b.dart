import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class Page6b extends StatefulWidget {
  final MySqlConnection? databaseConnection;
  const Page6b({super.key, required this.databaseConnection});

  @override
  State<Page6b> createState() => _Page6bState();
}

class _Page6bState extends State<Page6b> {
  final _formKey = GlobalKey<FormState>();
  final _bookidController = TextEditingController();
  final _nameController = TextEditingController();

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _bookidController.dispose();
    _nameController.dispose();

    super.dispose();
  }

  void submit(MySqlConnection? connection) async {
    try {
      if (connection != null) {
        await connection.query("""
      INSERT INTO BORROWER(bookid,name,Phone)
    VALUES(?,?,?);
      """, [
          _bookidController.text,
          _nameController.text,
        ]);

        var results = await connection.query("""
      SELECT Card_No from BORROWER
    where bookid= ? AND name = ? AND Phone = ?;
      """, [
          _bookidController.text,
          _nameController.text,
        ]);
        var id = results.first[0].toString();
        // print(results.first[0].toString());
        // ignore: use_build_context_synchronously
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
              content: Text('Borrower Added with Card No:$id'),
              duration: const Duration(seconds: 5)),
        );
      }
    } on MySqlException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Late fee for a book '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('bookid'),
              TextFormField(
                controller: _bookidController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your bookid';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Name or Part of Name'),
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  if (_formKey.currentState!.validate()) {
                    submit(widget.databaseConnection);
                  }
                },
                child: const Text('Save'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
