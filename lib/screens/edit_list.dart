import 'dart:math';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/material.dart';
import '../data/data_list.dart';


class EditListPage extends StatefulWidget {
  @override
  _EditListPageState createState() => _EditListPageState();
}

class _EditListPageState extends State<EditListPage> {
  bool _switchValue = false;
  String _dropdownValue = 'Orta';

  bool _isLoading = true;

  List<String> names = [];
  List<String> hairColors = [];
  List<String> eyeColors = [];
  List<String> places = [];
  List<String> events = [];

  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLists(); // Verileri yükle
  }

  _loadLists() async {
    names = await DataLists.loadList(DataLists.namesKey, DataLists.names);
    hairColors =
        await DataLists.loadList(DataLists.hairColorsKey, DataLists.hairColors);
    eyeColors =
        await DataLists.loadList(DataLists.eyeColorsKey, DataLists.eyeColors);
    places = await DataLists.loadList(DataLists.placesKey, DataLists.places);
    events = await DataLists.loadList(DataLists.eventsKey, DataLists.events);

    SharedPreferences prefs = await SharedPreferences.getInstance();

    setState(() {
      _switchValue = prefs.getBool('switch_value') ?? false;
      _dropdownValue = prefs.getString('dropdown_value') ?? 'Orta';
      _isLoading = false;
    });
  }

  _addItem(List<String> list, String item) {
    setState(() {
      list.add(item);
    });
    _saveList(list);
  }

  _removeItem(List<String> list, int index) {
    if (list.length > 1) {
      setState(() {
        list.removeAt(index);
      });
      _saveList(list);
    }else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Son öğe silinemez! ✋😡')),
      );
    }

  }

  void _savePreferences() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setBool('switch_value', _switchValue);
    prefs.setString('dropdown_value', _dropdownValue);
  }

  _saveList(List<String> list) {
    if (list == names) {
      DataLists.saveList(DataLists.namesKey, list);
    } else if (list == hairColors) {
      DataLists.saveList(DataLists.hairColorsKey, list);
    } else if (list == eyeColors) {
      DataLists.saveList(DataLists.eyeColorsKey, list);
    } else if (list == places) {
      DataLists.saveList(DataLists.placesKey, list);
    } else if (list == events) {
      DataLists.saveList(DataLists.eventsKey, list);
    }
  }

  _clearTextField() {
    _textController.clear();
  }

  _showAddItemDialog(List<String> list) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Yeni öğe ekleyin'),
          content: TextField(
            controller: _textController,
            decoration: InputDecoration(hintText: 'Yeni öğe'),
          ),
          actions: [
            TextButton(
              onPressed: () {
                if (_textController.text.isNotEmpty) {
                  _addItem(list, _textController.text);
                }
                _clearTextField();
                Navigator.pop(
                    context); // Diğer işlemi gerçekleştirdikten sonra pencereyi kapat
              },
              child: Text('Kaydet'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Cancel
              },
              child: Text('İptal'),
            ),
          ],
        );
      },
    );
  }

  _showDeleteConfirmationDialog(List<String> list, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Emin misiniz?'),
          content: Text('Bu öğeyi silmek istediğinizden emin misiniz?'),
          actions: [
            TextButton(
              onPressed: () {
                _removeItem(list, index);
                Navigator.pop(
                    context); // Silme işlemini yaptıktan sonra pencereyi kapat
              },
              child: Text('Evet'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context); // İptal
              },
              child: Text('Hayır'),
            ),
          ],
        );
      },
    );
  }

  Color getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1.0,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ayarlar', style: TextStyle(fontSize: 30),),
        iconTheme: IconThemeData(color: Colors.white),
      ),
      body: _isLoading ? Center(child: CircularProgressIndicator(color: Colors.white,),):Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            Text('Hikaye Ayarları',
                style: TextStyle(fontSize: 18, color: getRandomColor())),
            SizedBox(height: 10),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text('Masal Modu',
                  style: TextStyle(color: Colors.white, fontSize: 17)),
              subtitle: Text(
                  'Hikayelerden sıkıldınız mı? Bir de masalları deneyin!',
                  style: TextStyle(color: Colors.white24, fontSize: 13)),
              trailing: Switch(
                activeColor: getRandomColor(),
                value: _switchValue,
                onChanged: (bool newValue) {
                  setState(() {
                    _switchValue = newValue;
                  });
                  _savePreferences();
                },
              ),
            ),
            ListTile(
              contentPadding: EdgeInsets.zero,
              title: Text(_switchValue ? 'Masal Uzunluğu' : 'Hikaye Uzunluğu',
                  style: TextStyle(color: Colors.white, fontSize: 17)),
              subtitle: Text('Uzun bir şeyler mi okumak istersiniz kısa mı?',
                  style: TextStyle(color: Colors.white24, fontSize: 13)),
              trailing: DropdownButton<String>(
                value: _dropdownValue,
                onChanged: (String? newValue) {
                  if (newValue != null) {
                    setState(() {
                      _dropdownValue = newValue;
                    });
                    _savePreferences();
                  }
                },  // Text color for selected item
                dropdownColor: Color(0xFF161619),
                items: <String>['Kısa', 'Orta', 'Uzun']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value, style: TextStyle(color: Colors.white),),
                  );
                }).toList(),
              ),
            ),
            SizedBox(height: 20),
            Text('Rastgele Kütüphanesi',
                style: TextStyle(fontSize: 18, color: getRandomColor())),
            _buildSection('İsimler', names),
            _buildSection('Saç Renkleri', hairColors),
            _buildSection('Göz Renkleri', eyeColors),
            _buildSection('Yerler', places),
            _buildSection('Olaylar', events),

            Divider(color:Colors.white10),
            SizedBox(height: 20),
            GestureDetector(onTap: (){
              showDialog(
                context: context,
                builder: (BuildContext context) {
                  return AlertDialog(
                    title: Text("Uyarı"),
                    content: Text("Tüm listeleri sıfırlamak istediğinizden emin misiniz?"),
                    actions: <Widget>[

                      TextButton(
                        child: Text("Evet"),
                        onPressed: () async{
                          await DataLists.resetData();
                          Navigator.of(context).pop();
                          _loadLists();
                        },
                      ),

                      TextButton(
                        child: Text("Hayır"),
                        onPressed: () {
                          Navigator.of(context).pop(); // Dialogu kapat
                        },
                      ),
                    ],
                  );
                },
              );
            },child: Center(child: Text("Tüm Listeleri Sıfırla", style: TextStyle(color: getRandomColor(), fontSize: 14),))),
            SizedBox(height: 20),

          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<String> list) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title, style: TextStyle(color: Colors.white)),
            Padding(
              padding: EdgeInsets.only(right: 15),
              child: GestureDetector(
                onTap: (){
                  _showAddItemDialog(list);
                },
                child: Text(
                  '+',
                  style: TextStyle(color: getRandomColor()),
                ),
              ),
            ),
          ],
        ),
        SizedBox(height: 10),
        list.isEmpty
            ? Center(
                child: Text(
                'Liste boş',
                style: TextStyle(color: Colors.white),
              ))
            : ListView.builder(
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                itemCount: list.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(
                      list[index],
                      style: TextStyle(color: Colors.white70),
                    ),
                    trailing: list.length > 1 ? IconButton(
                      icon: Icon(
                        Icons.delete,
                        color: Colors.white70,
                      ),
                      onPressed: () =>
                          _showDeleteConfirmationDialog(list, index),
                    ) : null,
                  );
                },
              ),
      ],
    );
  }
}
