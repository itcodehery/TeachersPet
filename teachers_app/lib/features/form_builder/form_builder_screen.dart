import 'dart:typed_data';
import '../document_generator/document_generator_bloc.dart';
import '../document_generator/document_generator_event.dart';
import '../document_generator/document_generator_state.dart';
import 'package:reorderables/reorderables.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'form_builder_bloc.dart';
import 'form_builder_event.dart';
import 'form_builder_state.dart';
import 'question_model.dart';
import 'package:docx_template/docx_template.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'add_questions_dialog.dart';

// For grouped questions

class FormBuilderScreen extends StatelessWidget {
  const FormBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FormBuilderBloc(),
      child: Builder(
        builder: (blocContext) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => blocContext.pop(),
            ),
            title: const Text('Form Builder'),
            centerTitle: true,
            backgroundColor: Colors.deepPurple,
            elevation: 2,
            actions: [
              BlocProvider<DocumentGeneratorBloc>(
                create: (_) => DocumentGeneratorBloc(),
                child: Builder(
                  builder: (docGenContext) => IconButton(
                    icon: const Icon(Icons.save_as_outlined),
                    onPressed: () async {
                      final bloc = BlocProvider.of<FormBuilderBloc>(
                        blocContext,
                      );
                      final state = bloc.state;
                      if (state is! FormBuilding || state.questions.isEmpty) {
                        ScaffoldMessenger.of(blocContext).showSnackBar(
                          const SnackBar(
                            content: Text('No questions to export!'),
                          ),
                        );
                        return;
                      }

                      // Dispatch document generation event
                      final docGenBloc = BlocProvider.of<DocumentGeneratorBloc>(
                        docGenContext,
                      );
                      docGenBloc.add(GenerateDocument(state.questions));

                      // Listen for result
                      showDialog(
                        context: blocContext,
                        barrierDismissible: false,
                        builder: (ctx) {
                          return BlocListener<
                            DocumentGeneratorBloc,
                            DocumentGeneratorState
                          >(
                            bloc: docGenBloc,
                            listener: (context, docState) {
                              if (docState is DocumentGenerated) {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(blocContext).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Exported to ${docState.filePath}',
                                    ),
                                  ),
                                );
                              } else if (docState is GenerationFailed) {
                                Navigator.of(ctx).pop();
                                ScaffoldMessenger.of(blocContext).showSnackBar(
                                  SnackBar(
                                    content: Text(
                                      'Export failed: ${docState.error}',
                                    ),
                                  ),
                                );
                              }
                            },
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ),
            ],
          ),
          body: const FormBuilderBody(),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () {
              showDialog(
                context: blocContext,
                builder: (context) => BlocProvider.value(
                  value: blocContext.read<FormBuilderBloc>(),
                  child: const AddQuestionDialog(),
                ),
              );
            },
            icon: const Icon(Icons.add),
            label: const Text('Add Question'),
            backgroundColor: Colors.deepPurple,
          ),
          backgroundColor: Colors.grey[100],
        ),
      ),
    );
  }
}

class FormBuilderBody extends StatelessWidget {
  const FormBuilderBody({super.key});

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
      builder: (dialogContext) => BlocProvider.value(
        value: context.read<FormBuilderBloc>(),
        child: AddQuestionDialog(initialQuestion: question),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormBuilderBloc, FormBuilderState>(
      builder: (context, state) {
        if (state is FormBuilding && state.questions.isNotEmpty) {
          final questions = state.questions;
          return Padding(
            padding: const EdgeInsets.all(16),
            child: ReorderableColumn(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              needsLongPressDraggable: true,
              children: [
                for (int index = 0; index < questions.length; index++)
                  if (questions[index].type == QuestionType.sectionDivider)
                    Container(
                      key: ValueKey(questions[index].id),
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 18,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.deepPurple[50],
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.deepPurple,
                          width: 1.5,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              questions[index].sectionTitle ?? 'Section',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 20,
                                color: Colors.deepPurple,
                              ),
                            ),
                          ),
                          if (questions[index].marks != null)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.deepPurple,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Text(
                                '${questions[index].marks} marks',
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          IconButton(
                            icon: const Icon(
                              Icons.edit,
                              color: Colors.blueAccent,
                            ),
                            onPressed: () =>
                                _showEditDialog(context, questions[index]),
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
                    )
                  else if (questions[index].type ==
                      QuestionType.groupedQuestions)
                    Card(
                      key: ValueKey(questions[index].id),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    questions[index].title,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                                IconButton(
                                  icon: const Icon(
                                    Icons.edit,
                                    color: Colors.blueAccent,
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
                            const SizedBox(height: 8),
                            ...?questions[index].subQuestions?.asMap().entries.map((
                              entry,
                            ) {
                              final subQ = entry.value;
                              final subIndex = entry.key;
                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 4,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      '${String.fromCharCode(97 + subIndex)}) ',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Expanded(
                                      child: Text(
                                        subQ.title,
                                        style: const TextStyle(fontSize: 16),
                                      ),
                                    ),
                                  ],
                                ),
                              );
                            }),
                          ],
                        ),
                      ),
                    )
                  else
                    Card(
                      key: ValueKey(questions[index].id),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 3,
                      child: ListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                        title: Text(
                          questions[index].title,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                        subtitle: Text(
                          _questionTypeLabel(questions[index]),
                          style: const TextStyle(
                            fontSize: 15,
                            color: Colors.deepPurple,
                          ),
                        ),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: Colors.blueAccent,
                              ),
                              onPressed: () =>
                                  _showEditDialog(context, questions[index]),
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
                Icon(Icons.list_alt, size: 60, color: Colors.deepPurple),
                const SizedBox(height: 16),
                Text(
                  'No questions added yet. Tap "+" to add.',
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(color: Colors.black54),
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
