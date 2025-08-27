import 'question_model.dart';

abstract class FormBuilderEvent {}

class AddField extends FormBuilderEvent {
	final Question question;
	AddField(this.question);
}

class RemoveField extends FormBuilderEvent {
	final String questionId;
	RemoveField(this.questionId);
}

class ReorderField extends FormBuilderEvent {
	final int oldIndex;
	final int newIndex;
	ReorderField(this.oldIndex, this.newIndex);
}

class CompleteForm extends FormBuilderEvent {}
