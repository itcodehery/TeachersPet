enum QuestionType {
  shortAnswer,
  longAnswer,
  multipleChoice,
  matchTheFollowing,
  sectionDivider,
}

class Question {
  final String id;
  final String title;
  final QuestionType type;
  final List<String>? options; // For MCQ, Match the Following
  final int? marks; // For section divider
  final String? sectionTitle; // For section divider

  Question({
    required this.id,
    required this.title,
    required this.type,
    this.options,
    this.marks,
    this.sectionTitle,
  });
}
