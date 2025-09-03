import 'dart:ui';

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
import 'package:minty/features/form_builder/grammar_n_spellcheck/spellchecker.dart';

class FormBuilderScreen extends ConsumerStatefulWidget {
  final SavedForm? form;

  const FormBuilderScreen({super.key, this.form});

  @override
  ConsumerState<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends ConsumerState<FormBuilderScreen> {
  bool _isSpellChecking = false;
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

  void _showEditNameDialog(BuildContext context, SavedForm form) {
    final nameController = TextEditingController(text: form.name);
    final gradeController = TextEditingController(text: form.grade);
    final subjectController = TextEditingController(text: form.subject);
    final codeController = TextEditingController(text: form.code);
    final marksController = TextEditingController(text: form.marks);
    final durationController = TextEditingController(text: form.duration);
    final dateController = TextEditingController(text: form.date);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit Form Details'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Form Name'),
              ),
              TextField(
                controller: gradeController,
                decoration: const InputDecoration(labelText: 'Grade'),
              ),
              TextField(
                controller: subjectController,
                decoration: const InputDecoration(labelText: 'Subject'),
              ),
              TextField(
                controller: codeController,
                decoration: const InputDecoration(labelText: 'Code'),
              ),
              TextField(
                controller: marksController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Marks'),
              ),
              TextField(
                controller: durationController,
                decoration: const InputDecoration(labelText: 'Duration'),
                // keyboardType: TextInputType.number,
              ),
              TextField(
                controller: dateController,
                decoration: const InputDecoration(labelText: 'Date'),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: DateTime.now(),
                    firstDate: DateTime(2000),
                    lastDate: DateTime(2100),
                  );
                  if (date != null) {
                    dateController.text = DateFormat('yyyy-MM-dd').format(date);
                  }
                },
                readOnly: true,
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => context.pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              if (nameController.text.isNotEmpty) {
                // Here you would need to update your form provider to handle the additional fields
                ref
                    .read(formBuilderProvider.notifier)
                    .updateFormName(
                      nameController.text,
                      grade: gradeController.text.isEmpty
                          ? null
                          : gradeController.text,
                      subject: subjectController.text.isEmpty
                          ? null
                          : subjectController.text,
                      code: codeController.text.isEmpty
                          ? null
                          : codeController.text,
                      marks: marksController.text.isEmpty
                          ? null
                          : marksController.text,
                      duration: durationController.text.isEmpty
                          ? null
                          : durationController.text,
                      date: dateController.text.isEmpty
                          ? null
                          : dateController.text,
                    );
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
        ref.read(documentGeneratorProvider.notifier).generateDocument(form);
      },
      'Preview': (BuildContext context, WidgetRef ref) async {
        if (form.questions.isEmpty) {
          AppSnackbar.showError(context, 'No questions to preview!');
          return;
        }

        AppSnackbar.showInfo(context, 'Generating preview...');
        final pdfBytes = await generateQuestionPaperPdf(form);

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
      'Grammar & Spelling': (BuildContext context, WidgetRef ref) async {
        context.pop();
        setState(() => _isSpellChecking = true);
        await Future.delayed(const Duration(milliseconds: 100));
        final allTexts = <String>[];
        for (final q in form.questions) {
          allTexts.add(q.title);
          if (q.options != null) allTexts.addAll(q.options!);
          if (q.subQuestions != null) {
            for (final subQ in q.subQuestions!) {
              allTexts.add(subQ.title);
            }
          }
        }
        SpellChecker.initSpellCheck();
        final corrected = SpellChecker.correctText(allTexts);
        setState(() => _isSpellChecking = false);
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Spell Check Results'),
            content: SizedBox(
              width: 300,
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (int i = 0; i < allTexts.length; i++)
                      Text(
                        allTexts[i] == corrected[i]
                            ? allTexts[i]
                            : '${allTexts[i]} → ${corrected[i]}',
                        style: TextStyle(
                          color: allTexts[i] == corrected[i]
                              ? Theme.of(context).colorScheme.onSurface
                              : Theme.of(context).colorScheme.primary,
                        ),
                      ),
                  ],
                ),
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        );
      },
    };

    final splitOptionIcons = {
      'Add Node': Icons.add,
      'Preview': Icons.remove_red_eye,
      'Export to PDF': Icons.picture_as_pdf_outlined,
      'Reset Form': Icons.restore,
      'Grammar & Spelling': Icons.book_outlined,
    };

    return Stack(
      children: [
        Scaffold(
          body: SafeArea(
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).brightness == Brightness.dark
                        ? Theme.of(context).colorScheme.primary.withAlpha(20)
                        : Theme.of(
                            context,
                          ).colorScheme.onPrimary.withAlpha(160),
                  ),
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
                                    _showEditNameDialog(context, form),
                                style: TextButton.styleFrom(
                                  backgroundColor: Theme.of(
                                    context,
                                  ).colorScheme.primary.withAlpha(25),
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
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface.withOpacity(0.7),
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
            backgroundColor: Theme.of(context).colorScheme.primary,
            foregroundColor: Theme.of(context).colorScheme.onPrimary,
            onPressed: () => splitOptionList['Add Node']!(context, ref),
            elevation: 0,
            menuRadius: Radius.circular(12),
            popupList: splitOptionList.entries.map((entry) {
              return SplitButtonEntry(
                value: entry.key,
                child: ListTile(
                  dense: true,
                  onTap: () => entry.value(context, ref),
                  textColor: Theme.of(context).colorScheme.onPrimary,
                  iconColor: Theme.of(context).colorScheme.onPrimary,
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
        ),
        if (_isSpellChecking)
          Positioned.fill(
            child: Container(
              color: Theme.of(
                context,
              ).colorScheme.scrim.withAlpha(128), // Dim the background
              child: Center(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    BackdropFilter(
                      filter: ImageFilter.blur(
                        sigmaX: 5,
                        sigmaY: 5,
                      ), // Blur effect
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(
                            color: Theme.of(context).colorScheme.primary,
                          ),
                          const SizedBox(height: 16),
                          Text(
                            'Checking grammar and spelling...',
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  color: Theme.of(
                                    context,
                                  ).colorScheme.onSurface,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }
}
