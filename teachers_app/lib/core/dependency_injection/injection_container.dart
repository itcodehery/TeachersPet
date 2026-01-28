import 'package:get_it/get_it.dart';
import 'package:minty/features/auth/data/auth_api.dart';
import 'package:minty/features/form_builder/repositories/forms_repository.dart';
import 'package:minty/features/form_builder/repositories/supabase_forms_repository.dart';
import 'package:minty/features/form_builder/saved_forms_service.dart';

final sl = GetIt.instance;

Future<void> init() async {
  // Register services
  sl.registerLazySingleton<AuthApi>(() => AuthApi());

  // Register repositories
  // Use Supabase implementation
  sl.registerLazySingleton<FormsRepository>(() => SupabaseFormsRepository());
  // sl.registerLazySingleton<FormsRepository>(() => LocalFormsRepository()); // fallback

  // Config SavedFormsService to use the injected repository
  SavedFormsService.useRepository(sl<FormsRepository>());
}
