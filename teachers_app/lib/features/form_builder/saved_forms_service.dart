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

  SavedForm({
    required this.id,
    required this.name,
    required this.createdOn,
    required this.lastModified,
    required this.questions,
  });

  SavedForm copyWith({
    String? id,
    String? name,
    DateTime? createdOn,
    DateTime? lastModified,
    List<Question>? questions,
  }) {
    return SavedForm(
      id: id ?? this.id,
      name: name ?? this.name,
      createdOn: createdOn ?? this.createdOn,
      lastModified: lastModified ?? this.lastModified,
      questions: questions ?? this.questions,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'createdOn': createdOn.toIso8601String(),
        'lastModified': lastModified.toIso8601String(),
        'questions': questions.map((q) => q.toJson()).toList(),
      };

  factory SavedForm.fromJson(Map<String, dynamic> json) => SavedForm(
        id: json['id'],
        name: json['name'],
        createdOn: DateTime.parse(json['createdOn']),
        lastModified: DateTime.parse(json['lastModified']),
        questions: (json['questions'] as List)
            .map((q) => Question.fromJson(q))
            .toList(),
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
