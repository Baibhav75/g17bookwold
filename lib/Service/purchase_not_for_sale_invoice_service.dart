import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/purchase_not_for_sale_invoice_model.dart';

class PurchaseNotForSaleInvoiceService {
  static Future<PurchaseNotForSaleInvoiceModel> fetchInvoice(String billNo) async {
    final url = Uri.parse(
        "https://g17bookworld.com/api/PurchaseNotForSaleDetails/GetPurchaseInvoice?billNo=$billNo");

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return PurchaseNotForSaleInvoiceModel.fromJson(jsonData);
    } else {
      throw Exception("Failed to load invoice");
    }
  }
}