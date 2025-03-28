import 'package:flutter/material.dart';
import 'package:story_maker/data/data_list.dart';
import 'package:story_maker/screens/settings.dart';
import 'dart:math';
import '../data/image_data.dart';
import 'chatgpt_service.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:animated_text_kit/animated_text_kit.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  DateTime now = DateTime.now();
  String formattedDate = '';

  int _currentStep = 0;
  String _selectedImage = '';
  String _selectedMaleImage = '';
  String _selectedFemaleImage = '';

  final _formKey = GlobalKey<FormState>();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _hairColorController = TextEditingController();
  final TextEditingController _eyeColorController = TextEditingController();
  final TextEditingController _placeController = TextEditingController();
  final TextEditingController _eventController = TextEditingController();
  final TextEditingController _lastController = TextEditingController();

  final List<String> genders = ['Erkek', 'Kadın'];

  String _wearDetail = '';
  String _selectedGender = '';
  String _characterName = '';
  String _hairColor = 'Siyah';
  String _eyeColor = 'Siyah';
  String _place = 'Ankara';
  String _event = 'Tiyatro';

  final List<String> _maleImages =
      List.generate(9, (index) => 'assets/e-${index + 1}.png');
  final List<String> _femaleImages =
      List.generate(9, (index) => 'assets/k-${index + 1}.png');

  void _generateStory() async {
    setState(() {
      _currentStep = -1;
    });
    final service = ChatGPTService();
    final story = await service.generateStory(
      _nameController.text,
      _hairColorController.text,
      _eyeColorController.text,
      _wearDetail,
      _selectedGender,
      _placeController.text,
      _eventController.text,
    );

    formattedDate = DateFormat('d MMMM yyyy HH:mm').format(DateTime.now());

    Map<String, String> storyData = {
      'story': story,
      'selectedImage': _selectedImage,
      'name': _nameController.text,
      'hairColor': _hairColorController.text,
      'eyeColor': _eyeColorController.text,
      'place': _placeController.text,
      'event': _eventController.text,
      'time': formattedDate
    };

    SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String> savedStories = prefs.getStringList('stories') ?? [];
    savedStories.add(jsonEncode(storyData));
    await prefs.setStringList('stories', savedStories);

    setState(() {
      _lastController.text = story;
      _currentStep = 4;
    });
  }

  @override
  void initState() {
    super.initState();
    _selectRandomImages();
  }

  void _selectRandomImages() {
    setState(() {
      _selectedMaleImage = _maleImages[Random().nextInt(_maleImages.length)];
      _selectedFemaleImage =
          _femaleImages[Random().nextInt(_femaleImages.length)];
    });
  }

  void _getCharacterDetailByPhotoPath(String imagePath) {
    final imageFeature = ImageData.imageFeatures[imagePath];

    if (imageFeature != null) {
      setState(() {
        _eyeColorController.text = imageFeature.eyeColor;
        _hairColorController.text = imageFeature.hairColor;
        _wearDetail = imageFeature.wearStyle;
      });
    } else {
      print("No data found for the image: $imagePath");
    }
  }

  void _updateState() async {
    if (_currentStep == 0 && _selectedGender == '') {
      setState(() {
        _selectedGender = genders[Random().nextInt(genders.length)];
        _selectedImage = _selectedGender == 'Erkek' ? _selectedMaleImage : _selectedFemaleImage;

        _getCharacterDetailByPhotoPath(_selectedImage);
      });
    }if (_currentStep == 1 && _nameController.text.isEmpty) {
      _characterName = await DataLists.getRandomName();
      _nameController.text = _characterName;
    }if (_currentStep == 2 && _hairColorController.text.isEmpty) {
      _hairColor = await DataLists.getRandomHairColor();
      _hairColorController.text = _hairColor;
    }if (_currentStep == 2 && _eyeColorController.text.isEmpty) {
      _eyeColor = await DataLists.getRandomEyeColor();
      _eyeColorController.text = _eyeColor;
    }

    setState(() {
      _currentStep++;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PixelBackground(),

          CustomScrollView(
          slivers: [
          SliverAppBar(
          floating: true,
          backgroundColor: Colors.transparent,
          pinned: false,
          snap: true,
          title: RandomColorText('fablet'),
          actions: [
            _currentStep != -1 ?
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => SettingsPage()),
                );
              },
              child: Image.asset(
                'assets/icons/settings.png',
                color: Colors.white,
                width: 30,
                height: 30,
              ),
            ): SizedBox(),
            SizedBox(width: 20),
          ],
        ),
        SliverList(
          delegate: SliverChildListDelegate([
            if(_currentStep != 4)
            SizedBox(
              height: MediaQuery.of(context).size.height - 100,
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (_currentStep == -1) _buildLoaing(),
                    if (_currentStep == 0) _buildGenderSelection(),
                    if (_currentStep == 1) _buildCharacterNameInput(),
                    if (_currentStep == 2) _buildHairAndEyeColorInputs(),
                    if (_currentStep == 3) _buildPlaceInput(),
                    Spacer(),
                    Padding(
                        padding:
                        EdgeInsets.only(left: 24, right: 24, bottom: 150),
                        child: _buildNavigationButtons()),
                  ],
                ),
              ),
            ),
            if (_currentStep == 4) _buildParagraphInput(),

          ]),
            )]),
      ]));
  }

  Widget _buildLoaing() {
    return Center(  // Center widget'ı ile ortalayın
      child: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height - 100,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,  // Yatayda ortalar
          crossAxisAlignment: CrossAxisAlignment.center, // Dikeyde ortalar
          children: [
            CircularProgressIndicator(color: Colors.white),
            SizedBox(height: 20),  // Görseller arasına boşluk ekler
            AnimatedTextKit(
              repeatForever: true,
              animatedTexts: [
                TypewriterAnimatedText(
                  'Yükleniyor...',
                  speed: Duration(milliseconds: 150),
                  textStyle: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            Text("Hikayeniz oluşturuluyor. \n${_selectedGender} \n${_nameController.text} İsminde \n${_hairColorController.text} Saçlı \n${_eyeColorController.text} Gözlü \n${_wearDetail} Giyinmiş \n${_placeController.text} Yerinde \n${_eventController.text} Olayı",style: TextStyle(color: Colors.white24,fontSize: 12))
          ],
        ),
      ),
    );
  }

  Widget _buildGenderSelection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        SizedBox(height: 120),
        Text("Karakteriniz",
            style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
                color: Colors.white)),
        SizedBox(height: 30),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: genders.map((gender) {
            bool isSelected = _selectedGender == gender;
            return GestureDetector(
              onTap: () {
                setState(() {
                  _selectedGender = gender;
                  _selectedImage = gender == 'Erkek'
                      ? _selectedMaleImage
                      : _selectedFemaleImage;

                  _getCharacterDetailByPhotoPath(_selectedImage);
                });
              },
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.transparent,
                  backgroundImage: AssetImage(gender == 'Erkek'
                      ? _selectedMaleImage
                      : _selectedFemaleImage),
                  child: isSelected
                      ? Container(
                          width: 100,
                          height: 100,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: Colors.blue,
                              width: 3,
                            ),
                            shape: BoxShape.circle,
                          ),
                        )
                      : SizedBox(),
                ),
              ),
            );
          }).toList(),
        ),
        SizedBox(height: 50),
        GestureDetector(
            onTap: () {
              _selectRandomImages();

              _selectedImage = _selectedGender == 'Erkek'
                  ? _selectedMaleImage
                  : _selectedFemaleImage;

              _getCharacterDetailByPhotoPath(_selectedImage);
            },
            child: Image.asset(
              'assets/icons/restart.png',
              width: 50,
              color: Colors.white,
            )),
      ],
    );
  }

  Widget _buildCharacterNameInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 50),
          CircleAvatar(
              radius: 70,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(_selectedImage)),
          SizedBox(height: 50),
          Text("Karakter İsmi",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 18),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _nameController,
                  cursorColor: Colors.white30,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF1E1F23),
                    hintText: "Karakter İsmi Girin",
                    hintStyle: TextStyle(color: Colors.white10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _characterName = value;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.shuffle),
                onPressed: () {
                  setState(() async {
                    _characterName = await DataLists.getRandomName();
                    _nameController.text = _characterName;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildHairAndEyeColorInputs() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 50),
          CircleAvatar(
              radius: 70,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(_selectedImage)),
          SizedBox(height: 5),
          Text(_nameController.text,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 30),
          Text("Karakterinin Saç Rengi",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _hairColorController,
                  cursorColor: Colors.white30,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF1E1F23),
                    hintText: "Saç Rengini Girin",
                    hintStyle: TextStyle(color: Colors.white10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _hairColor = value;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.shuffle),
                onPressed: () {
                  setState(() async {
                    _hairColor = await DataLists.getRandomHairColor();
                    _hairColorController.text = _hairColor;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 30),
          Text("Karakterinin Göz Rengi",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _eyeColorController,
                  cursorColor: Colors.white30,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF1E1F23),
                    hintText: "Göz Rengini Girin",
                    hintStyle: TextStyle(color: Colors.white10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _eyeColor = value;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.shuffle),
                onPressed: () {
                  setState(() async {
                    _eyeColor = await DataLists.getRandomEyeColor();
                    _eyeColorController.text = _eyeColor;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPlaceInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 50),
          CircleAvatar(
              radius: 70,
              backgroundColor: Colors.transparent,
              backgroundImage: AssetImage(_selectedImage)),
          SizedBox(height: 5),
          Text(_nameController.text,
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 5),
          Text(
              "${_hairColorController.text} Saçlı ${_eyeColorController.text} Gözlü",
              style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.white30)),
          SizedBox(height: 30),
          Text("Hikaye Nerde Geçiyor?",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _placeController,
                  cursorColor: Colors.white30,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF1E1F23),
                    hintText: "Yer İsmi Girin",
                    hintStyle: TextStyle(color: Colors.white10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.white, width: 2),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _place = value;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.shuffle),
                onPressed: () {
                  setState(() async {
                    _place = await DataLists.getRandomPlace();
                    _placeController.text = _place;
                  });
                },
              ),
            ],
          ),
          SizedBox(height: 20),
          Text("Olayı Şekillendirelim",
              style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.white)),
          SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _eventController,
                  cursorColor: Colors.white30,
                  style: TextStyle(
                    color: Colors.white,
                  ),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: Color(0xFF1E1F23),
                    hintText: "Bir Olay Girin",
                    hintStyle: TextStyle(color: Colors.white10),
                    border: OutlineInputBorder(),
                    focusedBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Colors.white, width: 2)),
                    enabledBorder: OutlineInputBorder(
                      borderSide: BorderSide(color: Colors.grey, width: 2),
                    ),
                  ),
                  onChanged: (value) {
                    setState(() {
                      _place = value;
                    });
                  },
                ),
              ),
              IconButton(
                icon: Icon(Icons.shuffle),
                onPressed: () {
                  setState(() async {
                    _event = await DataLists.getRandomEvent();
                    _eventController.text = _event;
                  });
                },
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildParagraphInput() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          SizedBox(height: 10),
          Text(
            "İşte Eşsiz Hikayen",
            style: TextStyle(
                fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
          ),
          SizedBox(height: 10),
          // Wrap the Text widget inside a SingleChildScrollView
          Text(
            _lastController.text,
            style: TextStyle(color: Colors.white),
            maxLines: null, // Allow the text to be as long as necessary
            overflow: TextOverflow.visible,
          ),
          SizedBox(height: 30),

          OutlinedButton(
            style: OutlinedButton.styleFrom(
              side: BorderSide(color: Color(0xFF8AC186), width: 3),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
              ),
              backgroundColor: Colors.transparent,
              minimumSize: Size(double.infinity, 50),
            ),
            onPressed: () {
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => HomePage()),
              );
            },
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Text(
                'Ana Sayfa',
                style: TextStyle(
                  color: Color(0xFF8AC186),
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                ),
              ),
            ),
          ),

          SizedBox(height: 50),

        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        if (_currentStep > 0 && _currentStep != 4)
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Colors.red, width: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.transparent,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                setState(() {
                  _currentStep--;
                });
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Geri',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        if (_currentStep > 0 && _currentStep < 3) SizedBox(width: 20),
        if (_currentStep < 3 && _currentStep != -1)
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFF8AC186), width: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.transparent,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () {
                _updateState();
              },
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'İleri',
                  style: TextStyle(
                    color: Color(0xFF8AC186),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
        if (_currentStep == 3) SizedBox(width: 20),
        if (_currentStep == 3)
          Expanded(
            child: OutlinedButton(
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: Color(0xFFFFD47F), width: 3),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                backgroundColor: Colors.transparent,
                minimumSize: Size(double.infinity, 50),
              ),
              onPressed: () async {
                if (_formKey.currentState?.validate() ?? false) {
                  if (_currentStep == 3 && _placeController.text.isEmpty) {
                    _place = await DataLists.getRandomPlace();
                    _placeController.text = _place;
                  }if (_currentStep == 3 && _eventController.text.isEmpty) {
                    _event = await DataLists.getRandomEvent();
                    _eventController.text = _event;
                  }

                  _generateStory();
                }
              },
              child: Padding(
                padding: EdgeInsets.symmetric(vertical: 20),
                child: Text(
                  'Oluştur',
                  style: TextStyle(
                    color: Color(0xFFFFD47F),
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ),
      ],
    );
  }
}

class RandomColorText extends StatelessWidget {
  final String text;

  RandomColorText(this.text);

  Color _getRandomColor() {
    Random random = Random();
    return Color.fromRGBO(
      random.nextInt(256),
      random.nextInt(256),
      random.nextInt(256),
      1,
    );
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> coloredText = [];

    for (int i = 0; i < text.length; i++) {
      coloredText.add(
        Text(
          text[i],
          style: TextStyle(
              fontFamily: 'Thaleah', color: _getRandomColor(), fontSize: 50),
        ),
      );
    }
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: coloredText,
    );
  }
}

class PixelBackground extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: Size(double.infinity, double.infinity), // Ekranın tamamını kaplar
      painter: PixelPainter(),
    );
  }
}

class PixelPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = Color(0xFF303030)
      ..style = PaintingStyle.fill;

    double tileSize = 30;
    double offsetX = 0;
    double offsetY = 0;

    for (double y = 0; y < size.height; y += tileSize) {
      for (double x = 0; x < size.width; x += tileSize) {
        canvas.save();
        canvas.translate(x + tileSize / 2, y + tileSize / 2);
        canvas.rotate(-0.2);
        canvas.translate(-tileSize / 2, -tileSize / 2);

        canvas.drawCircle(Offset(offsetX, offsetY), 3.0, paint);

        canvas.restore();
      }
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
