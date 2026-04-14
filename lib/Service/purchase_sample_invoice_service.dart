import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/purchase_sample_invoice_model.dart';
import '/appDart/api_constants.dart';

class PurchaseSampleInvoiceService {
  static Future<PurchaseSampleInvoiceModel> fetchInvoice(
      String billNo) async {
    final url = Uri.parse(ApiConstants.purchaseSampleInvoice(billNo));

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return PurchaseSampleInvoiceModel.fromJson(jsonData);
    } else {
      throw Exception("Failed to load invoice");
    }
  }
}