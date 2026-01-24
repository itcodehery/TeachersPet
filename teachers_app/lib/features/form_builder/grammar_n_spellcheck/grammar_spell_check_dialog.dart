import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'text_checker.dart';
import '../form_builder_provider.dart';
import '../question_model.dart';

/// Dialog for displaying and correcting grammar and spelling errors
class GrammarSpellCheckDialog extends ConsumerStatefulWidget {
  const GrammarSpellCheckDialog({super.key});

  @override
  ConsumerState<GrammarSpellCheckDialog> createState() =>
      _GrammarSpellCheckDialogState();
}

class _GrammarSpellCheckDialogState
    extends ConsumerState<GrammarSpellCheckDialog> {
  List<CheckResult> _results = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _runCheck();
  }

  Future<void> _runCheck() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final form = ref.read(formBuilderProvider);
      final texts = <Map<String, dynamic>>[];

      for (int i = 0; i < form.questions.length; i++) {
        final q = form.questions[i];
        texts.add({'text': q.title, 'questionIndex': i, 'fieldType': 'title'});

        if (q.options != null) {
          for (int j = 0; j < q.options!.length; j++) {
            texts.add({
              'text': q.options![j],
              'questionIndex': i,
              'fieldType': 'option_$j',
            });
          }
        }

        if (q.subQuestions != null) {
          for (int j = 0; j < q.subQuestions!.length; j++) {
            texts.add({
              'text': q.subQuestions![j].title,
              'questionIndex': i,
              'fieldType': 'subquestion_$j',
            });
          }
        }
      }

      final results = await TextChecker.checkTexts(texts);
      setState(() {
        _results = results.where((r) => r.hasErrors).toList();
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  int get _totalSpellingErrors =>
      _results.fold(0, (sum, r) => sum + r.spellingErrors.length);
  int get _totalGrammarErrors =>
      _results.fold(0, (sum, r) => sum + r.grammarErrors.length);

  void _correctSpelling() {
    final notifier = ref.read(formBuilderProvider.notifier);
    final form = ref.read(formBuilderProvider);

    for (final result in _results) {
      if (result.spellingErrors.isEmpty) continue;

      final correctedText = TextChecker.correctSpelling(
        result.originalText,
        result.spellingErrors,
      );

      _applyCorrection(notifier, form, result, correctedText);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fixed $_totalSpellingErrors spelling errors')),
    );
  }

  void _correctGrammar() {
    final notifier = ref.read(formBuilderProvider.notifier);
    final form = ref.read(formBuilderProvider);

    for (final result in _results) {
      if (result.grammarErrors.isEmpty) continue;

      final correctedText = TextChecker.correctGrammar(
        result.originalText,
        result.grammarErrors,
      );

      _applyCorrection(notifier, form, result, correctedText);
    }

    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Fixed $_totalGrammarErrors grammar errors')),
    );
  }

  void _applyCorrection(
    FormBuilderNotifier notifier,
    dynamic form,
    CheckResult result,
    String correctedText,
  ) {
    final question = form.questions[result.questionIndex] as Question;

    if (result.fieldType == 'title') {
      notifier.updateQuestion(question.copyWith(title: correctedText));
    } else if (result.fieldType.startsWith('option_')) {
      final optionIndex = int.parse(result.fieldType.split('_')[1]);
      final newOptions = List<String>.from(question.options ?? []);
      if (optionIndex < newOptions.length) {
        newOptions[optionIndex] = correctedText;
        notifier.updateQuestion(question.copyWith(options: newOptions));
      }
    } else if (result.fieldType.startsWith('subquestion_')) {
      final subIndex = int.parse(result.fieldType.split('_')[1]);
      final newSubs = List<Question>.from(question.subQuestions ?? []);
      if (subIndex < newSubs.length) {
        newSubs[subIndex] = newSubs[subIndex].copyWith(title: correctedText);
        notifier.updateQuestion(question.copyWith(subQuestions: newSubs));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        width: MediaQuery.of(context).size.width * 0.9,
        constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary.withAlpha(20),
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.spellcheck,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'Grammar & Spelling Check',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            // Content
            Flexible(child: _buildContent()),
            // Actions
            if (!_isLoading && _error == null && _results.isNotEmpty)
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: const BorderRadius.vertical(
                    bottom: Radius.circular(12),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _totalSpellingErrors > 0
                          ? _correctSpelling
                          : null,
                      icon: const Icon(Icons.abc),
                      label: Text('Correct Spelling ($_totalSpellingErrors)'),
                    ),
                    const SizedBox(width: 8),
                    FilledButton.icon(
                      onPressed: _totalGrammarErrors > 0
                          ? _correctGrammar
                          : null,
                      icon: const Icon(Icons.auto_fix_high),
                      label: Text('Correct Grammar ($_totalGrammarErrors)'),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (_isLoading) {
      return const Padding(
        padding: EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Checking text...'),
          ],
        ),
      );
    }

    if (_error != null) {
      return Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.error_outline,
              size: 48,
              color: Theme.of(context).colorScheme.error,
            ),
            const SizedBox(height: 16),
            Text('Error: $_error'),
            const SizedBox(height: 16),
            TextButton(onPressed: _runCheck, child: const Text('Retry')),
          ],
        ),
      );
    }

    if (_results.isEmpty) {
      return Padding(
        padding: const EdgeInsets.all(48),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.check_circle, size: 64, color: Colors.green[400]),
            const SizedBox(height: 16),
            Text(
              'No errors found!',
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              'Your text looks good.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context).colorScheme.onSurface.withAlpha(150),
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Summary
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.errorContainer.withAlpha(50),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Theme.of(context).colorScheme.error,
                ),
                const SizedBox(width: 8),
                Text(
                  '$_totalSpellingErrors spelling, $_totalGrammarErrors grammar issues found',
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Spelling errors section
          if (_totalSpellingErrors > 0) ...[
            Text(
              'Spelling Errors',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.red[700],
              ),
            ),
            const SizedBox(height: 8),
            ..._results
                .where((r) => r.spellingErrors.isNotEmpty)
                .expand(
                  (r) => r.spellingErrors.map(
                    (e) => _buildErrorCard(e, isSpelling: true),
                  ),
                ),
            const SizedBox(height: 16),
          ],
          // Grammar errors section
          if (_totalGrammarErrors > 0) ...[
            Text(
              'Grammar Errors',
              style: Theme.of(context).textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.blue[700],
              ),
            ),
            const SizedBox(height: 8),
            ..._results
                .where((r) => r.grammarErrors.isNotEmpty)
                .expand(
                  (r) => r.grammarErrors.map(
                    (e) => _buildErrorCard(e, isSpelling: false),
                  ),
                ),
          ],
        ],
      ),
    );
  }

  Widget _buildErrorCard(TextError error, {required bool isSpelling}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              isSpelling ? Icons.abc : Icons.auto_fix_high,
              color: isSpelling ? Colors.red[400] : Colors.blue[400],
              size: 20,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RichText(
                    text: TextSpan(
                      style: Theme.of(context).textTheme.bodyMedium,
                      children: [
                        TextSpan(
                          text: '"${error.errorWord}"',
                          style: TextStyle(
                            color: isSpelling
                                ? Colors.red[700]
                                : Colors.blue[700],
                            decoration: TextDecoration.lineThrough,
                          ),
                        ),
                        const TextSpan(text: ' → '),
                        TextSpan(
                          text: '"${error.suggestion ?? 'no suggestion'}"',
                          style: TextStyle(
                            color: Colors.green[700],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (error.message != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 4),
                      child: Text(
                        error.message!,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: Theme.of(
                            context,
                          ).colorScheme.onSurface.withAlpha(150),
                        ),
                      ),
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
