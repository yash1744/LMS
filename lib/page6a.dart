import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

import 'helper.dart';

class Page6a extends StatefulWidget {
  final MySqlConnection? databaseConnection;
  const Page6a({super.key, required this.databaseConnection});

  @override
  State<Page6a> createState() => _Page6aState();
}

class _Page6aState extends State<Page6a> {
  final _formKey = GlobalKey<FormState>();
  final _idController = TextEditingController();
  final _nameController = TextEditingController();
  List<String?> columns = List.empty(growable: true);
  List<List<String>> rows = List.empty(growable: true);
  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    _idController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void submitUsingId(MySqlConnection? connection) async {
    try {
      if (connection != null) {
        var results = await connection.query("""
      SELECT DISTINCT Card_No as Borrower_ID,`Borrower Name`,CONCAT('\$',LateFeeBalance ) as LateFeeBalance
      from vBookLoanInfo 
      where `Card_No` =?;
      """, [_idController.text]);
        var tableresults = ResultstoTable(results);
        setState(() {
          columns = tableresults[0] as List<String?>;
          rows = tableresults[1] as List<List<String>>;
        });
      }
    } on MySqlException catch (e) {
      print(e.message);
    }
  }

  void submitUsingName(MySqlConnection? connection) async {
    try {
      if (connection != null) {
        var results = await connection.query("""
      SELECT DISTINCT Card_No as Borrower_ID,`Borrower Name`,CONCAT('\$',LateFeeBalance ) as LateFeeBalance
      from vBookLoanInfo
      where `Borrower Name` LIKE ?;
      """, ["%${_nameController.text}%"]);
        var tableresults = ResultstoTable(results);
        setState(() {
          columns = tableresults[0] as List<String?>;
          rows = tableresults[1] as List<List<String>>;
        });
      }
    } on MySqlException catch (e) {
      print(e.message);
    }
  }

  void submitUsingNothing(MySqlConnection? connection) async {
    try {
      if (connection != null) {
        var results = await connection.query("""
      SELECT Card_No as Borrower_ID, `Borrower Name`, CONCAT('\$',LateFeeBalance ) as LateFeeBalance
      from vBookLoanInfo bi
      order by bi.LateFeeBalance DESC;
      """);
        var tableresults = ResultstoTable(results);
        setState(() {
          columns = tableresults[0] as List<String?>;
          rows = tableresults[1] as List<List<String>>;
        });
      }
    } on MySqlException catch (e) {
      print(e.message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Search Borrower by Name or ID'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Id'),
              TextFormField(
                controller: _idController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              const Text('Name OR Part of Name'),
              TextFormField(
                controller: _nameController,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your address';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              ElevatedButton(
                onPressed: () {
                  FocusScope.of(context).unfocus();
                  if (_idController.text.isNotEmpty) {
                    submitUsingId(widget.databaseConnection);
                  } else if (_nameController.text.isNotEmpty) {
                    submitUsingName(widget.databaseConnection);
                  } else {
                    submitUsingNothing(widget.databaseConnection);
                  }
                },
                child: const Text('Search'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: columns.isEmpty || rows.isEmpty
                          ? Container()
                          : DataTable(
                              columns: columns.isEmpty
                                  ? []
                                  : columns
                                      .map((e) => DataColumn(
                                          label: Text(e.toString(),
                                              style: const TextStyle(
                                                  fontSize: 18,
                                                  fontWeight:
                                                      FontWeight.bold))))
                                      .toList(),
                              rows: rows.isEmpty
                                  ? []
                                  : rows
                                      .map((row) => DataRow(
                                          cells: row
                                              .map((item) =>
                                                  DataCell(Text(item)))
                                              .toList()))
                                      .toList())),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
