abstract class DocumentGeneratorState {}

class GeneratingDocument extends DocumentGeneratorState {}

class DocumentGenerated extends DocumentGeneratorState {
  final String filePath;
  DocumentGenerated(this.filePath);
}

class GenerationFailed extends DocumentGeneratorState {
  final String error;
  GenerationFailed(this.error);
}
