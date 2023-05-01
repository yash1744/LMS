import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

class Page4 extends StatefulWidget {
  final MySqlConnection? databaseConnection;
  const Page4({super.key, required this.databaseConnection});

  @override
  State<Page4> createState() => _Page4State();
}

class _Page4State extends State<Page4> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  late List<List<String>> results;
  List<String?> columns = List.empty(growable: true);
  List<List<String>> rows = List.empty(growable: true);
  String error = "";
  List<String> _bookList = ["None"];
  String _bookValue = "None";

  @override
  void initState() {
    super.initState();
    fetchBooks(widget.databaseConnection);
    // print(widget.databaseConnection);
  }

  void fetchBooks(MySqlConnection? connection) async {
    setState(() {
      _isLoading = true;
    });

    if (connection != null) {
      var results = await connection.query("select Title from BOOK ;");
      if (results.isEmpty) {
        setState(() {
          _bookList = ["None"];
          _bookValue = "None";
          _isLoading = false;
        });
        return;
      } else {
        List<String> temp = results.map((row) => row[0].toString()).toList();
        setState(() {
          _bookList = temp;
          _bookValue = temp[0];
        });
      }
    }

    setState(() {
      _isLoading = false;
    });
  }

  void getLoansPerBranch(MySqlConnection? connection) async {
    setState(() {
      _isLoading = true;
      error = "";
      columns = List.empty(growable: true);
      rows = List.empty(growable: true);
    });
    try {
      if (connection != null) {
        var results = await connection.query("""
select Branch_Name as BRANCH,count(*) as COUNT from BOOK_LOANS,LIBRARY_BRANCH
where LIBRARY_BRANCH.Branch_Id = BOOK_LOANS.Branch_Id and BOOK_LOANS.Book_Id = (
select Book_Id from BOOK where Title = ?)
group by Branch_Name;""", [_bookValue]);
        if (results.isEmpty) {
          setState(() {
            _isLoading = false;
            error = "No results found";
          });
          return;
        } else {
          var columns = results.map((row) {
            List<String?> temp =
                row.fields.keys.map((e) => e.toString()).toList();
            return temp;
          }).toList()[0];
          var rows = results.map((row) {
            print(row);
            List<String> temp = row.map((e) => e.toString()).toList();
            return temp;
          }).toList();
          if (rows.isEmpty) {
            setState(() {
              _isLoading = false;
              error = "No results found";
            });
          } else {
            setState(() {
              _isLoading = false;
              this.columns = columns;
              this.rows = rows;
            });
          }
        }
      }
    } catch (e) {
      setState(() {
        error ="No results found ";
        _isLoading = false;
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Get No of copies'),
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
                    DropdownButtonFormField<String>(
                      value: _bookValue,
                      onChanged: (newValue) {
                        setState(() {
                          _bookValue = newValue!;
                        });
                      },
                      items: _bookList.map((bookname) {
                        return DropdownMenuItem<String>(
                          value: bookname,
                          child: Text(bookname),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    ElevatedButton(
                      onPressed: () {
                        // Navigator.pop(context);
                        getLoansPerBranch(widget.databaseConnection);
                      },
                      child: const Text('Search'),
                    ),
                    const SizedBox(height: 16.0),
                    error.isNotEmpty
                        ? Text(
                            error,
                            style: const TextStyle(color: Colors.red),
                          )
                        : const SizedBox.shrink(),
                    columns.isEmpty || rows.isEmpty
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
                                    .toList())
                  ],
                ),
              ),
      ),
    );
  }
}
