import 'package:split_button/split_button.dart';
import 'package:teachers_app/features/form_builder/form_builder_body.dart';
import '../document_generator/document_generator_bloc.dart';
import '../document_generator/document_generator_event.dart';
import '../document_generator/document_generator_state.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'form_builder_bloc.dart';
import 'form_builder_state.dart';
import 'add_questions_dialog.dart';

// For grouped questions
Map<String, Function(BuildContext)> splitOptionList = {
  'Add Node': (context) {
    showDialog(
      context: context,
      builder: (context) => const AddQuestionDialog(),
    );
  },
  'Preview': (context) {
    // Handle preview action
  },
  'Export': (context) {
    final bloc = BlocProvider.of<FormBuilderBloc>(context);
    final state = bloc.state;
    if (state is! FormBuilding || state.questions.isEmpty) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('No questions to export!')));
      return;
    }

    // Dispatch document generation event
    final docGenBloc = BlocProvider.of<DocumentGeneratorBloc>(context);
    docGenBloc.add(GenerateDocument(state.questions));

    // Listen for result
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return BlocListener<DocumentGeneratorBloc, DocumentGeneratorState>(
          bloc: docGenBloc,
          listener: (context, docState) {
            if (docState is DocumentGenerated) {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Exported to ${docState.filePath}')),
              );
            } else if (docState is GenerationFailed) {
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Export failed: ${docState.error}')),
              );
            }
          },
          child: const Center(child: CircularProgressIndicator()),
        );
      },
    );
  },
};

Map<String, IconData> splitOptionIcons = {
  'Add Node': Icons.add,
  'Preview': Icons.remove_red_eye,
  'Export': Icons.file_download,
};

class FormBuilderScreen extends StatelessWidget {
  const FormBuilderScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => FormBuilderBloc(),
      child: Builder(
        builder: (blocContext) => Scaffold(
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => blocContext.pop(),
            ),
            title: Column(
              children: [
                TextButton(
                  onPressed: () {},
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.lime.withAlpha(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        'Question Paper',
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(width: 4),
                      const Icon(
                        Icons.edit_outlined,
                        size: 16,
                        color: Colors.white70,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Last modified: 12/12/2022',
                  style: TextStyle(fontSize: 10, color: Colors.white70),
                ),
              ],
            ),
            centerTitle: true,
            elevation: 2,
          ),
          body: const FormBuilderBody(),
          floatingActionButton: SplitButton(
            backgroundColor: Colors.lime,
            foregroundColor: Colors.black,
            onPressed: () => splitOptionList['Add Node']!(context),
            popupList: splitOptionList.entries.map((entry) {
              return SplitButtonEntry(
                value: entry.key,
                child: ListTile(
                  onTap: () => entry.value(context),
                  textColor: Colors.black,
                  iconColor: Colors.black,
                  leading: Icon(splitOptionIcons[entry.key]),
                  title: Text(entry.key),
                ),
              );
            }).toList(),
            title: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.add),
                const Text('Add Node', style: TextStyle(fontFamily: 'Outfit')),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
