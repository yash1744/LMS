import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';
import 'helper.dart';

class Page1 extends StatefulWidget {
  final MySqlConnection? databaseConnection;
  const Page1({super.key, required this.databaseConnection});

  @override
  State<Page1> createState() => _Page1State();
}

class _Page1State extends State<Page1> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  List<String> _branchList = ["None"];
  String _statusValue = "None";
  List<String> _bookList = ["None"];
  String _bookValue = "None";
  List<String?> columns = List.empty(growable: true);
  List<List<String>> rows = List.empty(growable: true);
  String error = "";
  final _cardController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    fetchBranches(widget.databaseConnection);
    _focusNode.addListener(() {
      if (!_focusNode.hasFocus) {
        FocusScope.of(context).unfocus();
      }
    });
  }

  void fetchBranches(MySqlConnection? connection) async {
    setState(() {
      _isLoading = true;
    });
    if (connection != null) {
      var results = await connection
          .query('Select DISTINCT Branch_Name,Branch_Id from LIBRARY_BRANCH');
      if (results.isEmpty) {
        setState(() {
          _branchList = ["None"];
          _bookList = ["None"];
          _bookValue = "None";
          _statusValue = "None";
          _isLoading = false;
        });
        return;
      } else {
        List<String> temp = results.map((row) => row[0].toString()).toList();
        setState(() {
          _branchList = temp;
          _statusValue = temp[0];
          _isLoading = false;
        });
        fetchBooks(connection, _statusValue);
      }
    }
  }

  void submit(MySqlConnection? connection) async {
    setState(() {
      _isLoading = true;
      error = "";
      columns = List.empty(growable: true);
      rows = List.empty(growable: true);
    });
    print("running");
    try {
      if (connection != null) {
        var results = await connection.query("""
      INSERT INTO BOOK_LOANS
      VALUES (
        (SELECT Book_Id FROM BOOK B WHERE B.Title = ?),
        (SELECT Branch_Id FROM LIBRARY_BRANCH LB WHERE LB.Branch_Name =?),
        ?,
        CURRENT_DATE,
        DATE_ADD(CURRENT_DATE, INTERVAL 10 DAY),
        NULL,
        0);
      """, [_bookValue, _statusValue, _cardController.text]);
      }
    } on MySqlException catch (e) {
      var error = "";
      if (e.errorNumber == 1452) {
        error = "Borrower Card_No does not exist";
      } else if (e.errorNumber == 1062) {
        error = "Book is already checked out";
      } else {
        error = e.message;
      }
      setState(() {
        this.error = error;
        _isLoading = false;
      });
      return;
    }
    print('done1');
    try {
      if (connection != null) {
        await connection.query("""
      UPDATE BOOK_COPIES
    SET No_Of_Copies = No_Of_Copies - 1
    WHERE Book_Id = (SELECT Book_Id FROM BOOK B WHERE B.Title = ?) AND
    Branch_Id = (SELECT Branch_Id FROM LIBRARY_BRANCH LB WHERE LB.Branch_Name = ?);
      """, [_bookValue, _statusValue]);
      }
    } catch (e) {
      print(e);
    }

    print("done2");
    try {
      if (connection != null) {
        var results = await connection.query("""
      select b.Title as Book, br.Branch_Name as Branch,No_Of_Copies as copies from BOOK_COPIES bc
    JOIN BOOK b ON b.Book_Id = bc.Book_Id
    JOIN LIBRARY_BRANCH br ON br.Branch_Id = bc.Branch_Id;
      """);
        var tableresults = ResultstoTable(results);
        setState(() {
          columns = tableresults[0] as List<String?>;
          rows = tableresults[1] as List<List<String>>;
        });
        print(columns);
      }
    } catch (e) {
      print(e);
    }
    fetchBranches(widget.databaseConnection);
    setState(() {
      _isLoading = false;
      _cardController.clear();
    });
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text("Book Loaned Successfully"),
      ),
    );
  }

  void fetchBooks(MySqlConnection? connection, String branchName) async {
    setState(() {
      _isLoading = true;
    });

    if (connection != null) {
      var results = await connection
          .query('''select Title from BOOK,BOOK_COPIES,LIBRARY_BRANCH
          where LIBRARY_BRANCH.Branch_Id = BOOK_COPIES.Branch_Id and
          BOOK.Book_Id = BOOK_COPIES.BOOK_ID and BOOK_COPIES.No_Of_Copies >0
          and LIBRARY_BRANCH.Branch_Name = ? ;''', [branchName]);
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
    print(
        "in fetch books with branch name: $branchName , book list: $_bookList ");
    setState(() {
      _isLoading = false;
    });
  }

  @override
  void dispose() {
    _cardController.dispose();
    super.dispose();
    _focusNode.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print(
        "running with branch list: $_branchList and status value: $_statusValue and bookvalue: $_bookValue ");
    return Scaffold(
      appBar: AppBar(
        title: const Text('Check Out a Book'),
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
                    const Text('LIBRARY BRANCH'),
                    DropdownButtonFormField<String>(
                      value: _statusValue,
                      onChanged: (newValue) {
                        setState(() {
                          _statusValue = newValue!;
                        });
                        fetchBooks(widget.databaseConnection, newValue!);
                      },
                      items: _branchList.map((branch) {
                        return DropdownMenuItem<String>(
                          value: branch,
                          child: Text(branch),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    const Text('BOOK NAME'),
                    DropdownButtonFormField<String>(
                      value: _bookValue,
                      onChanged: (newValue) {
                        setState(() {
                          _bookValue = newValue!;
                        });
                        // fetchBooks(widget.databaseConnection, newValue!);
                      },
                      items: _bookList.map((bookname) {
                        return DropdownMenuItem<String>(
                          value: bookname,
                          child: Text(bookname),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 16.0),
                    const Text('CARD NO'),
                    TextFormField(
                      controller: _cardController,
                      focusNode: _focusNode,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter a card number';
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
                      child: const Text('Checkout'),
                    ),
                    error.isNotEmpty
                        ? Text(
                            error,
                            style: const TextStyle(color: Colors.red),
                          )
                        : const SizedBox.shrink(),
                    const SizedBox(height: 16.0),
                    Expanded(
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
                  ],
                ),
              ),
      ),
    );
  }
}
