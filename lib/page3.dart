import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class Page3 extends StatefulWidget {

  final MySqlConnection? databaseConnection;
  const Page3(
      {super.key,  required this.databaseConnection});

  @override
  State<Page3> createState() => _Page3State();
}

class _Page3State extends State<Page3> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<String> _publisherList = ["None"];
  String _publisherValue = "None";
  final _bookController = TextEditingController();
  final _authorController = TextEditingController();

  @override
  void initState() {
    super.initState();
    fetchPublishers(widget.databaseConnection);
    // print(widget.databaseConnection);
  }

  void fetchPublishers(MySqlConnection? connection) async {
    setState(() {
      _isLoading = true;
    });
    if (connection != null) {
      var results =
          await connection.query('Select Publisher_Name from PUBLISHER');
      if (results.isEmpty) {
        setState(() {
          _publisherList = ["None"];
          _publisherValue = "None";
          _isLoading = false;
        });
        return;
      } else {
        List<String> temp = results.map((row) => row[0].toString()).toList();
        setState(() {
          _publisherList = temp;
          _publisherValue = temp[0];
          _isLoading = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _bookController.dispose();
    _authorController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add a new Book'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: _isLoading
            ? const CircularProgressIndicator()
            : Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Book Name'),
                    TextFormField(
                      controller: _bookController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid book name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16.0),
                    const Text('Publisher Name'),
                    DropdownButtonFormField<String>(
                      value: _publisherValue,
                      onChanged: (newValue) {
                        setState(() {
                          _publisherValue = newValue!;
                        });
                        // fetchBooks(widget.databaseConnection, newValue!);
                      },
                      items: _publisherList.map((bookname) {
                        return DropdownMenuItem<String>(
                          value: bookname,
                          child: Text(bookname),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    const Text('Author Name'),
                    TextFormField(
                      controller: _authorController,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a valid author name';
                        }
                        return null;
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        print(
                            "in add book with book name: ${_bookController.text} , author name: ${_authorController.text} and publisher name: $_publisherValue ");
                        // Navigator.pop(context);
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
