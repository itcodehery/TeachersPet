import 'package:flutter_bloc/flutter_bloc.dart';
import 'document_generator_event.dart';
import 'document_generator_state.dart';
import '../form_builder/question_model.dart';
import 'package:docx_template/docx_template.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:flutter/services.dart';

class DocumentGeneratorBloc
    extends Bloc<DocumentGeneratorEvent, DocumentGeneratorState> {
  DocumentGeneratorBloc() : super(GeneratingDocument()) {
    on<GenerateDocument>(_onGenerateDocument);
  }

  Future<void> _onGenerateDocument(
    GenerateDocument event,
    Emitter<DocumentGeneratorState> emit,
  ) async {
    emit(GeneratingDocument());
    try {
      // Load template.docx from assets
      final bytes = await rootBundle.load('assets/template.docx');
      final docx = await DocxTemplate.fromBytes(bytes.buffer.asUint8List());

      // Build question paper string
      StringBuffer paper = StringBuffer();
      for (final q in event.questions) {
        if (q.type == QuestionType.sectionDivider) {
          paper.writeln('\n${q.sectionTitle ?? 'Section'}');
          if (q.marks != null) {
            paper.writeln('Marks: ${q.marks}');
          }
        } else if (q.type == QuestionType.groupedQuestions) {
          paper.writeln('\n${q.title}');
          if (q.subQuestions != null) {
            for (final subQ in q.subQuestions!) {
              paper.writeln('  - ${subQ.title}');
            }
          }
        } else if (q.type == QuestionType.multipleChoice) {
          paper.writeln('\n${q.title}');
          if (q.options != null) {
            for (final opt in q.options!) {
              paper.writeln('  * $opt');
            }
          }
        } else if (q.type == QuestionType.matchTheFollowing) {
          paper.writeln('\n${q.title}');
          if (q.options != null) {
            for (final pair in q.options!) {
              paper.writeln('  $pair');
            }
          }
        } else {
          paper.writeln('\n${q.title}');
        }
      }

      final content = Content();
      content.add(TextContent('question_paper', paper.toString()));

      final generated = await docx.generate(content);
      if (generated == null) {
        emit(GenerationFailed('Failed to generate document!'));
        return;
      }

      final directory = await getApplicationDocumentsDirectory();
      final filePath =
          '${directory.path}/question_paper_${DateTime.now().millisecondsSinceEpoch}.docx';
      final file = File(filePath);
      await file.writeAsBytes(generated);

      emit(DocumentGenerated(filePath));
    } catch (e) {
      emit(GenerationFailed(e.toString()));
    }
  }
}
