import 'package:flutter_bloc/flutter_bloc.dart';
import 'form_response_event.dart';
import 'form_response_state.dart';

class FormResponseBloc extends Bloc<FormResponseEvent, FormResponseState> {
	FormResponseBloc() : super(FormLoading()) {
		// TODO: Add event handlers
	}
}
