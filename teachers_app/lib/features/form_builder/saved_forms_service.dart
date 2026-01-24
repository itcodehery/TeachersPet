import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../form_builder/question_model.dart';

class SavedForm {
  final String id;
  final String name;
  final DateTime createdOn;
  final DateTime lastModified;
  final List<Question> questions;
  final String? selectedHeaderId; // null = use default "Simple"
  // Header content values (per-form)
  final String? instituteName;
  final String? examTitle;
  final String? subtitle;
  final String? date;
  final String? duration;
  final String? maxMarks;
  final String? subject;
  final String? className;
  final Map<String, String> customFieldValues; // field name -> value

  SavedForm({
    required this.id,
    required this.name,
    required this.createdOn,
    required this.lastModified,
    required this.questions,
    this.selectedHeaderId,
    this.instituteName,
    this.examTitle,
    this.subtitle,
    this.date,
    this.duration,
    this.maxMarks,
    this.subject,
    this.className,
    this.customFieldValues = const {},
  });

  SavedForm copyWith({
    String? id,
    String? name,
    DateTime? createdOn,
    DateTime? lastModified,
    List<Question>? questions,
    String? selectedHeaderId,
    String? instituteName,
    String? examTitle,
    String? subtitle,
    String? date,
    String? duration,
    String? maxMarks,
    String? subject,
    String? className,
    Map<String, String>? customFieldValues,
  }) {
    return SavedForm(
      id: id ?? this.id,
      name: name ?? this.name,
      createdOn: createdOn ?? this.createdOn,
      lastModified: lastModified ?? this.lastModified,
      questions: questions ?? this.questions,
      selectedHeaderId: selectedHeaderId ?? this.selectedHeaderId,
      instituteName: instituteName ?? this.instituteName,
      examTitle: examTitle ?? this.examTitle,
      subtitle: subtitle ?? this.subtitle,
      date: date ?? this.date,
      duration: duration ?? this.duration,
      maxMarks: maxMarks ?? this.maxMarks,
      subject: subject ?? this.subject,
      className: className ?? this.className,
      customFieldValues: customFieldValues ?? this.customFieldValues,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'createdOn': createdOn.toIso8601String(),
    'lastModified': lastModified.toIso8601String(),
    'questions': questions.map((q) => q.toJson()).toList(),
    'selectedHeaderId': selectedHeaderId,
    'instituteName': instituteName,
    'examTitle': examTitle,
    'subtitle': subtitle,
    'date': date,
    'duration': duration,
    'maxMarks': maxMarks,
    'subject': subject,
    'className': className,
    'customFieldValues': customFieldValues,
  };

  factory SavedForm.fromJson(Map<String, dynamic> json) => SavedForm(
    id: json['id'],
    name: json['name'],
    createdOn: DateTime.parse(json['createdOn']),
    lastModified: DateTime.parse(json['lastModified']),
    questions: (json['questions'] as List)
        .map((q) => Question.fromJson(q))
        .toList(),
    selectedHeaderId: json['selectedHeaderId'],
    instituteName: json['instituteName'],
    examTitle: json['examTitle'],
    subtitle: json['subtitle'],
    date: json['date'],
    duration: json['duration'],
    maxMarks: json['maxMarks'],
    subject: json['subject'],
    className: json['className'],
    customFieldValues:
        (json['customFieldValues'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v.toString()),
        ) ??
        {},
  );
}

class SavedFormsService {
  static Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/forms.json');
  }

  static Future<List<SavedForm>> loadForms() async {
    final file = await _getFile();
    if (!await file.exists()) return [];
    final content = await file.readAsString();
    final data = jsonDecode(content) as List;
    return data.map((f) => SavedForm.fromJson(f)).toList();
  }

  static Future<void> saveForms(List<SavedForm> forms) async {
    final file = await _getFile();
    final content = jsonEncode(forms.map((f) => f.toJson()).toList());
    await file.writeAsString(content);
  }

  static Future<void> addForm(SavedForm form) async {
    final forms = await loadForms();
    forms.removeWhere((f) => f.id == form.id);
    forms.add(form);
    await saveForms(forms);
  }

  static Future<void> deleteForm(String id) async {
    final forms = await loadForms();
    forms.removeWhere((f) => f.id == id);
    await saveForms(forms);
  }
}
