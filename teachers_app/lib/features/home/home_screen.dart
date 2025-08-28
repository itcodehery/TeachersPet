import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('TeachersPet')),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Build your own",
                  style: TextStyle(color: Color.fromARGB(170, 255, 255, 255)),
                ),
                Text(
                  "Question Paper",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                ),
              ],
            ),
            SizedBox(height: 10),
            _buildFeatureCard(
              context: context,
              icon: Icons.add,
              title: 'Create New Form',
              description: 'Start building a new form from scratch.',
              onTap: () => context.push('/form-builder'),
            ),
            const SizedBox(height: 24),
            _buildFeatureCard(
              context: context,
              icon: Icons.list_alt,
              title: 'View Saved Forms',
              description: 'Access and manage your previously created forms.',
              onTap: () => context.push('/saved-forms'),
            ),
          ],
        ),
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
          colors: [Colors.lightGreen.withAlpha(150), Colors.black],
          center: AlignmentGeometry.bottomRight,
          stops: [0.0, 1.0],
        ),
        borderRadius: BorderRadiusGeometry.circular(12),
        border: BoxBorder.all(color: Colors.lime.withAlpha(40), width: 1),
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
