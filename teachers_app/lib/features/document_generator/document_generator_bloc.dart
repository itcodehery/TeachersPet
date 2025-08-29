import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:teachers_app/features/document_generator/document_generator_state.dart';
import 'package:teachers_app/features/form_builder/question_model.dart';
import 'package:teachers_app/features/document_generator/pdf_generator.dart';

final documentGeneratorProvider =
    StateNotifierProvider<DocumentGeneratorNotifier, DocumentGeneratorState>((
      ref,
    ) {
      return DocumentGeneratorNotifier();
    });

class DocumentGeneratorNotifier extends StateNotifier<DocumentGeneratorState> {
  DocumentGeneratorNotifier() : super(DocumentInitial());

  Future<void> generateDocument(List<Question> questions) async {
    state = GeneratingDocument();
    try {
      final pdfBytes = await generateQuestionPaperPdf(questions);

      final Directory tempDir = await getTemporaryDirectory();
      final String filePath = '${tempDir.path}/question_paper.pdf';
      final File file = File(filePath);
      await file.writeAsBytes(pdfBytes);

      await Share.shareXFiles([XFile(filePath)]);

      state = DocumentGenerated(filePath);
    } catch (e) {
      state = GenerationFailed(e.toString());
    }
  }
}