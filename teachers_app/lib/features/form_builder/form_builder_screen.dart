import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_builder_bloc.dart';
import 'form_builder_event.dart';
import 'form_builder_state.dart';

class FormBuilderScreen extends StatelessWidget {
  const FormBuilderScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FormBuilderBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Form Builder'),
        ),
        body: const FormBuilderBody(),
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            // TODO: Show dialog to add a new question
          },
          child: const Icon(Icons.add),
          tooltip: 'Add Question',
        ),
      ),
    );
  }
}

class FormBuilderBody extends StatelessWidget {
  const FormBuilderBody({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<FormBuilderBloc, FormBuilderState>(
      builder: (context, state) {
        if (state is FormBuilding && (state as FormBuilding).questions.isNotEmpty) {
          final questions = (state as FormBuilding).questions;
          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: questions.length,
            itemBuilder: (context, index) {
              final q = questions[index];
              return Card(
                margin: const EdgeInsets.symmetric(vertical: 8),
                child: ListTile(
                  title: Text(q.title),
                  subtitle: Text(_questionTypeLabel(q)),
                  trailing: IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      context.read<FormBuilderBloc>().add(RemoveField(q.id));
                    },
                  ),
                ),
              );
            },
          );
        } else {
          return Center(
            child: Text(
              'No questions added yet. Tap + to add.',
              style: Theme.of(context).textTheme.bodyLarge,
            ),
          );
        }
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
    default:
      return '';
  }
}
      },
    );
  }
}
