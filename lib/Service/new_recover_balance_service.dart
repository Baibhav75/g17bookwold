import 'dart:convert';
import 'package:http/http.dart' as http;
import '/Model/NewRecoverBalanceModel.dart';
import '/appDart/api_constants.dart';

class NewRecoverBalanceService {
  static Future<List<NewRecoverBalanceModel>> fetchData(int page) async {
    try {
      final response = await http.get(
        Uri.parse("${ApiConstants.newRecoverBalance}?page=$page"),
      );

      if (response.statusCode == 200) {
        final List data = jsonDecode(response.body);

        return data
            .map((e) => NewRecoverBalanceModel.fromJson(e))
            .toList();
      } else {
        return [];
      }
    } catch (e) {
      return [];
    }
  }
}