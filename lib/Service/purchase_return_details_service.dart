import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/purchase_return_details_model.dart';
import '/appDart/api_constants.dart';

class PurchaseReturnDetailsService {
  static Future<PurchaseReturnDetailsModel> fetch(String billNo) async {
    final url = Uri.parse(ApiConstants.purchaseReturnDetails(billNo));

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final jsonData = json.decode(response.body);
      return PurchaseReturnDetailsModel.fromJson(jsonData);
    } else {
      throw Exception("Failed to load data");
    }
  }
}