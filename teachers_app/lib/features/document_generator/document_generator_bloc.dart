import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:minty/features/form_builder/saved_forms_service.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';
import 'package:minty/features/document_generator/document_generator_state.dart';
import 'package:minty/features/document_generator/pdf_generator.dart';

final documentGeneratorProvider =
    StateNotifierProvider<DocumentGeneratorNotifier, DocumentGeneratorState>((
      ref,
    ) {
      return DocumentGeneratorNotifier();
    });

class DocumentGeneratorNotifier extends StateNotifier<DocumentGeneratorState> {
  DocumentGeneratorNotifier() : super(DocumentInitial());

  Future<void> generateDocument(SavedForm form) async {
    state = GeneratingDocument();
    try {
      final pdfBytes = await generateQuestionPaperPdf(form);

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
