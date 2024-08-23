import 'dart:convert';
import 'package:http/http.dart' as http;

class Api {
  final apiKey = 'd7121e93e62389413ab0ca736783ad1402491a1ebeb2125b14e81179716ce97b';

  Future<Map<String, dynamic>> cekResi(String kurir, String resi) async {
    final response = await http.get(
      Uri.parse(
        'https://api.binderbyte.com/v1/track?api_key=$apiKey&courier=$kurir&awb=$resi',
      ),
    );

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      return {
        'status': response.statusCode,
        'message': 'Error fetching data',
      };
    }
  }
}
