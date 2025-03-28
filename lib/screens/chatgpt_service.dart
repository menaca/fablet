import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';


class ChatGPTService {

  final String apiKey = dotenv.env['OPENAI_API_KEY'] ?? '';

  Future<String> generateStory(String name, String hairColor, String eyeColor, String wearDetail,String gender, String place, String event) async {
    final prefs = await SharedPreferences.getInstance();
    bool _switchValue = prefs.getBool('switchValue') ?? false;
    String _dropdownValue = prefs.getString('dropdownValue') ?? 'Orta';

    String storyType = _switchValue ? 'masal' : 'hikaye';  // If switch is true, it's a fairy tale
    String lengthDescription;

    if (_dropdownValue == 'Uzun') {
      lengthDescription = 'Yaklaşık 1200 kelimelik';
    } else if (_dropdownValue == 'Orta'){
      lengthDescription = 'Yaklaşık 800 kelimelik';
    } else if (_dropdownValue == 'Kısa'){
      lengthDescription = 'Yaklaşık 300 kelimelik';
    }else {
      lengthDescription = 'Yaklaşık 800 kelimelik';
    }


    final url = Uri.parse('https://api.openai.com/v1/chat/completions');

    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $apiKey',
      },
      body: json.encode({
        "model": "gpt-4o-mini",
        "messages": [
          {
            "role": "system", //developer
            "content": "Sen bir $storyType yazarısın. Karakterler, ortamlar ve olaylar yaratmada uzmanlaşmış birisin."
          },
          {
            "role": "user",
            "content": "$_dropdownValue uzunlukta bir $storyType oluştur. Karakterin ismi $name, saç rengi $hairColor, göz rengi $eyeColor, üstünde $wearDetail var,  cinsiyeti $gender, ve yer adı $place. Olay: $event. $storyType başlat."
          }
        ],
      }),
    );

    if (response.statusCode == 200) {
      final decodedResponse = utf8.decode(response.bodyBytes);
      final data = json.decode(decodedResponse);
      print(data);
      return data['choices'][0]['message']['content'];

    } else {
      throw Exception('API isteği başarısız oldu: ${response.statusCode}');
    }
  }
}
