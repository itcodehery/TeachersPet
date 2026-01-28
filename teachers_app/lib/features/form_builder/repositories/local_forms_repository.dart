import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../saved_forms_service.dart';
import 'forms_repository.dart';

class LocalFormsRepository implements FormsRepository {
  Future<File> _getFile() async {
    final dir = await getApplicationDocumentsDirectory();
    return File('${dir.path}/forms.json');
  }

  @override
  Future<List<SavedForm>> loadForms() async {
    final file = await _getFile();
    if (!await file.exists()) return [];
    try {
      final content = await file.readAsString();
      final data = jsonDecode(content) as List;
      return data.map((f) => SavedForm.fromJson(f)).toList();
    } catch (e) {
      return [];
    }
  }

  @override
  Future<void> saveForm(SavedForm form) async {
    final forms = await loadForms();
    final index = forms.indexWhere((f) => f.id == form.id);
    if (index >= 0) {
      forms[index] = form;
    } else {
      forms.add(form);
    }
    await saveAllForms(forms);
  }

  Future<void> saveAllForms(List<SavedForm> forms) async {
    final file = await _getFile();
    final content = jsonEncode(forms.map((f) => f.toJson()).toList());
    await file.writeAsString(content);
  }

  @override
  Future<void> deleteForm(String id) async {
    final forms = await loadForms();
    forms.removeWhere((f) => f.id == id);
    await saveAllForms(forms);
  }
}
