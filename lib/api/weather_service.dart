import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../models/weather_model.dart';

class WeatherService {
  final String apiKey = '192a79794062fa9e3d53e2bf303c2413'; 
  final String city = 'Bangka';

  Future<Weather?> fetchWeather() async {
    final url =
        'https://api.openweathermap.org/data/2.5/weather?q=bangka-belitung&appid=2201a4bcf6b0055ff422c2993c10f6cc&units=metric&lang=id';
    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return Weather.fromJson(data);
      } else {
        print('Gagal mengambil data cuaca: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      print('Terjadi kesalahan: $e');
      return null;
    }
  }
}
