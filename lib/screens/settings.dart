import 'dart:convert'; // JSON decode için
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:story_maker/screens/edit_list.dart';
import 'package:flutter/services.dart'; // Kopyalama işlemi için
import 'package:share_plus/share_plus.dart'; // share_plus import

class SettingsPage extends StatefulWidget {
  @override
  _SettingsPageState createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  List<Map<String, String>> _savedStories = [];

  @override
  void initState() {
    super.initState();
    _loadSavedStories();
  }

  void _loadSavedStories() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedStories = prefs.getStringList('stories') ?? [];

    setState(() {
      _savedStories = savedStories
          .map((story) => Map<String, String>.from(jsonDecode(story)))
          .toList();
    });
  }

  void _removeStory(int index) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedStories = prefs.getStringList('stories') ?? [];
    savedStories.removeAt(index);
    await prefs.setStringList('stories', savedStories);

    setState(() {
      _savedStories.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          'Hikayeler',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        actions: [

          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditListPage()),
              );
            },
            child: Image.asset(
              'assets/icons/settings_more.png',
              color: Colors.white,
              width: 30,
              height: 30,
            ),
          ),
          SizedBox(width: 20),
        ],
      ),
      body: _savedStories.isEmpty
          ? Center(child: Text('Henüz kaydedilmiş hikaye yok.',style: TextStyle(color: Colors.white),))
          : ListView.builder(
            itemCount: _savedStories.length,
            itemBuilder: (context, index) {
              final story = _savedStories[index];
              return ListTile(
                leading: CircleAvatar(
                  radius: 30,
                  backgroundImage: AssetImage(story['selectedImage']!),
                ),
                title: Text(
                  story['name'] ?? 'Bilinmiyor',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold),
                ),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "${story['hairColor']} Saçlı ${story['eyeColor']} Gözlü" ??
                            'Özellikler bulunamadı.',
                        style: TextStyle(
                          color: Colors.white54,
                          fontSize: 14,
                        )),
                    Text('${story['time'] ?? 'Tarih bulunamadı.'}',
                        style: TextStyle(
                          color: Colors.white70,
                          fontSize: 8,
                        )),
                  ],
                ),
                trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // Silme işlemi için onay diyaloğu göster
                      showDialog(
                        context: context,
                        builder: (context) => AlertDialog(
                          title: Text('Silme Onayı'),
                          content: Text(
                              '"${story['name']}" hikayesini silmek istediğinizden emin misiniz?'),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                Navigator.of(context)
                                    .pop(); // Diyaloğu kapat
                              },
                              child: Text('Hayır'),
                            ),
                            TextButton(
                              onPressed: () {
                                // Evet, öğeyi sil
                                _removeStory(index);
                                Navigator.of(context)
                                    .pop(); // Diyaloğu kapat
                              },
                              child: Text('Evet'),
                            ),
                          ],
                        ),
                      );
                    }),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) =>
                          StoryDetailPage(story: story),
                    ),
                  );
                },
              );
            },
          ),
    );
  }
}

class StoryDetailPage extends StatelessWidget {
  final Map<String, String> story;

  StoryDetailPage({required this.story});

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
  }

  void _shareStory(String text) {
    Share.share(text);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        iconTheme: IconThemeData(color: Colors.white),
        title: Text(
          story['name'] ?? 'Bilinmiyor',
          style: TextStyle(color: Colors.white, fontSize: 30),
        ),
        actions: [
          // Paylaş Butonu
          IconButton(
            icon: Icon(Icons.share),
            onPressed: () =>
                _shareStory(story['story'] ?? 'Hikaye bulunamadı.'),
          ),
          // Kopyala Butonu
          IconButton(
            icon: Icon(Icons.copy),
            onPressed: () =>
                _copyToClipboard(story['story'] ?? 'Hikaye bulunamadı.'),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Hikaye: ',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold)),
              SizedBox(height: 10),
              Text(story['story'] ?? 'Hikaye bulunamadı.',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              SizedBox(height: 20),
              Text('------',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              SizedBox(
                height: 20,
              ),
              Text('Tarih: ${story['time'] ?? 'Tarih bulunamadı.'}',
                  style: TextStyle(color: Colors.white70, fontSize: 16)),
              SizedBox(
                height: 100,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
