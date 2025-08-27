import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:reorderables/reorderables.dart';
import 'package:teachers_app/features/form_builder/add_questions_dialog.dart';
import 'form_builder_bloc.dart';
import 'form_builder_event.dart';
import 'form_builder_state.dart';
import 'question_model.dart';

class FormBuilderBody extends StatefulWidget {
  const FormBuilderBody({super.key});

  @override
  State<FormBuilderBody> createState() => _FormBuilderBodyState();
}

class _FormBuilderBodyState extends State<FormBuilderBody> {
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
    }
  }

  void _showEditDialog(BuildContext context, Question question) {
    showDialog(
      context: context,
      builder: (dialogContext) {
        return BlocProvider.value(
          value: context.read<FormBuilderBloc>(),
          child: AddQuestionDialog(initialQuestion: question),
        );
      },
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

      default:
        return const SizedBox.shrink();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    return BlocBuilder<FormBuilderBloc, FormBuilderState>(
      builder: (context, state) {
        if (state is FormBuilding && state.questions.isNotEmpty) {
          final questions = state.questions;
          return Padding(
            padding: const EdgeInsets.only(
              bottom: 64,
              left: 8,
              right: 8,
              top: 8,
            ),
            child: ReorderableColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              needsLongPressDraggable: true,
              children: [
                for (int index = 0; index < questions.length; index++)
                  Material(
                    color: colorScheme.surface,
                    elevation: 2,
                    borderRadius: BorderRadius.circular(16),
                    child: Container(
                      key: ValueKey(questions[index].id),
                      margin: const EdgeInsets.only(bottom: 8),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color:
                              questions[index].type ==
                                  QuestionType.sectionDivider
                              ? colorScheme.primary
                              : colorScheme.secondary,
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
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
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
                                                      QuestionType
                                                          .sectionDivider
                                                  ? colorScheme.primary
                                                  : colorScheme.onSurface,
                                            ),
                                      ),
                                      if (questions[index].type ==
                                              QuestionType.sectionDivider &&
                                          questions[index].marks != null)
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
                                      if (questions[index].type !=
                                          QuestionType.sectionDivider)
                                        Padding(
                                          padding: const EdgeInsets.only(
                                            top: 2,
                                          ),
                                          child: Text(
                                            _questionTypeLabel(
                                              questions[index],
                                            ),
                                            style: Theme.of(context)
                                                .textTheme
                                                .bodySmall
                                                ?.copyWith(
                                                  color: colorScheme.secondary,
                                                ),
                                          ),
                                        ),
                                    ],
                                  ),
                                ),
                                IconButton(
                                  icon: Icon(
                                    _expandedCards.contains(questions[index].id)
                                        ? Icons.expand_less
                                        : Icons.expand_more,
                                    color: colorScheme.secondary,
                                  ),
                                  onPressed: () =>
                                      _toggleExpansion(questions[index].id),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.grey,
                                  ),
                                  onPressed: () => _showEditDialog(
                                    context,
                                    questions[index],
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.delete,
                                    color: Colors.redAccent,
                                  ),
                                  onPressed: () {
                                    context.read<FormBuilderBloc>().add(
                                      RemoveField(questions[index].id),
                                    );
                                  },
                                ),
                              ],
                            ),
                            if (_expandedCards.contains(questions[index].id))
                              Padding(
                                padding: const EdgeInsets.only(top: 8),
                                child: _buildExpandableContent(
                                  questions[index],
                                ),
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
              ],
              onReorder: (oldIndex, newIndex) {
                context.read<FormBuilderBloc>().add(
                  ReorderField(oldIndex, newIndex),
                );
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
      },
    );
  }
}
