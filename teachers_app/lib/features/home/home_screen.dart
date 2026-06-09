import 'dart:math';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:minty/features/auth/domain/auth_state.dart';
import 'package:minty/tips.dart';
import 'package:minty/features/form_builder/saved_forms_service.dart';
import 'package:minty/core/widgets/banner_ad_widget.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  int _currentTipIndex = 0;
  List<SavedForm> _recentForms = [];
  bool _loadingForms = true;

  @override
  void initState() {
    super.initState();
    _currentTipIndex = Random().nextInt(Tips.tips.length);
    _loadRecentForms();
  }

  Future<void> _loadRecentForms() async {
    final forms = await SavedFormsService.loadForms();
    // Sort by last modified (most recent first) and take top 5
    forms.sort((a, b) => b.lastModified.compareTo(a.lastModified));
    if (mounted) {
      setState(() {
        _recentForms = forms.take(5).toList();
        _loadingForms = false;
      });
    }
  }

  void _cycleTip() {
    setState(() {
      _currentTipIndex = (_currentTipIndex + 1) % Tips.tips.length;
    });
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    return Scaffold(
      appBar: AppBar(
        leading: Padding(
          padding: const EdgeInsets.all(12.0),
          child: GestureDetector(
            onTap: () => context.push("/settings"),
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primaryContainer,
              child: Text(
                (authState.user?['name'] as String?)?.isNotEmpty == true
                    ? authState.user!['name'][0].toUpperCase()
                    : 'U',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.onPrimaryContainer,
                ),
              ),
            ),
          ),
        ),
        title: Row(
          spacing: 5,
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.eco_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
            Text(
              'Minty',
              style: TextStyle(color: Theme.of(context).colorScheme.secondary),
            ),
          ],
        ),
        centerTitle: true,
        actions: [
          IconButton(
            onPressed: () {
              context.push("/settings");
            },
            icon: Icon(
              Icons.settings_outlined,
              color: Theme.of(context).colorScheme.primary,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Build your own",
                  style: TextStyle(
                    color: Theme.of(
                      context,
                    ).colorScheme.onSurface.withAlpha(180),
                  ),
                ),
                Text(
                  "Question Paper",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 20),
            _buildFeatureCard(
              context: context,
              icon: Icons.add,
              title: 'Create New Form',
              description: 'Start building a new form from scratch.',
              onTap: () =>
                  context.push('/form-wizard').then((_) => _loadRecentForms()),
            ),
            const SizedBox(height: 24),
            _buildFeatureCard(
              context: context,
              icon: Icons.list_alt,
              title: 'View Saved Forms',
              description: 'Access and manage your previously created forms.',
              onTap: () =>
                  context.push('/saved-forms').then((_) => _loadRecentForms()),
            ),
            const SizedBox(height: 32),
            // Recent Forms Section
            const SizedBox(height: 32),
            Text(
              'Recent Forms',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 12),
            if (_loadingForms)
              const Center(child: CircularProgressIndicator())
            else if (_recentForms.isEmpty)
              Card(
                margin: EdgeInsets.zero,
                elevation: 0,
                color: Theme.of(
                  context,
                ).colorScheme.surfaceContainerHighest.withAlpha(50),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(
                    color: Theme.of(
                      context,
                    ).colorScheme.outline.withOpacity(0.2),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.feed_outlined,
                          size: 48,
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withOpacity(0.2),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No recent forms',
                          style: TextStyle(
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.5),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Create a new form to get started',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(
                              context,
                            ).colorScheme.onSurface.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              )
            else
              ..._recentForms.map((form) => _buildRecentFormTile(form)),
            const SizedBox(height: 32),
            const BannerAdWidget(),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: TextButton(
          onPressed: _cycleTip,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              'Tip: ${Tips.tips[_currentTipIndex]}',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
                fontStyle: FontStyle.italic,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRecentFormTile(SavedForm form) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(
          Icons.description_outlined,
          color: Theme.of(context).colorScheme.primary,
        ),
        title: Text(
          form.name,
          style: const TextStyle(fontWeight: FontWeight.w500),
        ),
        subtitle: Text(
          'Modified ${DateFormat.yMMMd().format(form.lastModified)}',
          style: TextStyle(
            fontSize: 12,
            color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
          ),
        ),
        trailing: Icon(
          Icons.chevron_right,
          color: Theme.of(context).colorScheme.onSurface.withAlpha(100),
        ),
        onTap: () => context
            .push('/form-builder', extra: form)
            .then((_) => _loadRecentForms()),
      ),
    );
  }

  Widget _buildFeatureCard({
    required BuildContext context,
    required IconData icon,
    required String title,
    required String description,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          colors: [
            Theme.of(context).colorScheme.primary.withOpacity(0.6),
            Theme.of(context).colorScheme.surface,
          ],
          center: AlignmentGeometry.bottomRight,
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadiusGeometry.circular(12),
        border: BoxBorder.all(
          color: Theme.of(context).colorScheme.primary.withAlpha(40),
          width: 1,
        ),
      ),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(icon, size: 24),
              const SizedBox(height: 16),
              Text(
                title,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Text(description, style: Theme.of(context).textTheme.bodyMedium),
            ],
          ),
        ),
      ),
    );
  }
}
