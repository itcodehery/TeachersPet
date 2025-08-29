import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:split_button/split_button.dart';
import 'package:teachers_app/features/form_builder/add_questions_dialog.dart';
import 'package:teachers_app/features/form_builder/form_builder_body.dart';
import 'package:teachers_app/features/form_builder/form_builder_provider.dart';
import 'package:teachers_app/features/form_builder/saved_forms_service.dart';
import 'package:teachers_app/features/document_generator/document_generator_bloc.dart';
import 'package:teachers_app/features/document_generator/document_generator_state.dart';
import 'package:teachers_app/features/document_generator/pdf_generator.dart';
import 'package:printing/printing.dart';

class FormBuilderScreen extends ConsumerStatefulWidget {
  final SavedForm? form;

  const FormBuilderScreen({super.key, this.form});

  @override
  ConsumerState<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends ConsumerState<FormBuilderScreen> {
  @override
  void initState() {
    super.initState();
    if (widget.form != null) {
      // Use a post-frame callback to avoid modifying state during build.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(formBuilderProvider.notifier).loadForm(widget.form!);
      });
    }
  }

  void _showEditNameDialog(BuildContext context, String currentName) {
    final controller = TextEditingController(text: currentName);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Form Name'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Form Name'),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (controller.text.isNotEmpty) {
                ref
                    .read(formBuilderProvider.notifier)
                    .updateFormName(controller.text);
                context.pop();
              }
            },
            child: const Text('Save'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final form = ref.watch(formBuilderProvider);

    ref.listen(documentGeneratorProvider, (previous, next) {
      if (next is GeneratingDocument) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Generating document...')));
      } else if (next is DocumentGenerated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Document generated and shared!')),
        );
      } else if (next is GenerationFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to generate document: ${next.error}')),
        );
      }
    });

    final splitOptionList = {
      'Add Node': (BuildContext context, WidgetRef ref) {
        showDialog(
          context: context,
          builder: (dialogContext) => const AddQuestionDialog(),
        );
      },
      'Preview': (BuildContext context, WidgetRef ref) async {
        if (form.questions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No questions to preview!')),
          );
          return;
        }

        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Generating preview...')));

        final pdfBytes = await generateQuestionPaperPdf(form.questions);

        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => Scaffold(
              appBar: AppBar(title: const Text('PDF Preview')),
              body: PdfPreview(build: (format) => pdfBytes),
            ),
          ),
        );
      },
      'Export to PDF': (BuildContext context, WidgetRef ref) {
        if (form.questions.isEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No questions to export!')),
          );
          return;
        }
        ref
            .read(documentGeneratorProvider.notifier)
            .generateDocument(form.questions);
      },
    };

    final splitOptionIcons = {
      'Add Node': Icons.add,
      'Preview': Icons.remove_red_eye,
      'Export': Icons.download_outlined,
    };

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: Column(
          children: [
            TextButton(
              onPressed: () => _showEditNameDialog(context, form.name),
              style: TextButton.styleFrom(
                backgroundColor: Colors.lime.withAlpha(25),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    form.name,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(
                    Icons.edit_outlined,
                    size: 16,
                    color: Colors.white70,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Last modified: ${DateFormat.yMd().add_jm().format(form.lastModified)}',
              style: const TextStyle(fontSize: 10, color: Colors.white70),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.save_outlined),
            onPressed: () {
              SavedFormsService.addForm(form).then((_) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(const SnackBar(content: Text('Form saved!')));
              });
            },
          ),
        ],
        centerTitle: true,
        elevation: 2,
      ),
      body: const FormBuilderBody(),
      floatingActionButton: SplitButton(
        backgroundColor: Colors.lime,
        foregroundColor: Colors.black,
        onPressed: () => splitOptionList['Add Node']!(context, ref),
        popupList: splitOptionList.entries.map((entry) {
          return SplitButtonEntry(
            value: entry.key,
            child: ListTile(
              onTap: () => entry.value(context, ref),
              textColor: Colors.black,
              iconColor: Colors.black,
              leading: Icon(splitOptionIcons[entry.key]),
              title: Text(entry.key),
            ),
          );
        }).toList(),
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.add),
            const Text('Add Node', style: TextStyle(fontFamily: 'Outfit')),
          ],
        ),
      ),
    );
  }
}
