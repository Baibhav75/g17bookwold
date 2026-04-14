import 'dart:convert';
import 'package:http/http.dart' as http;
import '../appDart/api_constants.dart';
import '../model/purchase_sample_revenew_ledger_model.dart';


class PurchaseSampleRevenewLedgerService {
  static Future<PurchaseSampleRevenewLedgerModel> fetchLedger(
      String publicationId) async {
    final url = Uri.parse(
        ApiConstants.purchaseSampleLedger(publicationId));

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return PurchaseSampleRevenewLedgerModel.fromJson(jsonData);
    } else {
      throw Exception("Failed to load ledger");
    }
  }
}