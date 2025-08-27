
import 'question_model.dart';

abstract class FormBuilderState {
	const FormBuilderState();
}

class FormBuilding extends FormBuilderState {
	final List<Question> questions;
	const FormBuilding({this.questions = const []});
}

class FieldAdded extends FormBuilderState {
	final List<Question> questions;
	const FieldAdded(this.questions);
}

class FieldRemoved extends FormBuilderState {
	final List<Question> questions;
	const FieldRemoved(this.questions);
}

class FormComplete extends FormBuilderState {
	final List<Question> questions;
	const FormComplete(this.questions);
}
