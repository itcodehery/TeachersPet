import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:minty/features/form_builder/saved_forms_service.dart';
import 'package:minty/routes/app_routes.dart';

class SavedFormsScreen extends ConsumerStatefulWidget {
  const SavedFormsScreen({super.key});

  @override
  ConsumerState<SavedFormsScreen> createState() => _SavedFormsScreenState();
}

class _SavedFormsScreenState extends ConsumerState<SavedFormsScreen> {
  late Future<List<SavedForm>> _formsFuture;

  @override
  void initState() {
    super.initState();
    _formsFuture = SavedFormsService.loadForms();
  }

  void _deleteForm(String id) async {
    await SavedFormsService.deleteForm(id);
    setState(() {
      _formsFuture = SavedFormsService.loadForms();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Saved Forms')),
      body: FutureBuilder<List<SavedForm>>(
        future: _formsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          final forms = snapshot.data;
          if (forms == null || forms.isEmpty) {
            return const Center(child: Text('No saved forms yet.'));
          }
          return ListView.builder(
            padding: const EdgeInsets.all(8),
            itemCount: forms.length,
            itemBuilder: (context, index) {
              final form = forms[index];
              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  side: BorderSide(
                    color: Theme.of(context).brightness == Brightness.light
                        ? Theme.of(context).primaryColor.withAlpha(40)
                        : Theme.of(context).colorScheme.primary.withAlpha(100),
                  ),
                  borderRadius: BorderRadiusGeometry.all(Radius.circular(24)),
                ),
                color: Theme.of(context).cardColor,
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(16),
                  title: Row(
                    children: [
                      Icon(Icons.file_present),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          form.name,
                          overflow: TextOverflow.ellipsis,
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                      ),
                    ],
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Last modified: ${DateFormat.yMd().add_jm().format(form.lastModified)}',
                    ),
                  ),
                  onTap: () => context.push(Routes.formBuilder, extra: form),
                  trailing: IconButton(
                    icon: Icon(
                      Icons.delete,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    onPressed: () => _deleteForm(form.id),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
