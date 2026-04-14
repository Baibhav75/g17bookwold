import 'dart:convert';
import 'package:http/http.dart' as http;
import '../model/sale_return_mrp_invoice_model.dart';
import '/appDart/api_constants.dart';

class SaleReturnMrpInvoiceService {
  static Future<SaleReturnMrpInvoiceModel> fetchInvoice(
      String billNo) async {
    final url =
    Uri.parse(ApiConstants.saleReturnMrpInvoice(billNo));

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = jsonDecode(response.body);
      return SaleReturnMrpInvoiceModel.fromJson(jsonData);
    } else {
      throw Exception("Failed to load invoice");
    }
  }
}