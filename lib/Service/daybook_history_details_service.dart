import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/daybook_history_details_model.dart';
import '/appDart/api_constants.dart';

class DayBookDetailsService {
  static Future<DayBookDetailsResponse?> fetchDetails(String mobileNo) async {
    final url =
        "${ApiConstants.dayBookDetails}?MobileNo=$mobileNo";

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return DayBookDetailsResponse.fromJson(jsonData);
    } else {
      return null;
    }
  }
}