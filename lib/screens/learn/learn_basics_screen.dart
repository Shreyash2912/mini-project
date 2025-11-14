// lib/screens/learn/learn_basics_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../providers/app_state.dart';
import '../../services/libretranslate_service.dart';

class LearnBasicsScreen extends StatefulWidget {
  const LearnBasicsScreen({super.key});

  @override
  State<LearnBasicsScreen> createState() => _LearnBasicsScreenState();
}

class _LearnBasicsScreenState extends State<LearnBasicsScreen> {
  final _service = LibreTranslateService();
  final _tts = FlutterTts();
  bool _loading = false;
  final _phrases = ['Hello', 'Good morning', 'Thank you', 'Please', 'Goodbye', 'How are you?', 'See you later'];
  List<String>? _translated;
  String? _titleText;
  String? _subtitleText;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final lang = context.read<AppState>().targetLanguageCode ?? 'es';
    try {
      // Translate phrases
      final list = await _service.translateBatch(texts: _phrases, from: 'en', to: lang);
      
      // Translate UI text
      final title = await _service.translate(text: 'Essential Phrases', from: 'en', to: lang);
      final subtitle = await _service.translate(text: 'Tap a phrase to add to favorites', from: 'en', to: lang);
      
      if (!mounted) return;
      setState(() {
        _translated = list;
        _titleText = title;
        _subtitleText = subtitle;
      });
    } catch (e) {
      setState(() {
        _translated = List<String>.from(_phrases);
        _titleText = 'Essential Phrases';
        _subtitleText = 'Tap a phrase to add to favorites';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _speak(String text, String langCode) async {
    final ttsCode = _ttsCode(langCode);
    await _tts.setLanguage(ttsCode);
    await _tts.setSpeechRate(0.55);
    await _tts.speak(text);
  }

  String _ttsCode(String code) {
    return {
      'fr': 'fr-FR',
      'es': 'es-ES',
      'de': 'de-DE',
      'it': 'it-IT',
      'pt': 'pt-PT',
      'hi': 'hi-IN',
      'ja': 'ja-JP',
      'ko': 'ko-KR',
      'zh': 'zh-CN',
      'ru': 'ru-RU',
    }[code] ?? 'en-US';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Basics'), backgroundColor: Colors.white, elevation: 0),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _titleText ?? 'Essential Phrases',
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _subtitleText ?? 'Tap a phrase to add to favorites',
                    style: TextStyle(color: Colors.grey.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            Expanded(child: ListView.separated(
              itemCount: _phrases.length,
              separatorBuilder: (_,__)=>const SizedBox(height: 8),
              itemBuilder: (context, i) {
                final src = _phrases[i];
                final dst = (_translated != null && i < _translated!.length) ? _translated![i] : src;
                final isFav = app.isFavorite(dst);
                return Card(
                  child: ListTile(
                    title: Text(dst, style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 18)),
                    subtitle: Text(src, style: TextStyle(color: Colors.grey.shade600)),
                    leading: IconButton(
                      icon: const Icon(Icons.volume_up, color: Color(0xFF58CC02)),
                      onPressed: () => _speak(dst, app.targetLanguageCode ?? 'es'),
                    ),
                    trailing: IconButton(
                      icon: Icon(isFav ? Icons.star : Icons.star_border, color: isFav ? Colors.amber : null),
                      onPressed: () => isFav ? app.removeFavorite(dst) : app.addFavorite(dst),
                    ),
                  ),
                );
              },
            ))
          ],
        ),
      ),
    );
  }
}
