import '../helpers/utils.dart';

class Word {
  final String text;
  final bool isLink;
  Word(String text)
      : text = LinkUtils.convertToHttps(text),
        isLink = text?.startsWith('http') == true;
}
