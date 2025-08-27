enum QuestionType {
  shortAnswer,
  longAnswer,
  multipleChoice,
  matchTheFollowing,
  sectionDivider,
  groupedQuestions,
}

class Question {
  final String id;
  final String title;
  final QuestionType type;
  final List<String>? options; // For MCQ, Match the Following
  final int? marks; // For section divider
  final String? sectionTitle; // For section divider
  final List<Question>? subQuestions; // For groupedQuestions

  Question({
    required this.id,
    required this.title,
    required this.type,
    this.options,
    this.marks,
    this.sectionTitle,
    this.subQuestions,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.toString().split('.').last,
    'options': options,
    'marks': marks,
    'sectionTitle': sectionTitle,
    'subQuestions': subQuestions?.map((q) => q.toJson()).toList(),
  };

  factory Question.fromJson(Map<String, dynamic> json) => Question(
    id: json['id'],
    title: json['title'],
    type: QuestionTypeExtension.fromString(json['type']),
    options: (json['options'] as List?)?.map((e) => e as String).toList(),
    marks: json['marks'],
    sectionTitle: json['sectionTitle'],
    subQuestions: (json['subQuestions'] as List?)
        ?.map((q) => Question.fromJson(q))
        .toList(),
  );
}

extension QuestionTypeExtension on QuestionType {
  static QuestionType fromString(String s) {
    switch (s) {
      case 'shortAnswer':
        return QuestionType.shortAnswer;
      case 'longAnswer':
        return QuestionType.longAnswer;
      case 'multipleChoice':
        return QuestionType.multipleChoice;
      case 'matchTheFollowing':
        return QuestionType.matchTheFollowing;
      case 'sectionDivider':
        return QuestionType.sectionDivider;
      case 'groupedQuestions':
        return QuestionType.groupedQuestions;
      default:
        throw Exception('Unknown QuestionType: $s');
    }
  }
}
