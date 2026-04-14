import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/purchase_return_sample_revenew_details_model.dart';
import '/appDart/api_constants.dart';

class PurchaseReturnService {
  static Future<PurchaseReturnSampleRevenewDetailsModel?> fetchInvoice(String billNo) async {
    try {
      final response = await http.get(
        Uri.parse(ApiConstants.purchaseInvoice(billNo)),
      );

      if (response.statusCode == 200) {
        final jsonData = jsonDecode(response.body);
        return PurchaseReturnSampleRevenewDetailsModel.fromJson(jsonData);
      } else {
        print("API Error: ${response.statusCode}");
        return null;
      }
    } catch (e) {
      print("Exception: $e");
      return null;
    }
  }
}