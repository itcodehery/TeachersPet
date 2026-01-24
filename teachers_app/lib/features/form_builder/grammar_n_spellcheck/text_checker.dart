import 'package:flutter/services.dart';
import 'package:spell_check_on_client/spell_check_on_client.dart';
import 'package:language_tool/language_tool.dart';

/// Represents a text error (spelling or grammar)
class TextError {
  final String originalText;
  final String errorWord;
  final String? suggestion;
  final int offset;
  final int length;
  final bool isSpelling;
  final String? message;

  TextError({
    required this.originalText,
    required this.errorWord,
    this.suggestion,
    required this.offset,
    required this.length,
    required this.isSpelling,
    this.message,
  });
}

/// Result of checking a piece of text
class CheckResult {
  final String originalText;
  final int questionIndex;
  final String fieldType; // 'title', 'option', 'subquestion'
  final List<TextError> spellingErrors;
  final List<TextError> grammarErrors;

  CheckResult({
    required this.originalText,
    required this.questionIndex,
    required this.fieldType,
    required this.spellingErrors,
    required this.grammarErrors,
  });

  bool get hasErrors => spellingErrors.isNotEmpty || grammarErrors.isNotEmpty;
}

/// Service for grammar and spelling checking
class TextChecker {
  static SpellCheck? _spellCheck;
  static LanguageTool? _languageTool;
  static bool _initialized = false;

  /// Initialize the checkers
  static Future<void> initialize() async {
    if (_initialized) return;

    // Initialize spell checker
    String language = 'en';
    String content = await rootBundle.loadString(
      'assets/${language}_words.txt',
    );
    _spellCheck = SpellCheck.fromWordsContent(
      content,
      letters: LanguageLetters.getLanguageForLanguage(language),
    );

    // Initialize LanguageTool for grammar
    _languageTool = LanguageTool();

    _initialized = true;
  }

  /// Find spelling errors in a word
  static List<TextError> findSpellingErrors(String text) {
    if (_spellCheck == null) return [];

    final errors = <TextError>[];
    final words = text.split(RegExp(r'\s+'));
    int currentOffset = 0;

    for (final word in words) {
      if (word.isEmpty) {
        currentOffset++;
        continue;
      }

      // Clean word of punctuation for checking
      final cleanWord = word.replaceAll(RegExp(r'[^\w]'), '');
      if (cleanWord.isEmpty) {
        currentOffset += word.length + 1;
        continue;
      }

      // Check if word is misspelled
      final suggestion = _spellCheck!.didYouMean(cleanWord);
      if (suggestion.isNotEmpty && suggestion != cleanWord.toLowerCase()) {
        errors.add(
          TextError(
            originalText: text,
            errorWord: cleanWord,
            suggestion: suggestion,
            offset: currentOffset,
            length: cleanWord.length,
            isSpelling: true,
            message: 'Possible spelling error',
          ),
        );
      }

      currentOffset += word.length + 1;
    }

    return errors;
  }

  /// Find grammar errors using LanguageTool API
  static Future<List<TextError>> findGrammarErrors(String text) async {
    if (_languageTool == null) return [];

    try {
      final mistakes = await _languageTool!.check(text);
      return mistakes
          .where(
            (m) => m.issueType != 'misspelling',
          ) // Exclude spelling (handled separately)
          .map(
            (match) => TextError(
              originalText: text,
              errorWord: text.substring(
                match.offset,
                match.offset + match.length,
              ),
              suggestion: match.replacements.isNotEmpty
                  ? match.replacements.first
                  : null,
              offset: match.offset,
              length: match.length,
              isSpelling: false,
              message: match.message,
            ),
          )
          .toList();
    } catch (e) {
      // API call failed (no internet, rate limit, etc.)
      return [];
    }
  }

  /// Check all texts and return results
  static Future<List<CheckResult>> checkTexts(
    List<Map<String, dynamic>> texts,
  ) async {
    await initialize();

    final results = <CheckResult>[];

    for (final item in texts) {
      final text = item['text'] as String;
      final questionIndex = item['questionIndex'] as int;
      final fieldType = item['fieldType'] as String;

      final spellingErrors = findSpellingErrors(text);
      final grammarErrors = await findGrammarErrors(text);

      results.add(
        CheckResult(
          originalText: text,
          questionIndex: questionIndex,
          fieldType: fieldType,
          spellingErrors: spellingErrors,
          grammarErrors: grammarErrors,
        ),
      );
    }

    return results;
  }

  /// Apply spelling correction to text
  static String correctSpelling(String text, List<TextError> errors) {
    if (errors.isEmpty) return text;

    // Sort errors by offset in reverse order to apply from end to start
    final sorted = List<TextError>.from(errors)
      ..sort((a, b) => b.offset.compareTo(a.offset));

    String result = text;
    for (final error in sorted) {
      if (error.suggestion != null) {
        result = result.replaceRange(
          error.offset,
          error.offset + error.length,
          error.suggestion!,
        );
      }
    }

    return result;
  }

  /// Apply grammar correction to text
  static String correctGrammar(String text, List<TextError> errors) {
    if (errors.isEmpty) return text;

    // Sort errors by offset in reverse order to apply from end to start
    final sorted = List<TextError>.from(errors)
      ..sort((a, b) => b.offset.compareTo(a.offset));

    String result = text;
    for (final error in sorted) {
      if (error.suggestion != null) {
        result = result.replaceRange(
          error.offset,
          error.offset + error.length,
          error.suggestion!,
        );
      }
    }

    return result;
  }
}
