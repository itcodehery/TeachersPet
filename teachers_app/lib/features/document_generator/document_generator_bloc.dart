import 'package:flutter_bloc/flutter_bloc.dart';
import 'document_generator_event.dart';
import 'document_generator_state.dart';

class DocumentGeneratorBloc extends Bloc<DocumentGeneratorEvent, DocumentGeneratorState> {
	DocumentGeneratorBloc() : super(GeneratingDocument()) {
		// TODO: Add event handlers
	}
}
