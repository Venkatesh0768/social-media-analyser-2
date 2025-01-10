import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:social_media/main.dart';

class AstraService {
  final String endpoint = Environment.get('API_URL');
  final String token = Environment.get('APP_TOKEN');

  Future<Map<String, dynamic>> fetchAnalytics() async {
    final response = await http.get(
      Uri.parse('$endpoint/api/rest/v2/keyspaces/default_keyspace/analytics'),
      headers: {
        'x-cassandra-token': token,
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load analytics data');
    }
  }
}
