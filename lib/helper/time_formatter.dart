/*

  - This converts a timestamp object into a string

  E.g. 

  if the input timestamp reporesents: July 24, 2024, 13:00

  the function will return the string: '2024-07-24 14:30'
*/

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

String formatTimestamp(Timestamp timestamp) {
  DateTime dateTime = timestamp.toDate();
  return DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
}
