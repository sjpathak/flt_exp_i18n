import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:i18n/extensions.dart';
import 'package:flutter/services.dart';

void main() {
  runApp(const MyApp());
}

const languages = {
  'en': 'English',
  'hi': 'Hindi',
  'tl': 'Telugu',
  'pn': 'Punjabi',
  'mr': 'Marathi',
};

const genders = ['male', 'female'];

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Language Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: const MyHomePage(title: 'page_title'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  String _language = languages.keys.first;
  String _gender = genders[0];
  Map<String, dynamic>? translations;

  @override
  void initState() {
    super.initState();

    fetchTranslations();
  }

  void setTranslations(String jsonString) {
    final Map<String, dynamic> jsonMap = json.decode(jsonString);
    setState(() {
      translations = jsonMap;
    });
  }

  Future<void> fetchTranslations({String? lang}) async {
    try {
      final url = 'http://10.0.2.2:3000/lang/${lang ?? _language}';
      final response = await http.get(Uri.parse(url));

      log('URL: $url,  Response: ${response.statusCode}');

      if (response.statusCode == 200) {
        setTranslations(response.body);
      } else {
        throw Exception('Failed to load translations');
      }
    } catch (e) {
      log('Error: $e');
      fetchTranslationsFromAssets(lang: lang ?? _language);
    }
  }

  Future<void> fetchTranslationsFromAssets({String? lang}) async {
    log('Fetching translations from assets');
    try {
      String jsonString = await rootBundle.loadString('assets/languages/$lang.arb');
      setTranslations(jsonString);
    } catch (error) {
      log('Error loading JSON: $error');
    }
  }

  String translate(String key) {
    return translations?[key] ?? key;
  }

  void _setLanguage(String lang) {
    fetchTranslations(lang: lang);

    setState(() {
      _language = lang;
    });
  }

  void _setGender(String gender) {
    setState(() {
      _gender = gender;
    });
  }

  void _showLanguageDropwdown() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: languages.keys
              .map((lang) => ListTile(
                    title: Text(languages[lang]!),
                    onTap: () {
                      _setLanguage(lang);
                    },
                    selected: _language == lang,
                  ))
              .toList(),
        );
      },
    );
  }

  void _showGenderDropwdown() {
    showModalBottomSheet(
      context: context,
      builder: (BuildContext context) {
        return ListView(
          children: genders
              .map((g) => ListTile(
                    title: Text(g),
                    onTap: () {
                      _setGender(g);
                    },
                    selected: _gender == g,
                  ))
              .toList(),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(translate(widget.title)),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: _showLanguageDropwdown,
                  child: Text(
                    translate('select_language'),
                  ),
                ),
                ElevatedButton(
                  onPressed: _showGenderDropwdown,
                  child: Text(
                    translate('select_gender'),
                  ),
                )
              ],
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Text(
                translate('farmer_info_$_gender').format([translate('num_10'), translate('num_4')]),
                style: Theme.of(context).textTheme.headlineSmall,
              ),
            ),
            const SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    translate('button_ok'),
                  ),
                ),
                ElevatedButton(
                  onPressed: () {},
                  child: Text(
                    translate('button_cancel'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
