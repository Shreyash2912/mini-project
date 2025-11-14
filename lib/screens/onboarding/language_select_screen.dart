import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';

class LanguageSelectScreen extends StatelessWidget {
  static const routeName = '/select-language';
  const LanguageSelectScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final langs = const [
      {'code': 'fr', 'name': 'French', 'flag': '🇫🇷'},
      {'code': 'es', 'name': 'Spanish', 'flag': '🇪🇸'},
      {'code': 'de', 'name': 'German', 'flag': '🇩🇪'},
      {'code': 'it', 'name': 'Italian', 'flag': '🇮🇹'},
      {'code': 'pt', 'name': 'Portuguese', 'flag': '🇵🇹'},
      {'code': 'hi', 'name': 'Hindi', 'flag': '🇮🇳'},
      {'code': 'ja', 'name': 'Japanese', 'flag': '🇯🇵'},
      {'code': 'ko', 'name': 'Korean', 'flag': '🇰🇷'},
      {'code': 'zh', 'name': 'Chinese', 'flag': '🇨🇳'},
      {'code': 'ru', 'name': 'Russian', 'flag': '🇷🇺'},
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Choose a language')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          children: langs.map((l) {
            return _LangTile(code: l['code']!, name: l['name']!, flag: l['flag']!);
          }).toList(),
        ),
      ),
    );
  }
}

class _LangTile extends StatelessWidget {
  final String code;
  final String name;
  final String flag;
  const _LangTile({required this.code, required this.name, required this.flag});

  static const _freeLanguages = ['es', 'fr', 'de'];

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isVip = app.isVip;
    final isLocked = !isVip && !_freeLanguages.contains(code);

    return GestureDetector(
      onTap: isLocked
          ? () => Navigator.pushNamed(context, '/premium')
          : () async {
              await app.setLanguage(code);
              Navigator.of(context).pushReplacementNamed('/');
            },
      child: Card(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        elevation: 1,
        color: isLocked ? Colors.grey.shade100 : Colors.white,
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                flag,
                style: TextStyle(
                  fontSize: 32,
                  color: Colors.black.withValues(alpha: isLocked ? 0.5 : 1.0),
                ),
              ),
              const SizedBox(height: 10),
              Text(
                name,
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: isLocked ? Colors.grey : Colors.black,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                code.toUpperCase(),
                style: TextStyle(
                  color: isLocked ? Colors.grey.shade400 : Colors.grey,
                ),
              ),
              if (isLocked) ...[
                const SizedBox(height: 8),
                const Icon(Icons.lock, size: 16, color: Colors.amber),
                const Text(
                  'Premium',
                  style: TextStyle(
                    fontSize: 10,
                    color: Colors.amber,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
