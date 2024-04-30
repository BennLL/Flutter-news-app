import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '/article_page.dart';

class News4YouScreen extends StatefulWidget {
  const News4YouScreen({super.key});

  @override
  State<News4YouScreen> createState() => _News4YouScreenState();
}

class _News4YouScreenState extends State<News4YouScreen> {
  final String apiUrl =
      'https://1bd4f239-53df-455d-a7d2-f0a8caf7a372-00-25bvk7lybbjfe.picard.replit.dev/fetch_news_based_on_interest';
  Map result = {};

  @override
  initState() {
    super.initState();
    fetchNews();
  }

  Future<String> _loadCategories() async {
    final prefs = await SharedPreferences.getInstance();
    String text = '';
    if (prefs.containsKey('categories')) {
      String? categories = prefs.getString('categories');
      setState(() {
        Map isPressedMap = jsonDecode(categories!);
        isPressedMap.forEach((key, value) {
          if (value) {
            if (text.isEmpty) {
              text += key;
            } else {
              text += ' OR ' + key;
            }
          }
        });
      });
    }
    return text;
  }

  Future<void> fetchNews() async {
    final prefs = await SharedPreferences.getInstance();

    int age = prefs.getInt('age') ?? 6;
    String categories = await _loadCategories();
    final Map<String, dynamic> data = {'age': age, 'interest': categories};

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
        title: const Text('News 4 kids!'),
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
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ArticlePage(
                            article: result[title],
                          ),
                        ),
                      );
                    },
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
                            subtitle: Text(result[title]['description'])),
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
