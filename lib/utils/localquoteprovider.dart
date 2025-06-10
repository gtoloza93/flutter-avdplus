import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LocalQuoteProvider {
  static Future<List<String>> loadQuotesFromAsset() async {
    final String response = await rootBundle.loadString('assets/data/motivationalphrases.json');
    return List<String>.from(json.decode(response));
  }

  static Future<String> getRandomQuote() async {
    final quotes = await loadQuotesFromAsset();
    final index = DateTime.now().minute ~/ 5; // 0 o 1 si son 0-30 o 30-60
    return quotes[index % quotes.length];
  }
}