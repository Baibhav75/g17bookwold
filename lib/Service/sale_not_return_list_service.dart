import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/sale_not_return_list_model.dart';

class SaleNotReturnListService {
  static Future<List<SaleNotReturnItem>> fetchList() async {
    try {
      final response = await http.get(
        Uri.parse(
          "https://g17bookworld.com/api/SampleReturn/SampleNotForSaleReturnList",
        ),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data
            .map((e) => SaleNotReturnItem.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}