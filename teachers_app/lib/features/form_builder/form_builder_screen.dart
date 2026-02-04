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
import 'package:minty/features/form_builder/header_selector_sheet.dart';
import 'package:minty/features/form_builder/header_template_service.dart';
import 'package:minty/features/form_builder/form_details_dialog.dart';
import 'package:printing/printing.dart';
import 'package:minty/widgets/app_snackbar.dart';
import 'package:minty/features/form_builder/grammar_n_spellcheck/grammar_spell_check_dialog.dart';
import 'dart:async';
import 'package:minty/core/accessibility/accessibility_settings.dart';

class FormBuilderScreen extends ConsumerStatefulWidget {
  final SavedForm? form;

  const FormBuilderScreen({super.key, this.form});

  @override
  ConsumerState<FormBuilderScreen> createState() => _FormBuilderScreenState();
}

class _FormBuilderScreenState extends ConsumerState<FormBuilderScreen> {
  bool _isSpellChecking = false;
  Timer? _autoSaveTimer;

  @override
  void initState() {
    super.initState();
    if (widget.form != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(formBuilderProvider.notifier).loadForm(widget.form!);
      });
    } else {
      // If no form is passed, reset the state to start fresh
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(formBuilderProvider.notifier).reset();
      });
    }
    _setupAutoSave();
  }

  @override
  void dispose() {
    _autoSaveTimer?.cancel();
    super.dispose();
  }

  void _setupAutoSave() {
    final settings = ref.read(accessibilityProvider);
    if (settings.autoSaveInterval > 0) {
      _autoSaveTimer?.cancel();
      _autoSaveTimer = Timer.periodic(
        Duration(seconds: settings.autoSaveInterval),
        (_) => _autoSave(),
      );
    }
  }

  Future<void> _autoSave() async {
    final form = ref.read(formBuilderProvider);
    if (form.questions.isNotEmpty) {
      final savedForm = SavedForm(
        id: widget.form?.id ?? DateTime.now().toIso8601String(),
        name: form.name,
        createdOn: widget.form?.createdOn ?? DateTime.now(),
        lastModified: DateTime.now(),
        questions: form.questions,
        selectedHeaderId: form.selectedHeaderId,
        instituteName: form.instituteName,
        examTitle: form.examTitle,
        subtitle: form.subtitle,
        date: form.date,
        duration: form.duration,
        maxMarks: form.maxMarks,
        subject: form.subject,
        className: form.className,
        customFieldValues: form.customFieldValues,
      );

      if (widget.form != null) {
        // Update existing form
        await SavedFormsService.deleteForm(widget.form!.id);
        await SavedFormsService.addForm(savedForm);
      } else {
        // For new forms, only auto-save if we have an ID (which means it was saved at least once)
        // or just quietly save it as a new draft?
        // Let's adopt the behavior: if it's a new form, we don't auto-save until manual save to avoid clutter
        // UNLESS we check if the user has already saved it once.
        // For simplicity, let's only auto-save if we are editing an existing form (widget.form != null)
        // OR if the user has manually saved it at least once (we'd need to track that).
        // A safer bet is: only auto-save if widget.form != null to avoid creating junk files.
        // BUT if users want auto-save on new forms, we should probably support it.
        // Let's stick to updating existing forms for now to be safe.
      }

      // Actually, to make auto-save useful for new forms, we need to handle the case where it hasn't been saved yet.
      // But creating a new file every 30s is bad if we don't have an ID.
      // Let's just update existing forms for safety in this iteration.
      if (widget.form != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Auto-saving...'),
            duration: Duration(seconds: 1),
          ),
        );
      }
    }
  }

  void _showFormDetailsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => const FormDetailsDialog(),
    );
  }

  void _showFontSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        final currentFont = ref.watch(formBuilderProvider).fontFamily;
        return AlertDialog(
          title: const Text('Select Font'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildFontRadio(
                context,
                title: 'Noto Sans',
                subtitle: 'Modern Sans-Serif (Multi-language)',
                value: 'NotoSans',
                groupValue: currentFont,
              ),
              _buildFontRadio(
                context,
                title: 'Times New Roman',
                subtitle: 'Classic Serif (English only)',
                value: 'TimesNewRoman',
                groupValue: currentFont,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
          ],
        );
      },
    );
  }

  Widget _buildFontRadio(
    BuildContext context, {
    required String title,
    required String subtitle,
    required String value,
    required String groupValue,
  }) {
    return RadioListTile<String>(
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
      value: value,
      groupValue: groupValue,
      onChanged: (newValue) {
        if (newValue != null) {
          ref.read(formBuilderProvider.notifier).updateFontFamily(newValue);
          Navigator.pop(context);
        }
      },
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
          useSafeArea: true,
          builder: (context) => const AddQuestionSheet(),
        );
      },
      'Export to PDF': (BuildContext context, WidgetRef ref) async {
        if (form.questions.isEmpty) {
          AppSnackbar.showError(context, 'No questions to export!');
          return;
        }
        final headerId = form.selectedHeaderId ?? 'prebuilt_simple';
        final header = await HeaderTemplateService.getHeaderById(headerId);
        ref
            .read(documentGeneratorProvider.notifier)
            .generateDocument(
              form.questions,
              headerTemplate: header,
              instituteName: form.instituteName,
              examTitle: form.examTitle,
              subtitle: form.subtitle,
              date: form.date,
              duration: form.duration,
              maxMarks: form.maxMarks,
              subject: form.subject,
              className: form.className,
              fontFamily: form.fontFamily,
              customFieldValues: form.customFieldValues,
            );
      },
      'Preview': (BuildContext context, WidgetRef ref) async {
        if (form.questions.isEmpty) {
          AppSnackbar.showError(context, 'No questions to preview!');
          return;
        }

        AppSnackbar.showInfo(context, 'Generating preview...');
        final headerId = form.selectedHeaderId ?? 'prebuilt_simple';
        final header = await HeaderTemplateService.getHeaderById(headerId);
        final pdfBytes = await generateQuestionPaperPdf(
          form.questions,
          headerTemplate: header,
          instituteName: form.instituteName,
          examTitle: form.examTitle,
          subtitle: form.subtitle,
          date: form.date,
          duration: form.duration,
          maxMarks: form.maxMarks,
          subject: form.subject,
          className: form.className,
          fontFamily: form.fontFamily,
          customFieldValues: form.customFieldValues,
        );

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
        context.pop(); // Close split button menu
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('Reset Form?'),
            content: const Text(
              'Are you sure you want to reset this form? All questions will be removed.',
            ),
            actions: [
              TextButton(
                onPressed: () => context.pop(),
                child: const Text('Cancel'),
              ),
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.error,
                ),
                onPressed: () {
                  ref.read(formBuilderProvider.notifier).clearQuestions();
                  context.pop();
                  AppSnackbar.showSuccess(context, 'Form reset successfully');
                },
                child: const Text('Reset'),
              ),
            ],
          ),
        );
      },
      'Choose Header': (BuildContext context, WidgetRef ref) {
        context.pop();
        showModalBottomSheet(
          context: context,
          isScrollControlled: true,
          useSafeArea: true,
          builder: (context) => const HeaderSelectorSheet(),
        );
      },
      'Grammar & Spelling': (BuildContext context, WidgetRef ref) async {
        context.pop();
        showDialog(
          context: context,
          builder: (context) => const GrammarSpellCheckDialog(),
        );
      },
      'Change Font': (BuildContext context, WidgetRef ref) {
        context.pop();
        _showFontSelectionDialog(context);
      },
    };

    final splitOptionIcons = {
      'Add Node': Icons.add,
      'Preview': Icons.remove_red_eye,
      'Export to PDF': Icons.picture_as_pdf_outlined,
      'Reset Form': Icons.restore,
      'Choose Header': Icons.description_outlined,
      'Grammar & Spelling': Icons.book_outlined,
      'Change Font': Icons.font_download_outlined,
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
                                    _showFormDetailsDialog(context),
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
                            SavedFormsService.addForm(form)
                                .then((_) {
                                  if (context.mounted) {
                                    AppSnackbar.showSuccess(
                                      context,
                                      'Form "${form.name}" saved!',
                                    );
                                  }
                                })
                                .catchError((e) {
                                  if (context.mounted) {
                                    AppSnackbar.showError(
                                      context,
                                      'Failed to save form: $e',
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
