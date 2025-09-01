import 'package:flutter/services.dart';
import 'package:spell_check_on_client/spell_check_on_client.dart';

// Basic spell check implementation
class SpellChecker {
  static SpellCheck? spellCheck;

  static void initSpellCheck() async {
    String language = 'en';
    String content = await rootBundle.loadString(
      'assets/${language}_words.txt',
    );
    spellCheck = SpellCheck.fromWordsContent(
      content,
      letters: LanguageLetters.getLanguageForLanguage(language),
    );
  }

  static List<String> correctText(List<String> text) {
    if (spellCheck == null) {
      initSpellCheck();
      return text;
    }

    List<String> correctedText = [];
    for (var word in text) {
      String correction = spellCheck!.didYouMeanWord(word);
      if (correction.isNotEmpty) {
        correctedText.add(correction);
      } else {
        correctedText.add(word);
      }
    }
    return correctedText;
  }
}
