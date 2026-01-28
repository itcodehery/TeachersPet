import '../saved_forms_service.dart';

abstract class FormsRepository {
  Future<List<SavedForm>> loadForms();
  Future<void> saveForm(SavedForm form);
  Future<void> deleteForm(String id);
}
