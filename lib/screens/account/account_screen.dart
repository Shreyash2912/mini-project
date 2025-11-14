import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/app_state.dart';
import '../onboarding/language_select_screen.dart';
import '../auth/login_signup_screen.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({super.key});

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  final _nameController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _editName(BuildContext context, AppState app) async {
    _nameController.text = app.displayName ?? '';
    final newName = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Name'),
        content: TextField(
          controller: _nameController,
          decoration: const InputDecoration(labelText: 'Name'),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, _nameController.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newName != null && newName.isNotEmpty) {
      await app.updateProfileName(newName);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Name updated successfully')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final avatarLetter = (app.displayName ?? '').isEmpty
        ? '?'
        : app.displayName![0].toUpperCase();
    final languageName = codeToName(app.targetLanguageCode);

    return Scaffold(
      appBar: AppBar(title: const Text('Account')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            CircleAvatar(radius: 36, child: Text(avatarLetter)),
            const SizedBox(height: 12),
            Center(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    app.displayName == null || app.displayName!.trim().isEmpty
                        ? 'Guest'
                        : app.displayName!,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  if (app.isLoggedIn) ...[
                    const SizedBox(width: 8),
                    IconButton(
                      icon: const Icon(Icons.edit, size: 20),
                      onPressed: () => _editName(context, app),
                      tooltip: 'Edit name',
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 24),
            if (app.isVip)
              Card(
                color: Colors.amber.withValues(alpha: 0.1),
                child: const ListTile(
                  leading: Icon(Icons.star, color: Colors.amber),
                  title: Text('VIP Member'),
                  subtitle: Text('You have access to all features'),
                ),
              ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.translate_outlined),
                title: const Text('Target language'),
                subtitle: Text(languageName ?? 'Not set'),
                trailing: TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const LanguageSelectScreen()),
                  ),
                  child: const Text('Change'),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Card(
              child: ListTile(
                leading: const Icon(Icons.tune_outlined),
                title: const Text('Difficulty'),
                subtitle: Text(app.difficulty),
              ),
            ),
            const Spacer(),
            if (app.isLoggedIn)
              FilledButton.icon(
                onPressed: () => context.read<AppState>().logout(),
                icon: const Icon(Icons.logout),
                label: const Text('Log out'),
              )
            else
              FilledButton.icon(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute(builder: (_) => const LoginSignupScreen()),
                ),
                icon: const Icon(Icons.login),
                label: const Text('Login / Sign up'),
              ),
          ],
        ),
      ),
    );
  }

  String? codeToName(String? code) {
    if (code == null) return null;
    const map = {
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
    };
    return map[code];
  }
}
