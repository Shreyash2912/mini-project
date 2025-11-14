import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../onboarding/language_select_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final name = app.displayName ?? 'Guest';
    final code = app.targetLanguageCode ?? 'fr';

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profile'),
        backgroundColor: Colors.white,
        elevation: 0,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 30,
                    child: Text(name.isNotEmpty ? name[0].toUpperCase() : 'G'),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          name,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Joined: ${DateTime.now().year}',
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  SwitchListTile(
                    value: false,
                    onChanged: (v) {},
                    title: const Text('Dark mode'),
                  ),
                  ListTile(
                    title: const Text('Target language'),
                    subtitle: Text(code.toUpperCase()),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () => Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const LanguageSelectScreen(),
                      ),
                    ),
                  ),
                  ListTile(
                    title: const Text('Difficulty'),
                    subtitle: Text(app.difficulty),
                    onTap: () {
                      showModalBottomSheet(
                        context: context,
                        builder: (c) => Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListTile(
                              title: const Text('Beginner'),
                              onTap: () {
                                app.setDifficulty('beginner');
                                Navigator.pop(c);
                              },
                            ),
                            ListTile(
                              title: const Text('Intermediate'),
                              onTap: () {
                                app.setDifficulty('intermediate');
                                Navigator.pop(c);
                              },
                            ),
                            ListTile(
                              title: const Text('Advanced'),
                              onTap: () {
                                app.setDifficulty('advanced');
                                Navigator.pop(c);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
