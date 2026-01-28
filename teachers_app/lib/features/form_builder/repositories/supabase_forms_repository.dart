import 'package:supabase_flutter/supabase_flutter.dart';
import '../saved_forms_service.dart';
import '../question_model.dart';
import 'forms_repository.dart';

class SupabaseFormsRepository implements FormsRepository {
  final _supabase = Supabase.instance.client;

  @override
  Future<List<SavedForm>> loadForms() async {
    final response = await _supabase
        .from('forms')
        .select()
        .order('last_modified', ascending: false);

    return (response as List).map((json) => _fromJson(json)).toList();
  }

  @override
  Future<void> saveForm(SavedForm form) async {
    final user = _supabase.auth.currentUser;
    print('DEBUG: Saving form. Current user: $user'); // Debug print
    if (user == null) {
      throw Exception('User not logged in');
    }

    final data = _toJson(form);
    data['user_id'] = user.id;

    await _supabase.from('forms').upsert(data);
  }

  @override
  Future<void> deleteForm(String id) async {
    await _supabase.from('forms').delete().match({'id': id});
  }

  Map<String, dynamic> _toJson(SavedForm form) {
    return {
      'id': form.id,
      'name': form.name,
      'created_at': form.createdOn.toIso8601String(),
      'last_modified': form.lastModified.toIso8601String(),
      'questions': form.questions.map((q) => q.toJson()).toList(),
      'selected_header_id': form.selectedHeaderId,
      'institute_name': form.instituteName,
      'exam_title': form.examTitle,
      'subtitle': form.subtitle,
      'date_str': form.date,
      'duration': form.duration,
      'max_marks': form.maxMarks,
      'subject': form.subject,
      'class_name': form.className,
      'custom_field_values': form.customFieldValues,
    };
  }

  SavedForm _fromJson(Map<String, dynamic> json) {
    return SavedForm(
      id: json['id'],
      name: json['name'],
      createdOn: DateTime.parse(json['created_at']),
      lastModified: DateTime.parse(json['last_modified']),
      questions: (json['questions'] as List)
          .map((q) => Question.fromJson(q))
          .toList(),
      selectedHeaderId: json['selected_header_id'],
      instituteName: json['institute_name'],
      examTitle: json['exam_title'],
      subtitle: json['subtitle'],
      date: json['date_str'],
      duration: json['duration'],
      maxMarks: json['max_marks'],
      subject: json['subject'],
      className: json['class_name'],
      customFieldValues: Map<String, String>.from(
        json['custom_field_values'] ?? {},
      ),
    );
  }
}
