import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_builder_event.dart';
import 'form_builder_state.dart';
import 'question_model.dart';
import 'saved_forms_service.dart';
import 'package:uuid/uuid.dart';

class FormBuilderBloc extends Bloc<FormBuilderEvent, FormBuilderState> {
  String? _formId;
  final String _formTitle = 'Question Paper';

  FormBuilderBloc() : super(const FormBuilding()) {
    on<AddField>((event, emit) async {
      final currentState = state;
      if (currentState is FormBuilding) {
        final updatedQuestions = List<Question>.from(currentState.questions)
          ..add(event.question);
        emit(FormBuilding(questions: updatedQuestions));

        // Save to local JSON
        await _saveForm(updatedQuestions);
      }
    });

    on<UpdateField>((event, emit) async {
      final currentState = state;
      if (currentState is FormBuilding) {
        final updatedQuestions = currentState.questions.map((q) {
          if (q.id == event.question.id) {
            return event.question;
          }
          return q;
        }).toList();
        emit(FormBuilding(questions: updatedQuestions));

        // Save to local JSON
        await _saveForm(updatedQuestions);
      }
    });

    on<RemoveField>((event, emit) async {
      final currentState = state;
      if (currentState is FormBuilding) {
        final updatedQuestions = List<Question>.from(currentState.questions)
          ..removeWhere((q) => q.id == event.questionId);
        emit(FormBuilding(questions: updatedQuestions));

        // Save to local JSON
        await _saveForm(updatedQuestions);
      }
    });

    on<ReorderField>((event, emit) async {
      final currentState = state;
      if (currentState is FormBuilding) {
        final updatedQuestions = List<Question>.from(currentState.questions);
        final item = updatedQuestions.removeAt(event.oldIndex);
        updatedQuestions.insert(
          event.newIndex > event.oldIndex ? event.newIndex - 1 : event.newIndex,
          item,
        );
        emit(FormBuilding(questions: updatedQuestions));

        // Save to local JSON
        await _saveForm(updatedQuestions);
      }
    });
  }

  Future<void> _saveForm(List<Question> questions) async {
    // If form is new, create a new id and save empty json
    if (_formId == null) {
      _formId = const Uuid().v4();
      // Initial save with empty questions
      await SavedFormsService.addForm(
        SavedForm(
          id: _formId!,
          title: _formTitle,
          lastModified: DateTime.now(),
          questions: questions,
        ),
      );
    } else {
      // Update existing form
      await SavedFormsService.addForm(
        SavedForm(
          id: _formId!,
          title: _formTitle,
          lastModified: DateTime.now(),
          questions: questions,
        ),
      );
    }
  }
}
