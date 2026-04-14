import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/purchase_not_for_sale_ledger_model.dart';

class PurchaseNotForSaleLedgerService {
  static Future<PurchaseNotForSaleLedgerModel> fetchLedger(
      String publicationId) async {
    final url = Uri.parse(
        "https://g17bookworld.com/api/PurchaseNotForSaleLadger/GetLedgerPurchaseNotForSale?publicationId=$publicationId");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return PurchaseNotForSaleLedgerModel.fromJson(jsonData);
    } else {
      throw Exception("Failed to load ledger");
    }
  }
}