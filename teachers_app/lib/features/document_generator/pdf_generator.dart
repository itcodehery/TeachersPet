import 'dart:io';
import 'package:flutter/services.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:minty/features/form_builder/question_model.dart';
import 'package:minty/features/form_builder/header_template_model.dart';
import 'package:minty/features/form_builder/prebuilt_headers.dart';

class QuestionCounter {
  int count = 1;
}

class MainCounter {
  int count = 1;
}

const Map<int, String> romanNumeralsTill15 = {
  1: 'I',
  2: 'II',
  3: 'III',
  4: 'IV',
  5: 'V',
  6: 'VI',
  7: 'VII',
  8: 'VIII',
  9: 'IX',
  10: 'X',
  11: 'XI',
  12: 'XII',
  13: 'XIII',
  14: 'XIV',
  15: 'XV',
};

Future<Uint8List> generateQuestionPaperPdf(
  List<Question> questions, {
  HeaderTemplate? headerTemplate,
  // Form content values
  String? instituteName,
  String? examTitle,
  String? subtitle,
  String? date,
  String? duration,
  String? maxMarks,
  String? subject,
  String? className,
  Map<String, String>? customFieldValues,
}) async {
  final font = await rootBundle.load('assets/times.ttf');
  final boldFont = await rootBundle.load('assets/timesbd.ttf');
  final italicFont = await rootBundle.load('assets/timesi.ttf');
  final boldItalicFont = await rootBundle.load('assets/timesbi.ttf');

  final theme = pw.ThemeData.withFont(
    base: pw.Font.ttf(font),
    bold: pw.Font.ttf(boldFont),
    italic: pw.Font.ttf(italicFont),
    boldItalic: pw.Font.ttf(boldItalicFont),
  ).copyWith(defaultTextStyle: const pw.TextStyle(fontSize: 12));

  final pdf = pw.Document(theme: theme);
  final counter = QuestionCounter();
  final mainCounter = MainCounter();

  // Use provided template or default to Simple
  final template = headerTemplate ?? PrebuiltHeaders.defaultTemplate;

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      build: (context) => [
        _buildHeaderFromTemplate(
          template,
          instituteName: instituteName,
          examTitle: examTitle,
          subtitle: subtitle,
          date: date,
          duration: duration,
          maxMarks: maxMarks,
          subject: subject,
          className: className,
          customFieldValues: customFieldValues,
        ),
        pw.SizedBox(height: 20),
        ...questions.map((q) => _buildQuestionWidget(q, counter, mainCounter)),
      ],
    ),
  );

  return pdf.save();
}

/// Builds a PDF header widget from a HeaderTemplate
pw.Widget _buildHeaderFromTemplate(
  HeaderTemplate template, {
  String? instituteName,
  String? examTitle,
  String? subtitle,
  String? date,
  String? duration,
  String? maxMarks,
  String? subject,
  String? className,
  Map<String, String>? customFieldValues,
}) {
  // Blank template = no header
  if (template.id == 'prebuilt_blank') {
    return pw.SizedBox.shrink();
  }

  final alignment = template.titleAlignment == HeaderAlignment.left
      ? pw.CrossAxisAlignment.start
      : template.titleAlignment == HeaderAlignment.right
      ? pw.CrossAxisAlignment.end
      : pw.CrossAxisAlignment.center;

  final textAlign = template.titleAlignment == HeaderAlignment.left
      ? pw.TextAlign.left
      : template.titleAlignment == HeaderAlignment.right
      ? pw.TextAlign.right
      : pw.TextAlign.center;

  final rowMainAlignment = template.titleAlignment == HeaderAlignment.left
      ? pw.MainAxisAlignment.start
      : template.titleAlignment == HeaderAlignment.right
      ? pw.MainAxisAlignment.end
      : pw.MainAxisAlignment.center;

  // Helper to format a field - if value is set, display it; otherwise show blank
  String formatField(String label, String? value) {
    if (value != null && value.isNotEmpty) {
      return '$label: $value';
    }
    return '$label: ________________';
  }

  final content = pw.Column(
    crossAxisAlignment: alignment,
    children: [
      // Institution name (use form value if template has it enabled)
      if (template.instituteName != null)
        pw.Text(
          instituteName ?? 'Institution Name',
          style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 16),
          textAlign: textAlign,
        ),
      // Subtitle
      if (template.subtitle != null)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 2),
          child: pw.Text(
            subtitle ?? 'Subtitle',
            style: const pw.TextStyle(fontSize: 11),
            textAlign: textAlign,
          ),
        ),
      // Exam title
      if (template.examTitle != null)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 6),
          child: pw.Text(
            examTitle ?? 'Examination',
            style: pw.TextStyle(fontWeight: pw.FontWeight.bold, fontSize: 14),
            textAlign: textAlign,
          ),
        ),
      // Date, Duration, Max Marks row
      if (template.showDate || template.showDuration || template.showMaxMarks)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 8),
          child: pw.Row(
            mainAxisAlignment: rowMainAlignment,
            children: [
              if (template.showDate)
                pw.Text(
                  formatField('Date', date),
                  style: const pw.TextStyle(fontSize: 11),
                ),
              if (template.showDuration)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 20),
                  child: pw.Text(
                    formatField('Duration', duration),
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
              if (template.showMaxMarks)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 20),
                  child: pw.Text(
                    formatField('Max Marks', maxMarks),
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
      // Subject, Class row
      if (template.showSubjectField || template.showClassField)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Row(
            mainAxisAlignment: rowMainAlignment,
            children: [
              if (template.showSubjectField)
                pw.Text(
                  formatField('Subject', subject),
                  style: const pw.TextStyle(fontSize: 11),
                ),
              if (template.showClassField)
                pw.Padding(
                  padding: const pw.EdgeInsets.only(left: 20),
                  child: pw.Text(
                    formatField('Class', className),
                    style: const pw.TextStyle(fontSize: 11),
                  ),
                ),
            ],
          ),
        ),
      // Custom fields
      if (template.customFields.isNotEmpty)
        pw.Padding(
          padding: const pw.EdgeInsets.only(top: 4),
          child: pw.Wrap(
            spacing: 20,
            runSpacing: 4,
            alignment: template.titleAlignment == HeaderAlignment.left
                ? pw.WrapAlignment.start
                : template.titleAlignment == HeaderAlignment.right
                ? pw.WrapAlignment.end
                : pw.WrapAlignment.center,
            children: template.customFields.map((field) {
              final value = customFieldValues?[field];
              return pw.Text(
                formatField(field, value),
                style: const pw.TextStyle(fontSize: 11),
              );
            }).toList(),
          ),
        ),
    ],
  );

  // Wrap in border if needed
  if (template.showBorder) {
    return pw.Container(
      padding: const pw.EdgeInsets.all(12),
      decoration: pw.BoxDecoration(
        border: pw.Border.all(color: PdfColors.black, width: 1),
      ),
      child: content,
    );
  }

  return content;
}

pw.Widget _buildQuestionWidget(
  Question question,
  QuestionCounter counter,
  MainCounter mainCounter,
) {
  switch (question.type) {
    case QuestionType.shortAnswer:
    case QuestionType.longAnswer:
    case QuestionType.fillInTheBlanks:
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 8.0),
        child: pw.Row(
          children: [
            pw.Text('${counter.count++}. '),
            _buildTextWithFractions(question.title),
          ],
        ),
      );
    case QuestionType.multipleChoice:
      final options = question.options ?? [];
      const int maxCharsInLine = 80;
      final totalChars = options.join().length;

      final useSingleLine = totalChars < maxCharsInLine;

      if (useSingleLine) {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 16.0),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Text('${counter.count++}. '),
                  _buildTextWithFractions(question.title),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.Row(
                mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                children: options.asMap().entries.map((entry) {
                  return pw.Text(
                    '${String.fromCharCode(97 + entry.key)}. ${entry.value}',
                  );
                }).toList(),
              ),
            ],
          ),
        );
      } else {
        return pw.Padding(
          padding: const pw.EdgeInsets.only(bottom: 16.0),
          child: pw.Column(
            crossAxisAlignment: pw.CrossAxisAlignment.start,
            children: [
              pw.Row(
                children: [
                  pw.Text('${counter.count++}. '),
                  _buildTextWithFractions(question.title),
                ],
              ),
              pw.SizedBox(height: 8),
              pw.GridView(
                crossAxisCount: 2,
                childAspectRatio: 12,
                children: options.asMap().entries.map((entry) {
                  return pw.Text(
                    '${String.fromCharCode(97 + entry.key)}. ${entry.value}',
                  );
                }).toList(),
              ),
            ],
          ),
        );
      }
    case QuestionType.matchTheFollowing:
      final pairs = (question.options ?? []).map((opt) {
        final parts = opt.split('=');
        return MapEntry(parts[0], parts.length > 1 ? parts[1] : '');
      }).toList();

      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 16.0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text('${counter.count++}. '),
                _buildTextWithFractions(question.title),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Column(
              children: pairs.map((pair) {
                return pw.Padding(
                  padding: const pw.EdgeInsets.symmetric(vertical: 2.0),
                  child: pw.Row(
                    children: [
                      pw.Expanded(flex: 2, child: pw.Text(pair.key)),
                      pw.Expanded(
                        flex: 1,
                        child: pw.Center(child: pw.Text('-')),
                      ),
                      pw.Expanded(
                        flex: 2,
                        child: pw.Text(
                          pair.value,
                          textAlign: pw.TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      );
    case QuestionType.sectionDivider:
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: pw.Column(
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Expanded(
                  child: pw.Text(
                    question.sectionTitle ?? '',
                    textAlign: pw.TextAlign.center,
                    style: pw.TextStyle(
                      fontWeight: pw.FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
                if (question.marks != null)
                  pw.Text(
                    '${question.marks}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
              ],
            ),
          ],
        ),
      );
    case QuestionType.mainDivider:
      final mainText =
          '${romanNumeralsTill15[mainCounter.count++]}. ${question.title}';
      return pw.Padding(
        padding: const pw.EdgeInsets.only(top: 16.0, bottom: 16.0),
        child: pw.Column(
          children: [
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.end,
              children: [
                pw.Text(
                  mainText,
                  textAlign: pw.TextAlign.center,
                  style: pw.TextStyle(
                    fontWeight: pw.FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                pw.Spacer(),

                if (question.marks != null)
                  pw.Text(
                    '${question.marks}',
                    style: pw.TextStyle(fontWeight: pw.FontWeight.bold),
                  ),
              ],
            ),
          ],
        ),
      );
    case QuestionType.groupedQuestions:
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 16.0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text('${counter.count++}. '),
                _buildTextWithFractions(question.title),
              ],
            ),
            pw.Padding(
              padding: const pw.EdgeInsets.only(left: 16.0),
              child: pw.Column(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: (question.subQuestions ?? []).asMap().entries.map((
                  entry,
                ) {
                  final subQuestionText =
                      '${String.fromCharCode(97 + entry.key)}. ${entry.value.title}';
                  return pw.Padding(
                    padding: const pw.EdgeInsets.only(bottom: 8.0),
                    child: _buildTextWithFractions(subQuestionText),
                  );
                }).toList(),
              ),
            ),
          ],
        ),
      );
    case QuestionType.questionWithImage:
      List<pw.Widget> imageWidgets = [];
      if (question.imagePaths != null && question.imagePaths!.isNotEmpty) {
        for (var imagePath in question.imagePaths!) {
          final image = pw.MemoryImage(File(imagePath).readAsBytesSync());
          imageWidgets.add(
            pw.Container(
              padding: const pw.EdgeInsets.symmetric(vertical: 8.0),
              height: 200,
              child: pw.Image(image),
            ),
          );
        }
      }
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 16.0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text('${counter.count++}. '),
                _buildTextWithFractions(question.title),
              ],
            ),
            if (imageWidgets.isNotEmpty) ...imageWidgets,
          ],
        ),
      );
    case QuestionType.groupedQuestionWithImage:
      List<pw.Widget> imageWidgets = [];
      if (question.imagePaths != null && question.imagePaths!.isNotEmpty) {
        for (var imagePath in question.imagePaths!) {
          final image = pw.MemoryImage(File(imagePath).readAsBytesSync());
          imageWidgets.add(pw.Image(image));
        }
      }
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 16.0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text('${counter.count++}. '),
                _buildTextWithFractions(question.title),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Row(
              crossAxisAlignment: pw.CrossAxisAlignment.start,
              children: [
                if (imageWidgets.isNotEmpty)
                  pw.Expanded(
                    flex: 1,
                    child: pw.Column(children: imageWidgets),
                  ),
                if (imageWidgets.isNotEmpty) pw.SizedBox(width: 16),
                pw.Expanded(
                  flex: 2,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: (question.subQuestions ?? []).asMap().entries.map((
                      entry,
                    ) {
                      final subQuestionText =
                          '${String.fromCharCode(97 + entry.key)}. ${entry.value.title}';
                      return pw.Padding(
                        padding: const pw.EdgeInsets.only(bottom: 8.0),
                        child: _buildTextWithFractions(subQuestionText),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    case QuestionType.table:
      return pw.Padding(
        padding: const pw.EdgeInsets.only(bottom: 16.0),
        child: pw.Column(
          crossAxisAlignment: pw.CrossAxisAlignment.start,
          children: [
            pw.Row(
              children: [
                pw.Text('${counter.count++}. '),
                _buildTextWithFractions(question.title),
              ],
            ),
            pw.SizedBox(height: 8),
            pw.Table.fromTextArray(
              data: question.tableData ?? [],
              border: pw.TableBorder.all(),
              cellStyle: const pw.TextStyle(),
              cellAlignment: pw.Alignment.center,
            ),
          ],
        ),
      );
  }
}

pw.Widget _buildTextWithFractions(String text) {
  final List<pw.InlineSpan> spans = [];
  final RegExp fractionRegExp = RegExp(r'(\d*)\s*\{(\d+)/(\d+)}');

  text.splitMapJoin(
    fractionRegExp,
    onMatch: (Match match) {
      final wholeNumber = match.group(1);
      final numerator = match.group(2)!;
      final denominator = match.group(3)!;

      final fractionWidget = pw.SizedBox(
        width: 20,
        child: pw.Column(
          mainAxisAlignment: pw.MainAxisAlignment.center,
          children: [
            pw.Text(numerator, style: const pw.TextStyle(fontSize: 10)),
            pw.Container(height: 1, color: PdfColors.black, width: 15),
            pw.Text(denominator, style: const pw.TextStyle(fontSize: 10)),
          ],
        ),
      );

      if (wholeNumber != null && wholeNumber.isNotEmpty) {
        spans.add(
          pw.WidgetSpan(
            child: pw.Row(
              mainAxisSize: pw.MainAxisSize.min,
              children: [
                pw.Text(wholeNumber),
                pw.SizedBox(width: 2),
                fractionWidget,
              ],
            ),
          ),
        );
      } else {
        spans.add(pw.WidgetSpan(child: fractionWidget));
      }

      return '';
    },
    onNonMatch: (String nonMatch) {
      spans.add(pw.TextSpan(text: nonMatch));
      return '';
    },
  );

  return pw.RichText(text: pw.TextSpan(children: spans));
}
