import 'dart:convert';
import 'package:http/http.dart' as http;

class LibreTranslateService {
  static const String _baseUrl = 'https://libretranslate.com/translate';

  Future<String> translate({
    required String text,
    required String from,
    required String to,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_baseUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'q': text, 'source': from, 'target': to, 'format': 'text'}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['translatedText'] as String? ?? text;
      } else {
        throw Exception('Translation failed: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Translation error: $e');
    }
  }

  Future<List<String>> translateBatch({
    required List<String> texts,
    required String from,
    required String to,
  }) async {
    final results = <String>[];
    for (final t in texts) {
      try {
        final r = await translate(text: t, from: from, to: to);
        results.add(r);
      } catch (_) {
        results.add(t); // fallback to original
      }
    }
    return results;
  }
}
