import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  ProfilePageState createState() => ProfilePageState();
}

enum Gender {
  male,
  female,
}

class ProfilePageState extends State<ProfilePage> {
  Image img =
      Image.asset('assets/logo.png', height: 100, width: 100, fit: BoxFit.fill);
  Gender selectedGender = Gender.female;
  int age = 2007;
  String name = '';
  Map<String, dynamic> isPressedMap = {
    'tech': false,
    'business': false,
    'politics': false,
    'entertainment': false,
    'health': false,
    'art': false,
    'travel': false,
    'sport': false
  };

  final ImagePicker _picker = ImagePicker();

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  _loadProfile() {
    _loadUsername();
    _loadAge();
    _loadCategories();
    _loadImage();
    _loadGender();
    _saveProfileData();
    _saveCategory();
  }

  _loadImage() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('image_profile')) {
      String path = prefs.getString('image_profile')!;
      img = Image.file(File(path), height: 100, width: 100, fit: BoxFit.fill);
      setState(() {});
    }
  }

  Future<void> _loadUsername() async {
    final prefs = await SharedPreferences.getInstance();
    name = prefs.getString('username') ?? 'User';
    setState(() {});
  }

  Future<void> _loadGender() async {
    final prefs = await SharedPreferences.getInstance();
    int genderIndex = prefs.getInt('gender') ?? 0;
    selectedGender = genderIndex == 0 ? Gender.male : Gender.female;
    setState(() {});
  }

  Future<void> _saveCategory() async {
    final prefs = await SharedPreferences.getInstance();
    String categories = jsonEncode(isPressedMap);
    prefs.setString('categories', categories);
  }

  Future<void> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('Categories')) {
      String? categories = prefs.getString('categories');
      setState(() {
        isPressedMap = jsonDecode(categories!);
      });
    }
  }

  Future<void> _loadAge() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      age = prefs.getInt('age') ?? 6;
    });
  }

  _saveImage(File image) async {
    final appDir = await getApplicationDocumentsDirectory();
    final fileName = DateTime.now().millisecondsSinceEpoch.toString();
    final savedImage = File('${appDir.path}/$fileName.png');
    await image.copy(savedImage.path);
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('image_profile', '${appDir.path}/$fileName.png');
  }

  _imgFromGallery() async {
    final image =
        await _picker.pickImage(source: ImageSource.gallery, imageQuality: 50);

    if (image != null) {
      setState(() {
        img = Image.file(File(image.path),
            height: 100, width: 100, fit: BoxFit.fill);
        _saveImage(File(image.path));
      });
    }
  }

  void _showEditProfileDialog(BuildContext context) {
    TextEditingController usernameController =
        TextEditingController(text: name);
    TextEditingController ageController =
        TextEditingController(text: age.toString());
    showDialog(
        context: context,
        builder: (context) {
          return StatefulBuilder(
            builder: (context, setState) {
              return AlertDialog(
                title: Text('Edit Profile'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: usernameController,
                      decoration: InputDecoration(labelText: 'Username'),
                      onChanged: (value) {
                        setState(() {
                          name = value;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    TextField(
                      controller: ageController,
                      decoration: InputDecoration(labelText: 'Age'),
                      keyboardType: TextInputType.number,
                      onChanged: (value) {
                        setState(() {
                          age = int.tryParse(value) ?? 0;
                        });
                      },
                    ),
                    SizedBox(height: 16),
                    Text('Gender:'),
                    Row(
                      children: <Widget>[
                        Row(
                          children: <Widget>[
                            Radio(
                              value: Gender.male,
                              groupValue: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value as Gender;
                                });
                              },
                            ),
                            Text('Male'),
                            Radio(
                              value: Gender.female,
                              groupValue: selectedGender,
                              onChanged: (value) {
                                setState(() {
                                  selectedGender = value as Gender;
                                });
                              },
                            ),
                            Text('Female'),
                          ],
                        ),
                      ],
                    ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: Text('Cancel'),
                  ),
                  TextButton(
                    onPressed: () {
                      _saveProfileData();
                      Navigator.of(context).pop();
                    },
                    child: Text('Save'),
                  ),
                ],
              );
            },
          );
        });
  }

  void _saveProfileData() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString('username', name);
    prefs.setInt('age', age);
    prefs.setInt('gender', selectedGender.index);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Profile'),
          automaticallyImplyLeading: false,
        ),
        body: Stack(
          children: [
            SingleChildScrollView(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Stack(
                    children: [
                      BigCard(imagePath: img, name: name, age: age),
                      Positioned(
                        right: 20,
                        top: 20,
                        child: IconButton(
                            onPressed: () {
                              _showEditProfileDialog(context);
                            },
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.white,
                            )),
                      ),
                      Positioned(
                        right: 20,
                        top: 60,
                        child: IconButton(
                            onPressed: () {
                              _imgFromGallery();
                            },
                            icon: const Icon(
                              Icons.add_photo_alternate,
                              color: Colors.white,
                            )),
                      )
                    ],
                  ),
                ),
                const Padding(
                  padding: EdgeInsets.all(12.0),
                  child: Text(
                    'Select your interests',
                    style: TextStyle(fontSize: 25),
                  ),
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPressedMap['tech'] = !isPressedMap['tech']!;
                          _saveCategory();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPressedMap['tech']!
                            ? Theme.of(context).primaryColorLight
                            : Colors.green,
                      ),
                      child: const Text(
                        "#Tech + Science",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPressedMap['business'] = !isPressedMap['business']!;
                          _saveCategory();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPressedMap['business']!
                            ? Theme.of(context).primaryColorLight
                            : Colors.green,
                      ),
                      child: const Text(
                        "#Business",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPressedMap['politics'] = !isPressedMap['politics']!;
                          _saveCategory();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPressedMap['politics']!
                            ? Theme.of(context).primaryColorLight
                            : Colors.green,
                      ),
                      child: const Text(
                        "#Politics",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPressedMap['entertainment'] =
                              !isPressedMap['entertainment']!;
                          _saveCategory();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPressedMap['entertainment']!
                            ? Theme.of(context).primaryColorLight
                            : Colors.green,
                      ),
                      child: const Text(
                        "#Entertainment",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPressedMap['health'] = !isPressedMap['health']!;
                          _saveCategory();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPressedMap['health']!
                            ? Theme.of(context).primaryColorLight
                            : Colors.green,
                      ),
                      child: const Text(
                        "#Health Interests",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPressedMap['art'] = !isPressedMap['art']!;
                          _saveCategory();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPressedMap['art']!
                            ? Theme.of(context).primaryColorLight
                            : Colors.green,
                      ),
                      child: const Text(
                        "#Art",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPressedMap['travel'] = !isPressedMap['travel']!;
                          _saveCategory();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPressedMap['travel']!
                            ? Theme.of(context).primaryColorLight
                            : Colors.green,
                      ),
                      child: const Text(
                        "#Travel",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton(
                      onPressed: () {
                        setState(() {
                          isPressedMap['sport'] = !isPressedMap['sport']!;
                          _saveCategory();
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isPressedMap['sport']!
                            ? Theme.of(context).primaryColorLight
                            : Colors.green,
                      ),
                      child: const Text(
                        "#Sport",
                        style: TextStyle(
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ],
                )
              ],
            ))
          ],
        ));
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    Key? key,
    required this.imagePath,
    required this.name,
    required this.age,
  }) : super(key: key);

  final Image imagePath;
  final String name;
  final int age;

  @override
  Widget build(BuildContext context) {
    var theme = Theme.of(context);
    var style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
      fontSize: 40,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 200),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircleAvatar(
                radius: 60,
                backgroundColor: Colors.transparent,
                child: ClipOval(
                  child: imagePath,
                ),
              ),
              Text(
                name,
                style: style.copyWith(fontWeight: FontWeight.w200),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '$age Year-old',
                    style: style.copyWith(fontWeight: FontWeight.w100),
                  )
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
