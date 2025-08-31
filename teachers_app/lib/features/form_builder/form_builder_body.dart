import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:reorderables/reorderables.dart';
import 'package:minty/features/form_builder/add_question_sheet.dart';
import 'form_builder_provider.dart';
import 'question_model.dart';

class FormBuilderBody extends ConsumerStatefulWidget {
  const FormBuilderBody({super.key});

  @override
  ConsumerState<FormBuilderBody> createState() => _FormBuilderBodyState();
}

class _FormBuilderBodyState extends ConsumerState<FormBuilderBody> {
  final Set<String> _expandedCards = {};

  String _questionTypeLabel(Question q) {
    switch (q.type) {
      case QuestionType.shortAnswer:
        return 'Short Answer';
      case QuestionType.longAnswer:
        return 'Long Answer';
      case QuestionType.multipleChoice:
        return 'Multiple Choice';
      case QuestionType.matchTheFollowing:
        return 'Match the Following';
      case QuestionType.sectionDivider:
        return 'Section Divider';
      case QuestionType.groupedQuestions:
        return 'Grouped Question';
      case QuestionType.fillInTheBlanks:
        return 'Fill in the Blanks';
      case QuestionType.questionWithImage:
        return 'Question with Image';
      case QuestionType.groupedQuestionWithImage:
        return 'Grouped Question with Image';
      case QuestionType.mainDivider:
        return 'Main Divider';
      case QuestionType.table:
        return 'Table';
    }
  }

  void _showEditSheet(BuildContext context, Question question) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => AddQuestionSheet(initialQuestion: question),
    );
  }

  void _toggleExpansion(String questionId) {
    setState(() {
      if (_expandedCards.contains(questionId)) {
        _expandedCards.remove(questionId);
      } else {
        _expandedCards.add(questionId);
      }
    });
  }

  Widget _buildExpandableContent(Question question) {
    switch (question.type) {
      case QuestionType.multipleChoice:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 16),
            const Text(
              'Options:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (question.options != null)
              ...question.options!.asMap().entries.map((entry) {
                final index = entry.key;
                final option = entry.value;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${String.fromCharCode(97 + index)}) $option',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }),
          ],
        );

      case QuestionType.matchTheFollowing:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 16),
            const Text('Pairs:', style: TextStyle(fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            if (question.options != null)
              ...question.options!.map((pair) {
                final parts = pair.split('=');
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${parts[0]} → ${parts.length > 1 ? parts[1] : ''}',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }),
          ],
        );

      case QuestionType.groupedQuestions:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 16),
            const Text(
              'Subquestions:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (question.subQuestions != null)
              ...question.subQuestions!.asMap().entries.map((entry) {
                final subQ = entry.value;
                final subIndex = entry.key;
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 2),
                  child: Text(
                    '${String.fromCharCode(97 + subIndex)}) ${subQ.title}',
                    style: const TextStyle(fontSize: 14),
                  ),
                );
              }),
          ],
        );

      case QuestionType.sectionDivider:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 16),
            if (question.marks != null)
              Text(
                'Total Marks: ${question.marks}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
          ],
        );

      case QuestionType.mainDivider:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 16),
            if (question.marks != null)
              Text(
                'Total Marks: ${question.marks}',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
          ],
        );

      case QuestionType.table:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Divider(height: 16),
            const Text(
              'Table Data:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            if (question.tableData != null)
              Table(
                border: TableBorder.all(color: Colors.white70),
                children: question.tableData!.map((row) {
                  return TableRow(
                    children: row.map((cell) {
                      return Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Text(cell),
                      );
                    }).toList(),
                  );
                }).toList(),
              ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final state = ref.watch(formBuilderProvider);
    final questions = state.questions;
    if (questions.isNotEmpty) {
      return Padding(
        padding: const EdgeInsets.only(bottom: 64, left: 8, right: 8, top: 8),
        child: ReorderableColumn(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          needsLongPressDraggable: true,
          children: [
            for (int index = 0; index < questions.length; index++)
              Padding(
                key: ValueKey(questions[index].id),
                padding: EdgeInsets.only(
                  left:
                      questions[index].type == QuestionType.sectionDivider ||
                          questions[index].type == QuestionType.mainDivider
                      ? 0.0
                      : 8.0,
                ),
                child: Card(
                  elevation: 2,
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    side: BorderSide(
                      color:
                          questions[index].type ==
                                  QuestionType.sectionDivider ||
                              questions[index].type == QuestionType.mainDivider
                          ? colorScheme.primary.withAlpha(140)
                          : colorScheme.secondary.withAlpha(40),
                      width: 1.2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  if (questions[index].type ==
                                      QuestionType.mainDivider)
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "MAIN: ${questions[index].sectionTitle ?? 'Main Title'}",
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleMedium
                                              ?.copyWith(
                                                fontWeight: FontWeight.bold,
                                                color: colorScheme.primary,
                                              ),
                                        ),
                                        if (questions[index].marks != null)
                                          Padding(
                                            padding: const EdgeInsets.only(
                                              top: 2,
                                            ),
                                            child: Text(
                                              '${questions[index].marks} marks',
                                              style: Theme.of(context)
                                                  .textTheme
                                                  .bodySmall
                                                  ?.copyWith(
                                                    color: colorScheme.primary,
                                                    fontWeight: FontWeight.w600,
                                                  ),
                                            ),
                                          ),
                                      ],
                                    )
                                  else ...[
                                    Text(
                                      questions[index].type ==
                                              QuestionType.sectionDivider
                                          ? (questions[index].sectionTitle ??
                                                'Section')
                                          : questions[index].title,
                                      style: Theme.of(context)
                                          .textTheme
                                          .titleMedium
                                          ?.copyWith(
                                            fontWeight: FontWeight.bold,
                                            color:
                                                questions[index].type ==
                                                    QuestionType.sectionDivider
                                                ? colorScheme.primary
                                                : colorScheme.onSurface,
                                          ),
                                    ),
                                    if (questions[index].type ==
                                            QuestionType.sectionDivider &&
                                        questions[index].marks != null)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          '${questions[index].marks} marks',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colorScheme.primary,
                                                fontWeight: FontWeight.w600,
                                              ),
                                        ),
                                      ),
                                    if (questions[index].type !=
                                            QuestionType.sectionDivider &&
                                        questions[index].type !=
                                            QuestionType.mainDivider)
                                      Padding(
                                        padding: const EdgeInsets.only(top: 2),
                                        child: Text(
                                          _questionTypeLabel(questions[index]),
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall
                                              ?.copyWith(
                                                color: colorScheme.secondary,
                                              ),
                                        ),
                                      ),
                                  ],
                                ],
                              ),
                            ),
                            questions[index].type != QuestionType.shortAnswer &&
                                    questions[index].type !=
                                        QuestionType.longAnswer &&
                                    questions[index].type !=
                                        QuestionType.fillInTheBlanks
                                ? IconButton(
                                    icon: Icon(
                                      _expandedCards.contains(
                                            questions[index].id,
                                          )
                                          ? Icons.expand_less
                                          : Icons.expand_more,
                                      color: colorScheme.secondary,
                                    ),
                                    onPressed: () =>
                                        _toggleExpansion(questions[index].id),
                                  )
                                : Container(),
                            IconButton(
                              icon: const Icon(
                                Icons.edit_outlined,
                                color: Colors.grey,
                              ),
                              onPressed: () =>
                                  _showEditSheet(context, questions[index]),
                            ),
                            IconButton(
                              icon: const Icon(
                                Icons.delete_outline,
                                color: Colors.redAccent,
                              ),
                              onPressed: () {
                                ref
                                    .read(formBuilderProvider.notifier)
                                    .removeQuestion(questions[index].id);
                              },
                            ),
                          ],
                        ),
                        if (_expandedCards.contains(questions[index].id))
                          Padding(
                            padding: const EdgeInsets.only(top: 8),
                            child: _buildExpandableContent(questions[index]),
                          ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
          onReorder: (oldIndex, newIndex) {
            ref
                .read(formBuilderProvider.notifier)
                .reorderQuestions(oldIndex, newIndex);
          },
        ),
      );
    } else {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.list_alt, size: 60, color: colorScheme.primary),
            const SizedBox(height: 16),
            Text(
              'No questions added yet. Tap "+" to add.',
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                color: colorScheme.onSurface.withOpacity(0.6),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }
  }
}
