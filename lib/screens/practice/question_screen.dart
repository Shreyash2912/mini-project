import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '../../providers/app_state.dart';
import '../../services/libretranslate_service.dart';
import '../../services/progress_service.dart';

class QuestionScreen extends StatefulWidget {
  const QuestionScreen({super.key});

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _service = LibreTranslateService();
  final _tts = FlutterTts();
  bool _loading = false;

  String? _promptTarget;
  String? _answerEnglish;
  List<String> _options = [];
  List<String> _optionsEnglish = [];
  int? _selected;
  String? _feedback;

  @override
  void initState() {
    super.initState();
    _generateQuestion();
  }

  Future<void> _generateQuestion() async {
    setState(() {
      _loading = true;
      _feedback = null;
      _selected = null;
      _options = [];
    });

    final app = context.read<AppState>();
    final lang = app.targetLanguageCode ?? "es";

    final pool = [
      "Good morning",
      "I want a coffee",
      "Where is the station?",
      "Thank you very much",
      "Please help me",
      "I love learning languages",
      "What is your name?",
      "How much does this cost?",
      "Can you speak slowly?"
    ];

    pool.shuffle();
    final english = pool.first;
    _answerEnglish = english.toLowerCase();

    try {
      final translated = await _service.translate(text: english, from: "en", to: lang);
      final questionPrompt = await _service.translate(
        text: "What is the English translation of",
        from: "en",
        to: lang,
      );

      final wrong = pool.where((e) => e != english).take(3).toList();
      final allEnglish = [english, ...wrong]..shuffle();

      setState(() {
        _promptTarget = "$questionPrompt \"$translated\"?";
        _options = allEnglish;
        _optionsEnglish = allEnglish;
      });
    } catch (e) {
      setState(() {
        _promptTarget = english;
        _options = [english];
        _optionsEnglish = [english];
      });
    }

    setState(() => _loading = false);
  }

  Future<void> _speakTarget() async {
    final app = context.read<AppState>();
    final code = app.targetLanguageCode ?? "es";
    await _tts.setLanguage(_ttsCode(code));
    await _tts.setSpeechRate(0.55);
    await _tts.speak(_promptTarget ?? "");
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
    }[code] ?? "en-US";
  }

  void _submit() {
    if (_selected == null) return;

    final chosenEnglish = _optionsEnglish[_selected!].toLowerCase();
    final ok = chosenEnglish == _answerEnglish;
    
    if (context.read<AppState>().isLoggedIn) {
      try {
        ProgressService.recordAttempt(correct: ok);
      } catch (e) {
        // Guest mode
      }
    }

    final app = context.read<AppState>();
    final lang = app.targetLanguageCode ?? "es";
    
    if (ok) {
      _service.translate(text: "Correct!", from: "en", to: lang).then((translated) {
        if (mounted) {
          setState(() => _feedback = "$translated 🎉");
        }
      }).catchError((_) {
        if (mounted) {
          setState(() => _feedback = "Correct! 🎉");
        }
      });
    } else {
      _service.translate(text: "Wrong! Correct answer:", from: "en", to: lang).then((translated) {
        if (mounted) {
          setState(() => _feedback = "$translated $_answerEnglish");
        }
      }).catchError((_) {
        if (mounted) {
          setState(() => _feedback = "Wrong! Correct: $_answerEnglish");
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        title: const Text("Practice"),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
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
                      _promptTarget ?? "...",
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.volume_up, size: 28),
                    onPressed: _speakTarget,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...List.generate(_options.length, (i) {
              final selected = _selected == i;
              final correct =
                  _feedback != null && _options[i].toLowerCase() == _answerEnglish;

              return GestureDetector(
                onTap: _feedback == null
                    ? () => setState(() => _selected = i)
                    : null,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 250),
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: _feedback == null
                        ? (selected ? Colors.blue.shade50 : Colors.white)
                        : (correct ? Colors.green.shade100 : (selected ? Colors.red.shade100 : Colors.white)),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.grey.shade300),
                  ),
                  child: Text(
                    _options[i],
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            }),
            const SizedBox(height: 20),
            if (_feedback != null)
              Text(
                _feedback!,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: _feedback!.contains("Correct")
                      ? Colors.green
                      : Colors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const Spacer(),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: _submit,
                    child: const Text("Submit"),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: OutlinedButton(
                    onPressed: _generateQuestion,
                    child: const Text("Next"),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
