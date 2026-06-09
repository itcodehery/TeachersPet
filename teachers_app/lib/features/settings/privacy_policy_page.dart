import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Privacy Policy'),
        foregroundColor: Theme.of(context).colorScheme.primary,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Hi, I\'m Hari!',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'I\'m a solo developer passionate about low-level programming, system design, and crafting great user experiences. I built this app to help teachers, and I want you to know that I value your privacy just as much as you do. I\'m not here to sell your data; I\'m just here to make your life a little easier.',
            style: TextStyle(fontSize: 16, height: 1.5),
          ),
          const SizedBox(height: 24),
          const Text(
            'TL;DR',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          const Text(
            'I value your privacy. I do not sell your personal data. I only collect the information necessary to provide and improve my services. Your data is stored securely.',
            style: TextStyle(fontSize: 16),
          ),
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 24),
          const Text(
            'Detailed Privacy Policy',
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildSection(
            '1. Information I Collect',
            'When you register and use the app, I collect your name, email address, and any forms you create or save within the app. Authentication is handled securely.',
          ),
          _buildSection(
            '2. How I Use Your Information',
            'Your information is used to personalize your experience, provide core functionality like saving and managing forms, and to communicate with you regarding your account or app updates.',
          ),
          _buildSection(
            '3. Data Storage and Security',
            'I implement security measures to maintain the safety of your personal information. Your account details and forms are stored securely through my backend services, and I follow industry-standard practices to protect your data.',
          ),
          _buildSection(
            '4. Third-Party Services',
            'I may use third-party services for analytics or crash reporting to improve the app. These services have their own privacy policies addressing how they use such information.',
          ),
          _buildSection(
            '5. Changes to This Policy',
            'I may update this Privacy Policy from time to time. I will notify you of any changes by posting the new Privacy Policy on this page.',
          ),
          _buildSection(
            '6. Contact Me',
            'If you have any questions about this Privacy Policy, please contact me through my official support channels. You can also reach out to me directly!',
          ),
          const SizedBox(height: 8),
          Center(
            child: FilledButton.icon(
              onPressed: () {
                Clipboard.setData(const ClipboardData(text: '+91 9008015121'));
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Phone number copied to clipboard!'),
                      behavior: SnackBarBehavior.floating,
                    ),
                  );
                }
              },
              icon: const Icon(Icons.copy),
              label: const Text('Copy My Number (+91 9008015121)'),
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.primaryContainer,
                foregroundColor: Theme.of(
                  context,
                ).colorScheme.onPrimaryContainer,
              ),
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(content, style: const TextStyle(fontSize: 14, height: 1.5)),
        ],
      ),
    );
  }
}
