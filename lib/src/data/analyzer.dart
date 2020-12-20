import 'dart:convert';
import 'dart:io';

import 'package:gbk2utf8/gbk2utf8.dart';
import 'package:html/dom.dart' hide Text;
import 'package:html/parser.dart' as parser;
import 'package:http/http.dart';
import 'package:http/io_client.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../helpers/reg_exp.dart';
import '../helpers/utils.dart';
import '../models/link_info.dart';
import '../models/media.dart';

/// Web analyzer
mixin WebAnalyzerRepo {
  static Future<LinkInfo> getInfo(String text) async {
    final url = LinkUtils.getValidLink(text);

    if (url.isEmpty) {
      print('-- LinkPreviewer: Invalid Link');
      return null;
    }

    LinkInfo res;
    try {
      final prefs = await SharedPreferences.getInstance();
      res = LinkInfo.fromJson(prefs.getString(url));
      if (res != null) return res;
      final response = await _requestUrl(url, useDesktopAgent: false);
      if (response == null) return null;
      print("$url ${response.statusCode}");

      res = await _getWebInfo(response, url);
      prefs.setString(url, res.toJson());
    } catch (e) {
      print("Get web error:$url, Error:$e");
    }

    return res;
  }

  static Future<Response> _requestUrl(
    String url, {
    int count = 0,
    String cookie,
    bool useDesktopAgent = true,
  }) async {
    Response res;
    final uri = Uri.parse(url);
    final client = IOClient(HttpClient());
    final request = Request('GET', uri)
      ..followRedirects = false
      ..headers["User-Agent"] = useDesktopAgent
          ? "Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_6) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/84.0.4147.125 Safari/537.36"
          : "Mozilla/5.0 (iPhone; CPU iPhone OS 13_2_3 like Mac OS X) AppleWebKit/605.1.15 (KHTML, like Gecko) Version/13.0.3 Mobile/15E148 Safari/604.1"
      ..headers["cache-control"] = "no-cache"
      ..headers["accept"] = "*/*";
    final stream = await client.send(request);

    if (stream.statusCode == HttpStatus.movedTemporarily ||
        stream.statusCode == HttpStatus.movedPermanently) {
      if (stream.isRedirect && count < 6) {
        final location = stream.headers['location'];
        if (location != null) {
          url = location;
          if (location.startsWith("/")) {
            url = uri.origin + location;
          }
        }
        if (stream.headers['set-cookie'] != null) {
          cookie = stream.headers['set-cookie'];
        }
        count++;
        client.close();
        return _requestUrl(url, count: count, cookie: cookie);
      }
    } else if (stream.statusCode == HttpStatus.ok) {
      res = await Response.fromStream(stream);
    }
    client.close();
    if (res == null) print("Get web info empty($url)");
    return res;
  }

  static Future<LinkInfo> _getWebInfo(Response response, String url) async {
    if (response.statusCode == HttpStatus.ok) {
      final contentType = response.headers["content-type"] ?? '';

      final uri = Uri.parse(url);
      final domain =
          uri.authority.split('.').reversed.take(2).toList().reversed.join('.');

      if (contentType.contains("image/")) {
        return LinkInfo(
          link: url,
          domain: domain,
          media: LinkMedia.create(url, MediaType.image),
        );
      } else if (contentType.contains("video/")) {
        return LinkInfo(
          link: url,
          domain: domain,
          media: LinkMedia.create(url, MediaType.video),
        );
      } else {
        String html;
        try {
          html = const Utf8Decoder().convert(response.bodyBytes);
        } catch (e) {
          try {
            html = gbk.decode(response.bodyBytes);
          } catch (e) {
            print("Web page resolution failure from:$url Error:$e");
          }
        }

        if (html == null) {
          print("Web page resolution failure from:$url");
          return null;
        }

        final headHtml = _getHeadHtml(html);
        final document = parser.parse(headHtml);

        return LinkInfo(
          link: url,
          domain: domain,
          title: _analyzeTitle(document, domain),
          icon: _analyzeIcon(document, uri),
          description:
              _analyzeDescription(document, html)?.replaceAll(r"\x0a", " "),
          media: LinkMedia.create(
                  _analyzeImage(document, uri), MediaType.image) ??
              LinkMedia.create(_analyzeGif(document, uri), MediaType.gif) ??
              LinkMedia.create(_analyzeVideo(document, uri), MediaType.video),
          redirectUrl: response.request.url.toString(),
        );
      }
    }
    return null;
  }

  static String _getHeadHtml(String html) {
    html = html.replaceFirst(LinkRegExp.bodyReg, "<body></body>");
    final matchs = LinkRegExp.metaReg.allMatches(html);
    final head = StringBuffer("<html><head>");
    if (matchs != null) {
      for (final e in matchs) {
        final str = e.group(0);
        if (str.contains(LinkRegExp.titleReg)) head.writeln(str);
      }
    }
    head.writeln("</head></html>");
    return head.toString();
  }

  static String _analyzeGif(Document document, Uri uri) {
    var _url = '';
    if (_getMetaContent(document, "property", "og:image:type") == "image/gif") {
      final gif = _getMetaContent(document, "property", "og:image");
      _url = _handleUrl(uri, gif);
    }
    return _url;
  }

  static String _analyzeVideo(Document document, Uri uri) {
    var _url = '';

    final video = _getMetaContent(document, "property", "og:video");

    if (video != null) _url = _handleUrl(uri, video);
    return _url;
  }

  static String _getMetaContent(
      Document document, String property, String propertyValue) {
    final meta = document.head.getElementsByTagName("meta");
    final ele = meta.firstWhere((e) => e.attributes[property] == propertyValue,
        orElse: () => null);
    if (ele != null) return ele.attributes["content"]?.trim();
    return null;
  }

  static String _analyzeTitle(Document document, String domain) {
    final title = _getMetaContent(document, "property", "og:title") ?? '';
    if (title.isNotEmpty) return title;
    final list = document.head.getElementsByTagName("title");
    for (var e in list) {
      final tagTitle = e.text?.trim() ?? '';
      if (tagTitle.isNotEmpty) return tagTitle;
    }
    return domain.split('.').first;
  }

  static String _analyzeDescription(Document document, String html) {
    final desc = _getMetaContent(document, "property", "og:description");
    if (desc != null) return desc;

    final description = _getMetaContent(document, "name", "description") ??
        _getMetaContent(document, "name", "Description");

    if (!LinkUtils.isNotEmpty(description)) {
      // final DateTime start = DateTime.now();
      var body = html.replaceAll(LinkRegExp.htmlReg, "");
      body = body
          .trim()
          .replaceAll(LinkRegExp.lineReg, " ")
          .replaceAll(LinkRegExp.spaceReg, " ");
      if (body.length > 300) {
        body = body.substring(0, 300);
      }
      // print("html cost ${DateTime.now().difference(start).inMilliseconds}");
      return body;
    }
    return description;
  }

  static String _analyzeIcon(Document document, Uri uri) {
    final meta = document.head.getElementsByTagName("link");
    var icon = "";
    // get icon first
    var metaIcon = meta.firstWhere((e) {
      final rel = (e.attributes["rel"] ?? "").toLowerCase();
      if (rel == "icon") {
        icon = e.attributes["href"];
        if (icon != null && !icon.toLowerCase().contains(".svg")) {
          return true;
        }
      }
      return false;
    }, orElse: () => null);

    metaIcon ??= meta.firstWhere((e) {
      final rel = (e.attributes["rel"] ?? "").toLowerCase();
      if (rel == "shortcut icon") {
        icon = e.attributes["href"];
        if (icon != null && !icon.toLowerCase().contains(".svg")) {
          return true;
        }
      }
      return false;
    }, orElse: () => null);

    if (metaIcon != null) {
      icon = metaIcon.attributes["href"];
    } else {
      return "${uri.origin}/favicon.ico";
    }

    return _handleUrl(uri, icon);
  }

  static String _analyzeImage(Document document, Uri uri) {
    final image = _getMetaContent(document, "property", "og:image");
    return _handleUrl(uri, image);
  }

  static String _handleUrl(Uri uri, String source) {
    var _url = source;
    if (LinkUtils.isEmpty(source)) {
      _url = uri.origin;
    } else if (source.startsWith("//")) {
      _url = "${uri.scheme}:$source";
    } else if (source.startsWith("/")) {
      _url = "${uri.origin}$source";
    } else if (!source.startsWith('http')) {
      _url = "${uri.origin}/$source";
    }
    return _url.replaceFirst(RegExp(r'http://'), 'https://');
  }
}
