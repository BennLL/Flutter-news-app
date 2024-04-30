import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final String apiUrl = 'https://1bd4f239-53df-455d-a7d2-f0a8caf7a372-00-25bvk7lybbjfe.picard.replit.dev/fetch_news';
  Map result = {};

  @override
  initState() {
    super.initState();
    fetchNews();
  }

  Future<void> fetchNews() async {
    final prefs = await SharedPreferences.getInstance();

    int age = prefs.getInt('age') ?? 6;
    final Map<String, dynamic> data = {
      'age': age,
    };

    final response = await http.post(
      Uri.parse(apiUrl),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(data),
    );

    if (response.statusCode == 200) {
      setState(() {
        result = jsonDecode(response.body);
        print(result);
      });
    } else {
      throw Exception('Failed to post data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: false,
        title: const Text('Welcome to News4Kids!'),
        automaticallyImplyLeading: false,
      ),
      body: result.isNotEmpty
          ? Padding(
              padding: const EdgeInsets.all(8.0),
              child: ListView.separated(
                padding: const EdgeInsets.all(8),
                itemCount: result.length,
                itemBuilder: (BuildContext context, int index) {
                  String title = result.keys.elementAt(index);
                  return GestureDetector(
                    onTap: () {},
                    child: ListView(
                      shrinkWrap: true,
                      physics: const ClampingScrollPhysics(),
                      children: [
                        SizedBox(
                          height: 200,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Image.network(
                              result[title]['urlToImage'],
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                        ListTile(
                          title: Text(
                            title,
                            style: const TextStyle(fontSize: 20),
                          ),
                          subtitle: Text(result[title]['description']),
                        ),
                      ],
                    ),
                  );
                },
                separatorBuilder: (BuildContext context, int index) =>
                    const Divider(),
              ),
            )
          : const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [CircularProgressIndicator()],
              ),
            ),
    );
  }
}
