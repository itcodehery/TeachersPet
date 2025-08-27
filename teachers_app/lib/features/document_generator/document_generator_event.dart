import '../form_builder/question_model.dart';

abstract class DocumentGeneratorEvent {}

class GenerateDocument extends DocumentGeneratorEvent {
  final List<Question> questions;
  GenerateDocument(this.questions);
}
