import 'repositories/forms_repository.dart';
import 'repositories/local_forms_repository.dart';
import '../form_builder/question_model.dart';
// import 'repositories/supabase_forms_repository.dart'; // Uncomment to use Supabase

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
  final String fontFamily; // 'NotoSans' or 'TimesNewRoman'
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
    this.fontFamily = 'NotoSans',
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
    String? fontFamily,
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
      fontFamily: fontFamily ?? this.fontFamily,
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
    'fontFamily': fontFamily,
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
    fontFamily: json['fontFamily'] ?? 'NotoSans',
    customFieldValues:
        (json['customFieldValues'] as Map<String, dynamic>?)?.map(
          (k, v) => MapEntry(k, v.toString()),
        ) ??
        {},
  );
}

class SavedFormsService {
  // Configurable repository - defaults to local storage
  // Change this to SupabaseFormsRepository() to use Supabase
  static FormsRepository _repository = LocalFormsRepository();

  static void useRepository(FormsRepository repository) {
    _repository = repository;
  }

  static Future<List<SavedForm>> loadForms() async {
    return _repository.loadForms();
  }

  static Future<void> saveForms(List<SavedForm> forms) async {
    if (_repository is LocalFormsRepository) {
      await (_repository as LocalFormsRepository).saveAllForms(forms);
    } else {
      // For remote, we would ideally sync, but for now let's just warn or
      // try to save each one.
      for (final form in forms) {
        await _repository.saveForm(form);
      }
    }
  }

  static Future<void> addForm(SavedForm form) async {
    await _repository.saveForm(form);
  }

  static Future<void> deleteForm(String id) async {
    await _repository.deleteForm(id);
  }
}
