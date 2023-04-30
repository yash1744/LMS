import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

import 'helper.dart';

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
  List<String?> columns = List.empty(growable: true);
  List<List<String>> rows = List.empty(growable: true);
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

  void submitUsingId(MySqlConnection? connection) async {
    try {
      if (connection != null) {
        var results = await connection.query("""
      SELECT 
	(select Book_Id from BOOK where Title=vbl.`Book Title`) as book_id,
	`Book Title`,
    (select Book_Publisher from BOOK where Title=vbl.`Book Title`) as Book_Publisher,
	CONCAT('\$', SUM(LateFeeBalance) + 0.00) as LateFeeAmount
from vBookLoanInfo as vbl 
Join BOOK b on b.title = vbl.`Book Title`
where book_id = ?
group by `Book Title` 
order by SUM(LateFeeBalance) desc;

      """, [_bookidController.text]);
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
      SELECT
	(select Book_Id from BOOK where Title=vbl.`Book Title`) as book_id,
	`Book Title`,
    (select Book_Publisher from BOOK where Title=vbl.`Book Title`) as Book_Publisher,
	CONCAT('\$', SUM(LateFeeBalance) + 0.00) as LateFeeAmount
from vBookLoanInfo as vbl 
Join BOOK b on b.title = vbl.`Book Title`
where b.Title LIKE ?
group by `Book Title` 
order by SUM(LateFeeBalance) desc;
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
      SELECT 
	(select Book_Id from BOOK where Title=vbl.`Book Title`) as book_id,
	`Book Title`,
    (select Book_Publisher from BOOK where Title=vbl.`Book Title`) as Book_Publisher,
	CONCAT('\$', SUM(LateFeeBalance) + 0.00) as LateFeeAmount
from vBookLoanInfo as vbl
group by `Book Title` 
order by SUM(LateFeeBalance) desc;
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
                  FocusScope.of(context).unfocus();
                  if (_bookidController.text.isNotEmpty) {
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
