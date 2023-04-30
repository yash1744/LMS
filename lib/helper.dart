import 'package:flutter/material.dart';
import 'package:mysql1/mysql1.dart';

List<List<Object?>> ResultstoTable(Results results){
  var columns = results.map((row) {
    List<String?> temp = row.fields.keys.map((e) => e.toString()).toList();
    return temp;
  }).toList()[0];
  var rows = results.map((row) {
    print(row);
    List<String> temp = row.map((e) => e.toString()).toList();
    return temp;
  }).toList();
  return [columns,rows];
}

