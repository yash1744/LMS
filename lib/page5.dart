import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'package:intl/intl.dart';

import 'helper.dart';

class Page5 extends StatefulWidget {
  final MySqlConnection? databaseConnection;
  const Page5({super.key, required this.databaseConnection});

  @override
  State<Page5> createState() => _Page5State();
}

class DateWrapper {
  DateTime? date;
  DateWrapper(this.date);
}

class _Page5State extends State<Page5> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  final _phoneController = TextEditingController();
  DateWrapper startDate = DateWrapper(DateTime.now());
  DateWrapper endDate = DateWrapper(DateTime.now());
  late List<List<String>> results;
  List<String?> columns = List.empty(growable: true);
  List<List<String>> rows = List.empty(growable: true);
  String error = "";

  @override
  void initState() {
    super.initState();
  }

  Future<void> _selectDate(BuildContext context, DateWrapper date) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: date.date ?? DateTime.now(),
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != date.date) {
      setState(() {
        date.date = picked;
      });
    }
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
      columns = List.empty(growable: true);
      rows = List.empty(growable: true);
    });
    try {
      if (connection != null) {
        var results = await connection.query("""
SELECT  bl.Card_No as Borrower_ID, lb.Branch_Name as Branch,b.Title as Book,datediff(Returned_date,bl.Due_Date) as `Days late` 
    FROM BOOK_LOANS bl 
    join BOOK b on b.Book_Id = bl.Book_Id
    join LIBRARY_BRANCH lb on lb.Branch_Id = bl.Branch_Id
    WHERE Due_Date BETWEEN ? AND ? AND LATE = 1;""", [
          DateFormat('yyyy-MM-dd').format(startDate.date!).toString(),
          DateFormat('yyyy-MM-dd').format(endDate.date!).toString()
        ]);
        print(results);
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
        title: const Text('Borrower '),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text("Start Date"),
              ElevatedButton(
                onPressed: () {
                  _selectDate(context, startDate);
                },
                child: Text(DateFormat('MM-dd-yyyy')
                    .format(startDate.date!)
                    .toString()),
              ),
              const Text("End Date"),
              ElevatedButton(
                onPressed: () {
                  _selectDate(context, endDate);
                  
                },
                child: Text(
                    DateFormat('MM-dd-yyyy').format(endDate.date!).toString()),
              ),
              ElevatedButton(
                onPressed: () {
                  submit(widget.databaseConnection);
                  print(
                      "${DateFormat('yyyy-MM-dd').format(startDate.date!).toString()}  ${DateFormat('yyyy-MM-dd').format(endDate.date!).toString()}");
                },
                child: const Text('Search'),
              ),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
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
                                              fontWeight: FontWeight.bold))))
                                  .toList(),
                          rows: rows.isEmpty
                              ? []
                              : rows
                                  .map((row) => DataRow(
                                      cells: row
                                          .map((item) => DataCell(Text(item)))
                                          .toList()))
                                  .toList()),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
