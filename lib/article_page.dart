import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class ArticlePage extends StatefulWidget {
  final Map article;
  const ArticlePage({
    super.key,
    required this.article,
  });

  @override
  State<ArticlePage> createState() => _ArticlePageState();
}

class _ArticlePageState extends State<ArticlePage> {
  final String apiUrl =
      'https://1bd4f239-53df-455d-a7d2-f0a8caf7a372-00-25bvk7lybbjfe.picard.replit.dev/fetch_content';
  String content = '';

  @override
  void initState() {
    super.initState();
    fetchContent();
  }

  Future<void> fetchContent() async {
    final prefs = await SharedPreferences.getInstance();

    int age = prefs.getInt('age') ?? 6;
    int genderIndex = prefs.getInt('gender') ?? 0;
    String gender = genderIndex == 0 ? 'male' : 'female';

    final Map<String, dynamic> data = {
      'age': age,
      'gender': gender,
      'url': widget.article['url']
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
        content = jsonDecode(response.body);
        // print(content);
      });
    } else {
      throw Exception('Failed to post data');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Article"),
      ),
      body: content.isNotEmpty
          ? SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Image.network(widget.article['urlToImage']),
                    ListTile(
                        title: Text(
                          widget.article['title'],
                          style: const TextStyle(fontSize: 25),
                        ),
                        subtitle: Text('${widget.article['author']} '
                            '- ${widget.article['source']['name']}')),
                    Text(
                      content,
                      style: TextStyle(fontSize: 15),
                    )
                  ],
                ),
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
