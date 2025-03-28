import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';

class DataLists {
  static const String namesKey = 'namesKey';
  static const String hairColorsKey = 'hairColorsKey';
  static const String eyeColorsKey = 'eyeColorsKey';
  static const String placesKey = 'placesKey';
  static const String eventsKey = 'eventsKey';

  static final List<String> _names = ['Beril', 'Mehmet', 'Hüseyin', 'Burak', 'Cemre', 'Zeynep', 'Ada', 'Tuana', 'Efe', 'Kıvanç', 'Kaya', 'Nazım', 'Deniz', 'Ceren', 'Ozan'];
  static final List<String> _hairColors = ['Siyah', 'Sarışın', 'Kahverengi', 'Kızıl', 'Kumral'];
  static final List<String> _eyeColors = ['Kahverengi', 'Mavi', 'Yeşil', 'Ela'];
  static final List<String> _places = ['New York', 'Ankara', 'Muğla', 'Norveç', 'Londra', 'Los Angeles', 'Paris', 'Tokyo', 'İspanya', 'İngiltere'];
  static final List<String> _events = ['Aşk', 'Yürüyüş', 'Tutku', 'Kahve', 'Yağmur', 'Puro', 'Romantizm', 'Müzik', 'Dans', 'Yüzme', 'Keşif', 'Spor', 'Dağ Yürüyüşü', 'Futbol', 'Döner Yemek', 'Basketbol'];

  static List<String> get names => _names;
  static List<String> get hairColors => _hairColors;
  static List<String> get eyeColors => _eyeColors;
  static List<String> get places => _places;
  static List<String> get events => _events;

  static Future<List<String>> loadList(String key, List<String> defaultList) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedList = prefs.getStringList(key);
    if (savedList != null) {
      return savedList;
    }
    return defaultList;
  }

  static Future<void> saveList(String key, List<String> list) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setStringList(key, list);
  }

  static String getRandomElement(List<String> list) {
    Random random = Random();
    int index = random.nextInt(list.length);
    return list[index];
  }

  static Future<String> getRandomName() async {
    List<String> names = await loadList(namesKey, _names);
    return getRandomElement(names);
  }

  static Future<String> getRandomHairColor() async {
    List<String> hairColors = await loadList(hairColorsKey, _hairColors);
    return getRandomElement(hairColors);
  }

  static Future<String> getRandomEyeColor() async {
    List<String> eyeColors = await loadList(eyeColorsKey, _eyeColors);
    return getRandomElement(eyeColors);
  }

  static Future<String> getRandomPlace() async {
    List<String> places = await loadList(placesKey, _places);
    return getRandomElement(places);
  }

  static Future<String> getRandomEvent() async {
    List<String> events = await loadList(eventsKey, _events);
    return getRandomElement(events);
  }

  static Future<void> saveNames(List<String> names) async {
    await saveList(namesKey, names);
  }

  static Future<void> saveHairColors(List<String> hairColors) async {
    await saveList(hairColorsKey, hairColors);
  }

  static Future<void> saveEyeColors(List<String> eyeColors) async {
    await saveList(eyeColorsKey, eyeColors);
  }

  static Future<void> savePlaces(List<String> places) async {
    await saveList(placesKey, places);
  }

  static Future<void> saveEvents(List<String> events) async {
    await saveList(eventsKey, events);
  }

  static Future<void> resetData() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(namesKey, _names);
    await prefs.setStringList(hairColorsKey, _hairColors);
    await prefs.setStringList(eyeColorsKey, _eyeColors);
    await prefs.setStringList(placesKey, _places);
    await prefs.setStringList(eventsKey, _events);
  }
}
