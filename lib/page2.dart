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
  String error = "";
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
    setState(() {
      // _isLoading = true;
      error = "";
    });
    try {
      if (connection != null) {
        await connection.query("""
      INSERT INTO BORROWER(Name,Address,Phone)
    VALUES(?,?,?);
      """, [
          _nameController.text,
          _addressController.text,
          _phoneController.text
        ]);

        var results = await connection.query("""
      SELECT Card_No from BORROWER
    where Name= ? AND Address = ? AND Phone = ?;
      """, [
          _nameController.text,
          _addressController.text,
          _phoneController.text
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
    } on MySqlException {
      setState(() {
        error = "Combination of Name, Address and Phone already exists";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a Borrower '),
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
                    FocusScope.of(context).unfocus();
                    submit(widget.databaseConnection);
                  }
                },
                child: const Text('Submit'),
              ),
              error.isNotEmpty
                  ? Text(
                      error,
                      style: const TextStyle(color: Colors.red),
                    )
                  : const SizedBox.shrink(),
            ],
          ),
        ),
      ),
    );
  }
}
