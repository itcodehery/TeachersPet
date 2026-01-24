enum QuestionType {
  shortAnswer,
  longAnswer,
  multipleChoice,
  matchTheFollowing,
  sectionDivider,
  groupedQuestions,
  fillInTheBlanks,
  questionWithImage,
  groupedQuestionWithImage,
  mainDivider,
  table,
}

class QuestionImage {
  final String path;
  final String alignment; // 'left', 'center', 'right'
  final double width; // 0.1 to 1.0 (10% to 100%)

  QuestionImage({
    required this.path,
    this.alignment = 'center',
    this.width = 1.0,
  });

  Map<String, dynamic> toJson() => {
    'path': path,
    'alignment': alignment,
    'width': width,
  };

  factory QuestionImage.fromJson(Map<String, dynamic> json) => QuestionImage(
    path: json['path'],
    alignment: json['alignment'] ?? 'center',
    width: (json['width'] as num?)?.toDouble() ?? 1.0,
  );

  QuestionImage copyWith({String? path, String? alignment, double? width}) {
    return QuestionImage(
      path: path ?? this.path,
      alignment: alignment ?? this.alignment,
      width: width ?? this.width,
    );
  }
}

class Question {
  final String id;
  final String title;
  final QuestionType type;
  final List<String>? options; // For MCQ, Match the Following
  final String? marks; // For section divider
  final String? sectionTitle; // For section divider
  final List<Question>? subQuestions; // For groupedQuestions
  // Deprecated: imagePaths, use images instead
  final List<String>? imagePaths;
  final List<QuestionImage>?
  images; // For questionWithImage and groupedQuestionWithImage
  final List<List<String>>? tableData; // For table

  Question({
    required this.id,
    required this.title,
    required this.type,
    this.options,
    this.marks,
    this.sectionTitle,
    this.subQuestions,
    this.imagePaths,
    this.images,
    this.tableData,
  });

  Map<String, dynamic> toJson() => {
    'id': id,
    'title': title,
    'type': type.toString().split('.').last,
    'options': options,
    'marks': marks,
    'sectionTitle': sectionTitle,
    'subQuestions': subQuestions?.map((q) => q.toJson()).toList(),
    'images': images?.map((i) => i.toJson()).toList(),
    'tableData': tableData,
    // Keep imagePaths null in JSON to avoid duplication, migration should be one-way
  };

  factory Question.fromJson(Map<String, dynamic> json) {
    // Handle migration from old imagePaths to new images list
    List<QuestionImage>? loadedImages;

    if (json['images'] != null) {
      loadedImages = (json['images'] as List)
          .map((i) => QuestionImage.fromJson(i as Map<String, dynamic>))
          .toList();
    } else if (json['imagePaths'] != null) {
      // Backward compatibility: Convert strings to QuestionImage objects
      loadedImages = (json['imagePaths'] as List)
          .map((path) => QuestionImage(path: path as String))
          .toList();
    }

    return Question(
      id: json['id'],
      title: json['title'],
      type: QuestionTypeExtension.fromString(json['type']),
      options: (json['options'] as List?)?.map((e) => e as String).toList(),
      marks: json['marks'],
      sectionTitle: json['sectionTitle'],
      subQuestions: (json['subQuestions'] as List?)
          ?.map((q) => Question.fromJson(q as Map<String, dynamic>))
          .toList(),
      images: loadedImages,
      // We don't populate imagePaths anymore, prefer images
      imagePaths: null,
      tableData: (json['tableData'] as List?)
          ?.map((row) => (row as List).map((cell) => cell as String).toList())
          .toList(),
    );
  }

  Question copyWith({
    String? id,
    String? title,
    QuestionType? type,
    List<String>? options,
    String? marks,
    String? sectionTitle,
    List<Question>? subQuestions,
    List<QuestionImage>? images,
    List<List<String>>? tableData,
  }) {
    return Question(
      id: id ?? this.id,
      title: title ?? this.title,
      type: type ?? this.type,
      options: options ?? this.options,
      marks: marks ?? this.marks,
      sectionTitle: sectionTitle ?? this.sectionTitle,
      subQuestions: subQuestions ?? this.subQuestions,
      images: images ?? this.images,
      imagePaths: null, // Always null on copy to enforce migration
      tableData: tableData ?? this.tableData,
    );
  }
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
      case 'mainDivider':
        return QuestionType.mainDivider;
      case 'groupedQuestions':
        return QuestionType.groupedQuestions;
      case 'fillInTheBlanks':
        return QuestionType.fillInTheBlanks;
      case 'questionWithImage':
        return QuestionType.questionWithImage;
      case 'groupedQuestionWithImage':
        return QuestionType.groupedQuestionWithImage;
      case 'table':
        return QuestionType.table;
      default:
        throw Exception('Unknown QuestionType: $s');
    }
  }
}
