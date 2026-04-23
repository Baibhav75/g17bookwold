import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/sample_sale_bill_ledger_model.dart';
import '/appDart/api_constants.dart';

class SampleSaleLedgerService {
  static Future<SampleSaleLedgerResponse?> fetchLedger(String schoolName) async {
    try {
      final url = ApiConstants.sampleSaleLedger(Uri.encodeComponent(schoolName));

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return SampleSaleLedgerResponse.fromJson(jsonData);
      } else {
        return null;
      }
    } catch (e) {
      print("Ledger API Error: $e");
      return null;
    }
  }
}