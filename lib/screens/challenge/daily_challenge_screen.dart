// lib/screens/challenge/daily_challenge_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../providers/app_state.dart';
import '../../services/daily_service.dart';
import '../../services/libretranslate_service.dart';
import '../../services/progress_service.dart';

class DailyChallengeScreen extends StatefulWidget {
  const DailyChallengeScreen({super.key});

  @override
  State<DailyChallengeScreen> createState() => _DailyChallengeScreenState();
}

class _DailyChallengeScreenState extends State<DailyChallengeScreen> {
  final _service = LibreTranslateService();
  final _tts = FlutterTts();
  final _controller = TextEditingController();

  bool _loading = false;
  String? _promptTarget; // English phrase shown to user
  String? _answerEnglish; // Correct answer in target language
  String? _promptLabel; // Translated label text
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    setState(() => _loading = true);
    final app = context.read<AppState>();
    final lang = app.targetLanguageCode ?? 'es';
    final difficulty = app.difficulty;

    try {
      final data = await DailyService.getToday(generator: () async {
        final pool = [
          'Practice makes perfect',
          'Never stop learning',
          'Knowledge is power',
          'Actions speak louder than words',
          'Believe in yourself'
        ]..shuffle();
        final english = pool.first;
        final translated = await _service.translate(text: english, from: 'en', to: lang);
        return {'prompt': english, 'answer': translated.toLowerCase(), 'lang': lang, 'difficulty': difficulty};
      });

      if (!mounted) return;
      
      // Translate UI text to target language
      final promptText = await _service.translate(
        text: 'Type the translation in',
        from: 'en',
        to: lang,
      );
      
      setState(() {
        _promptTarget = data['prompt']; // English phrase to translate
        _answerEnglish = data['answer']; // Correct answer in target language
        _promptLabel = promptText;
      });
    } catch (e) {
      setState(() {
        _promptTarget = '...';
        _answerEnglish = '';
        _promptLabel = 'Type the translation';
      });
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _speak() async {
    final lang = context.read<AppState>().targetLanguageCode;
    if (lang != null && _promptTarget != null) {
      await _tts.setLanguage(_ttsCode(lang));
      await _tts.setSpeechRate(0.55);
      await _tts.speak(_promptTarget!);
    }
  }

  String _ttsCode(String c) {
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
    }[c] ?? 'en-US';
  }

  String _getLanguageName(String code) {
    return {
      'fr': 'French',
      'es': 'Spanish',
      'de': 'German',
      'it': 'Italian',
      'pt': 'Portuguese',
      'hi': 'Hindi',
      'ja': 'Japanese',
      'ko': 'Korean',
      'zh': 'Chinese',
      'ru': 'Russian',
    }[code] ?? 'the target language';
  }

  Future<void> _submit() async {
    final attempt = _controller.text.trim().toLowerCase();
    if (attempt.isEmpty) return;
    final ok = attempt == (_answerEnglish ?? '');
    
    // Only record if logged in
    if (context.read<AppState>().isLoggedIn) {
      try {
        ProgressService.recordAttempt(correct: ok);
      } catch (e) {
        // Guest mode
      }
    }
    
    // Translate feedback to target language
    final lang = context.read<AppState>().targetLanguageCode ?? 'es';
    try {
      if (ok) {
        final translated = await _service.translate(text: 'Great job!', from: 'en', to: lang);
        setState(() => _feedback = '$translated ✅');
      } else {
        final translated = await _service.translate(text: 'Correct:', from: 'en', to: lang);
        setState(() => _feedback = '$translated ${_answerEnglish ?? ''}');
      }
    } catch (e) {
      setState(() => _feedback = ok ? 'Great job! ✅' : 'Correct: ${_answerEnglish ?? ''}');
    }
  }

  @override
  Widget build(BuildContext context) {
    const green = Color(0xFF58CC02);
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(title: const Text('Daily Challenge'), backgroundColor: Colors.white, elevation: 0),
      body: _loading ? const Center(child: CircularProgressIndicator()) : Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              padding: const EdgeInsets.all(18),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade300),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      _promptTarget ?? '...',
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w700),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up),
                    onPressed: () async {
                      // Speak the English phrase
                      await _tts.setLanguage('en-US');
                      await _tts.setSpeechRate(0.55);
                      await _tts.speak(_promptTarget ?? '');
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _controller,
              decoration: InputDecoration(
                labelText: _promptLabel ?? 'Type the translation',
                hintText: 'Type in ${_getLanguageName(context.read<AppState>().targetLanguageCode ?? 'es')}',
              ),
              onSubmitted: (_) => _submit(),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.check),
              label: const Text('Check Answer'),
              style: ElevatedButton.styleFrom(
                backgroundColor: green,
                shape: const StadiumBorder(),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: _submit,
            ),
            const SizedBox(height: 12),
            if (_feedback != null) Container(padding: const EdgeInsets.all(12), decoration: BoxDecoration(color: _feedback!.contains('Correct') ? Colors.green.withValues(alpha: 0.12) : Colors.red.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(10)), child: Text(_feedback!, textAlign: TextAlign.center)),
          ],
        ),
      ),
    );
  }
}
