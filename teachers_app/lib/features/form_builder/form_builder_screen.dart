import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:split_button/split_button.dart';
import 'package:minty/features/form_builder/add_question_sheet.dart';
import 'package:minty/features/form_builder/form_builder_body.dart';
import 'package:minty/features/form_builder/form_builder_provider.dart';
import 'package:minty/features/form_builder/saved_forms_service.dart';
import 'package:minty/features/document_generator/document_generator_bloc.dart';
import 'package:minty/features/document_generator/document_generator_state.dart';
import 'package:minty/features/document_generator/pdf_generator.dart';
import 'package:printing/printing.dart';
import 'package:minty/widgets/app_snackbar.dart';

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
        AppSnackbar.showInfo(context, 'Generating document...');
      } else if (next is DocumentGenerated) {
        AppSnackbar.showSuccess(context, 'Document generated and shared!');
      } else if (next is GenerationFailed) {
        AppSnackbar.showError(
          context,
          'Failed to generate document: ${next.error}',
        );
      }
    });

    final splitOptionList = {
      'Add Node': (BuildContext context, WidgetRef ref) {
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          builder: (context) => const AddQuestionSheet(),
        );
      },
      'Export to PDF': (BuildContext context, WidgetRef ref) {
        if (form.questions.isEmpty) {
          AppSnackbar.showError(context, 'No questions to export!');
          return;
        }
        ref
            .read(documentGeneratorProvider.notifier)
            .generateDocument(form.questions);
      },
      'Preview': (BuildContext context, WidgetRef ref) async {
        if (form.questions.isEmpty) {
          AppSnackbar.showError(context, 'No questions to preview!');
          return;
        }

        AppSnackbar.showInfo(context, 'Generating preview...');
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
      'Reset Form': (BuildContext context, WidgetRef ref) {
        ref.read(formBuilderProvider.notifier).clearQuestions();
      },
      'Grammar & Spelling': (BuildContext context, WidgetRef ref) {
        AppSnackbar.showInfo(context, "Running the Grammar and Spell Check...");
      },
    };

    final splitOptionIcons = {
      'Add Node': Icons.add,
      'Preview': Icons.remove_red_eye,
      'Export to PDF': Icons.picture_as_pdf_outlined,
      'Reset Form': Icons.restore,
      'Grammar & Spelling': Icons.book_outlined,
    };

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Container(
              decoration: BoxDecoration(color: Colors.lime.withAlpha(20)),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8.0,
                  vertical: 8.0,
                ),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back),
                      onPressed: () => context.pop(),
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          TextButton(
                            onPressed: () =>
                                _showEditNameDialog(context, form.name),
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
                                const Icon(Icons.edit_outlined, size: 16),
                              ],
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Last modified: ${DateFormat.yMd().add_jm().format(form.lastModified)}',
                            style: const TextStyle(
                              fontSize: 10,
                              color: Colors.white70,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.save_outlined),
                      onPressed: () {
                        SavedFormsService.addForm(form).then((_) {
                          if (context.mounted) {
                            AppSnackbar.showSuccess(
                              context,
                              'Form "${form.name}" saved!',
                            );
                          }
                        });
                      },
                    ),
                  ],
                ),
              ),
            ),
            const Divider(height: 1),
            const Expanded(child: FormBuilderBody()),
          ],
        ),
      ),
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
