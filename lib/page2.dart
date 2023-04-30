import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class Page2 extends StatefulWidget {
  final MySqlConnection? databaseConnection;
  const Page2({super.key, required this.databaseConnection});

  @override
  State<Page2> createState() => _Page2State();
}

class _Page2State extends State<Page2> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  final String _statusValue = 'Available';
  final List<String> _statusList = ['Available', 'Reserved', 'Borrowed'];
  late var output;
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void submit(MySqlConnection? connection) async {
    try {
      if (connection != null) {
        var results = await connection.query("""
      INSERT INTO BORROWER(Name,Address,Phone)
    VALUES(?,?,?);
      """, [
          _nameController.text,
          _addressController.text,
          _phoneController.text
        ]);
        print(results);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Borrower Added'),
          ),
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
        title: const Text('Borrower '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Name'),
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
              const Text('Address'),
              TextFormField(
                controller: _addressController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Phone Number'),
              TextFormField(
                controller: _phoneController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your phone number';
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
