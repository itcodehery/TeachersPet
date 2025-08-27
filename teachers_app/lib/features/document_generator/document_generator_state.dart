abstract class DocumentGeneratorState {}

class GeneratingDocument extends DocumentGeneratorState {}
class DocumentGenerated extends DocumentGeneratorState {}
class GenerationFailed extends DocumentGeneratorState {}
