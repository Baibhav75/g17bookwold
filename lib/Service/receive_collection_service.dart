import 'dart:convert';
import 'package:http/http.dart' as http;
import '../Model/receive_collection_model.dart';

class ReceiveCollectionService {
  static Future<ReceiveCollectionModel?> fetchData() async {
    final url = Uri.parse(
        "https://g17bookworld.com/api/RecoveryAmountRececiveList/GetPendingPayments");

    try {
      final response = await http.get(url);

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        return ReceiveCollectionModel.fromJson(jsonData);
      }
    } catch (e) {
      print("Error: $e");
    }

    return null;
  }
}