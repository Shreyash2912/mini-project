import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../challenge/daily_challenge_screen.dart';
import '../practice/question_screen.dart';
import '../progress/progress_screen.dart';
import '../settings/settings_screen.dart';
import '../../services/progress_service.dart';

class HomeTodayScreen extends StatefulWidget {
  static const routeName = '/home-today';
  const HomeTodayScreen({super.key});

  @override
  State<HomeTodayScreen> createState() => _HomeTodayScreenState();
}

class _HomeTodayScreenState extends State<HomeTodayScreen>
    with SingleTickerProviderStateMixin {
  int _streak = 0;
  int _totalXp = 0;
  late final AnimationController _anim;
  late final Animation<double> _fade;
  late final Animation<Offset> _slide;

  @override
  void initState() {
    super.initState();
    _anim = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 600));
    _fade = CurvedAnimation(parent: _anim, curve: Curves.easeOut);
    _slide = Tween(begin: const Offset(0, 0.06), end: Offset.zero)
        .animate(CurvedAnimation(parent: _anim, curve: Curves.easeOut));
    _anim.forward();
    _refreshStats();
  }

  @override
  void dispose() {
    _anim.dispose();
    super.dispose();
  }

  Future<void> _refreshStats() async {
    try {
      _streak = await ProgressService.getStreak();
      _totalXp = await ProgressService.getTotalXp();
    } catch (_) {
      _streak = 0;
      _totalXp = 0;
    }
    if (mounted) setState(() {});
  }

  String _nameFor(String code) {
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
      'ru': 'Russian'
    }[code] ?? 'Language';
  }

  String _greetingFor(String code) {
    return {
      'fr': 'Bonjour!',
      'es': '¡Hola!',
      'de': 'Guten Tag!',
      'it': 'Ciao!',
      'pt': 'Olá!',
      'hi': 'नमस्ते!',
      'ja': 'こんにちは！',
      'ko': '안녕하세요!',
      'zh': '你好！',
      'ru': 'Привет!'
    }[code] ?? 'Hello!';
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();

    if (!app.isReady) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final code = app.targetLanguageCode ?? 'fr';
    final name = app.displayName ?? 'Guest';
    final greeting = _greetingFor(code);

    return Scaffold(
      backgroundColor: const Color(0xFFF4F7FB),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('Language of the Day'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsScreen()),
            ),
          )
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () async {
          await _refreshStats();
        },
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: FadeTransition(
            opacity: _fade,
            child: SlideTransition(
              position: _slide,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      gradient: LinearGradient(
                          colors: [Colors.indigo.shade700, Colors.indigo.shade400]),
                      boxShadow: [
                        BoxShadow(
                            color: Colors.indigo.withValues(alpha: 0.18),
                            blurRadius: 14,
                            offset: const Offset(0, 8))
                      ],
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(_nameFor(code),
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 26,
                                          fontWeight: FontWeight.w800)),
                                  const SizedBox(height: 6),
                                  Text(greeting,
                                      style: const TextStyle(
                                          color: Colors.white70, fontSize: 16)),
                                  const SizedBox(height: 12),
                                  Text('Day ${_dayOfYear()}',
                                      style: const TextStyle(color: Colors.white70)),
                                ],
                              ),
                            ),
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.white,
                              child: Text(
                                (app.targetLanguageCode ?? 'F')
                                    .substring(0, 1)
                                    .toUpperCase(),
                                style: const TextStyle(
                                    color: Colors.indigo,
                                    fontSize: 22,
                                    fontWeight: FontWeight.w700),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 14),
                        Row(
                          children: [
                            Expanded(
                              child: FilledButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const DailyChallengeScreen()),
                                ),
                                style: FilledButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    foregroundColor: Colors.indigo,
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12)),
                                child: const Text('Daily Challenge'),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: OutlinedButton(
                                onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const QuestionScreen()),
                                ),
                                style: OutlinedButton.styleFrom(
                                    padding:
                                        const EdgeInsets.symmetric(vertical: 12),
                                    side: BorderSide(
                                        color: Colors.white.withValues(alpha: 0.9))),
                                child: const Text('Practice',
                                    style: TextStyle(color: Colors.white)),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Expanded(
                          child: _smallStatCard('Streak', '$_streak',
                              Icons.local_fire_department, Colors.orange)),
                      const SizedBox(width: 12),
                      Expanded(
                          child: _smallStatCard(
                              'XP', '$_totalXp', Icons.flash_on, Colors.yellow.shade700)),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200)),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Explore',
                            style:
                                TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
                        const SizedBox(height: 8),
                        Row(children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const ProgressScreen()),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.indigo.shade50,
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Column(children: [
                                  Icon(Icons.insights_outlined,
                                      size: 28, color: Colors.indigo),
                                  SizedBox(height: 6),
                                  Text('Progress',
                                      style: TextStyle(fontWeight: FontWeight.w700)),
                                  Text('View stats')
                                ]),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => Navigator.of(context).push(
                                MaterialPageRoute(
                                    builder: (_) => const QuestionScreen()),
                              ),
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                    color: Colors.green.shade50,
                                    borderRadius: BorderRadius.circular(10)),
                                child: const Column(children: [
                                  Icon(Icons.school, size: 28, color: Colors.green),
                                  SizedBox(height: 6),
                                  Text('Practice',
                                      style: TextStyle(fontWeight: FontWeight.w700)),
                                  Text('Daily practice')
                                ]),
                              ),
                            ),
                          ),
                        ]),
                        const SizedBox(height: 12),
                        Text(
                            'Tip: Questions are shown in the target language; choose the English option.',
                            style: TextStyle(color: Colors.grey.shade700)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 18),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: Colors.grey.shade200)),
                    child: Row(
                      children: [
                        CircleAvatar(
                            radius: 24,
                            child: Text(name.isNotEmpty
                                ? name[0].toUpperCase()
                                : 'G')),
                        const SizedBox(width: 12),
                        Expanded(
                            child: Text(name,
                                style: const TextStyle(fontWeight: FontWeight.w700))),
                        TextButton.icon(
                            onPressed: () => Navigator.of(context).push(
                                  MaterialPageRoute(
                                      builder: (_) => const SettingsScreen()),
                                ),
                            icon: const Icon(Icons.settings_outlined),
                            label: const Text('Settings')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _smallStatCard(String title, String value, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200)),
      child: Row(
        children: [
          CircleAvatar(
              backgroundColor: color.withValues(alpha: 0.15),
              child: Icon(icon, color: color)),
          const SizedBox(width: 12),
          Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: const TextStyle(fontWeight: FontWeight.w600)),
                Text(value,
                    style: const TextStyle(
                        fontWeight: FontWeight.bold, fontSize: 16))
              ])
        ],
      ),
    );
  }

  int _dayOfYear() {
    final now = DateTime.now();
    final start = DateTime(now.year, 1, 1);
    return now.difference(start).inDays + 1;
  }
}
