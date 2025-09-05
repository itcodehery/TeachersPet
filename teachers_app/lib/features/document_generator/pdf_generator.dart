import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:minty/features/form_builder/saved_forms_service.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:minty/features/form_builder/question_model.dart';

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

Future<Uint8List> generateQuestionPaperPdf(SavedForm form) async {
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

  pw.MemoryImage? logoImage;
  try {
    logoImage = pw.MemoryImage(
      await rootBundle
          .load('assets/florence_academy.png')
          .then((data) => data.buffer.asUint8List()),
    );
  } catch (e) {
    debugPrint('Error loading header image: $e');
    // logoImage will remain null
  }

  pdf.addPage(
    pw.MultiPage(
      pageFormat: PdfPageFormat.a4,
      margin: const pw.EdgeInsets.all(32),
      // header: (context) => _buildHeader(form, logoImage),
      build: (context) => [
        _buildHeader(form, logoImage),
        ...form.questions.map(
          (q) => _buildQuestionWidget(q, counter, mainCounter),
        ),
      ],
    ),
  );

  return pdf.save();
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
              pw.Table(
                columnWidths: {
                  0: const pw.FlexColumnWidth(1),
                  1: const pw.FlexColumnWidth(1),
                },
                children: [
                  for (int i = 0; i < options.length; i += 2)
                    pw.TableRow(
                      children: [
                        pw.Text(
                          '${String.fromCharCode(97 + i)}. ${options[i]}',
                        ),
                        if (i + 1 < options.length)
                          pw.Text(
                            '${String.fromCharCode(97 + i + 1)}. ${options[i + 1]}',
                          )
                        else
                          pw.Text(''),
                      ],
                    ),
                ],
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

pw.Widget _buildHeader(SavedForm form, pw.MemoryImage? logoImage) {
  return pw.Column(
    crossAxisAlignment: pw.CrossAxisAlignment.center,
    children: [
      pw.Row(
        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
        children: [
          logoImage != null
              ? pw.Image(logoImage, width: 80, height: 80)
              : pw.Container(),
          pw.Column(
            children: [
              pw.Text(
                "Florence Academy",
                style: pw.TextStyle(
                  fontSize: 24,
                  decoration: pw.TextDecoration.underline,
                ),
              ),
              pw.Text(
                "Lighting your Way",
                style: pw.TextStyle(fontStyle: pw.FontStyle.italic),
              ),
              pw.Text("Affiliated to CBSE No. 830628"),
              pw.Text("Electronic City, Bengaluru - 100"),
            ],
          ),
          pw.Container(width: 60),
        ],
      ),
      pw.Text(
        form.name.toUpperCase(),
        style: pw.TextStyle(fontSize: 12, fontWeight: pw.FontWeight.bold),
      ),
      pw.SizedBox(height: 8),
      pw.Table(
        columnWidths: {
          0: const pw.FlexColumnWidth(1),
          1: const pw.FlexColumnWidth(1),
        },
        defaultVerticalAlignment: pw.TableCellVerticalAlignment.middle,
        children: [
          pw.TableRow(
            children: [
              pw.Text('Grade: ${form.grade}'),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Code: ${form.code}'),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Text('Subject: ${form.subject}'),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Marks: ${form.marks}'),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Text('Roll No: ___'),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Duration: ${form.duration}'),
              ),
            ],
          ),
          pw.TableRow(
            children: [
              pw.Text('Name of the Student: ______'),
              pw.Align(
                alignment: pw.Alignment.centerRight,
                child: pw.Text('Date: ${form.date}'),
              ),
            ],
          ),
        ],
      ),
    ],
  );
}
