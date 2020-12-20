import 'package:linkify/linkify.dart';
import 'package:url_launcher/url_launcher.dart';

import '../models/word.dart';

mixin LinkUtils {
  static bool isNotEmpty(String str) => str?.isNotEmpty == true;
  static bool isEmpty(String str) => str?.isNotEmpty != true;
  static bool isValidLink(String str) => linkify(str?.trim() ?? '').isNotEmpty;

  static String convertToHttps(String text) {
    if (text.startsWith('http://')) {
      return text.replaceFirst(RegExp(r'http://'), 'https://');
    }
    return text;
  }

  static List<Word> parseLink(String text) {
    final links = linkify(
      text,
      options: LinkifyOptions(
        humanize: false,
        defaultToHttps: true,
        looseUrl: true,
      ),
    );
    return [for (final e in links) Word(e.text)];
  }

  static String getValidLink(String text) {
    for (var w in parseLink(text)) {
      if (w.isLink) return w.text;
    }
    return '';
  }

  static void launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      print('LinkPreviewer: Cannot launch $url');
    }
  }
}
