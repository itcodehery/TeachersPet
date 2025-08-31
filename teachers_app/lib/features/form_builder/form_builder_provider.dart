import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minty/features/form_builder/saved_forms_service.dart';
import 'package:uuid/uuid.dart';
import 'question_model.dart';

class FormBuilderNotifier extends StateNotifier<SavedForm> {
  FormBuilderNotifier()
    : super(
        SavedForm(
          id: const Uuid().v4(),
          name: 'Untitled Form',
          createdOn: DateTime.now(),
          lastModified: DateTime.now(),
          questions: [],
        ),
      );

  void loadForm(SavedForm form) {
    state = form;
  }

  void addQuestion(Question question) {
    final newQuestions = [...state.questions, question];
    state = state.copyWith(
      questions: newQuestions,
      lastModified: DateTime.now(),
    );
  }

  void updateQuestion(Question question) {
    final newQuestions = state.questions
        .map((q) => q.id == question.id ? question : q)
        .toList();
    state = state.copyWith(
      questions: newQuestions,
      lastModified: DateTime.now(),
    );
  }

  void clearQuestions() {
    state = state.copyWith(questions: []);
  }

  void removeQuestion(String id) {
    final newQuestions = state.questions.where((q) => q.id != id).toList();
    state = state.copyWith(
      questions: newQuestions,
      lastModified: DateTime.now(),
    );
  }

  void reorderQuestions(int oldIndex, int newIndex) {
    final questions = [...state.questions];
    final item = questions.removeAt(oldIndex);
    questions.insert(newIndex, item);
    state = state.copyWith(questions: questions, lastModified: DateTime.now());
  }

  void updateFormName(String name) {
    state = state.copyWith(name: name, lastModified: DateTime.now());
  }
}

final formBuilderProvider =
    StateNotifierProvider<FormBuilderNotifier, SavedForm>((ref) {
      return FormBuilderNotifier();
    });
