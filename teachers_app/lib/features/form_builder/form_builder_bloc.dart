import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_builder_event.dart';
import 'form_builder_state.dart';
import 'question_model.dart';

class FormBuilderBloc extends Bloc<FormBuilderEvent, FormBuilderState> {
  FormBuilderBloc() : super(const FormBuilding()) {
    on<AddField>((event, emit) {
      final currentState = state;
      if (currentState is FormBuilding) {
        final updatedQuestions = List<Question>.from(currentState.questions)
          ..add(event.question);
        emit(FormBuilding(questions: updatedQuestions));
      }
    });

    on<UpdateField>((event, emit) {
      final currentState = state;
      if (currentState is FormBuilding) {
        final updatedQuestions = currentState.questions.map((q) {
          if (q.id == event.question.id) {
            return event.question;
          }
          return q;
        }).toList();
        emit(FormBuilding(questions: updatedQuestions));
      }
    });

    on<RemoveField>((event, emit) {
      final currentState = state;
      if (currentState is FormBuilding) {
        final updatedQuestions = List<Question>.from(currentState.questions)
          ..removeWhere((q) => q.id == event.questionId);
        emit(FormBuilding(questions: updatedQuestions));
      }
    });

    on<ReorderField>((event, emit) {
      final currentState = state;
      if (currentState is FormBuilding) {
        final updatedQuestions = List<Question>.from(currentState.questions);
        final item = updatedQuestions.removeAt(event.oldIndex);
        updatedQuestions.insert(
          event.newIndex > event.oldIndex ? event.newIndex - 1 : event.newIndex,
          item,
        );
        emit(FormBuilding(questions: updatedQuestions));
      }
    });
  }
}
