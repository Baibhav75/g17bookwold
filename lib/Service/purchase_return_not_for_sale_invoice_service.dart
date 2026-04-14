import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/purchase_return_not_for_sale_invoice_model.dart';
import '/appDart/api_constants.dart';

class PurchaseReturnNotForSaleInvoiceService {
  static Future<PurchaseReturnNotForSaleInvoiceModel> fetchInvoice(
      String billNo) async {
    final url = Uri.parse(
        ApiConstants.purchaseReturnNotForSaleInvoice(billNo));

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return PurchaseReturnNotForSaleInvoiceModel.fromJson(jsonData);
    } else {
      throw Exception("Failed to load invoice");
    }
  }
}