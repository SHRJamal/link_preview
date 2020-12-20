import 'dart:convert';

import 'media.dart';

class LinkInfo {
  final String link;
  final String title;
  final String icon;
  final String description;
  final LinkMedia media;
  final String domain;
  final String redirectUrl;

  LinkInfo({
    this.link,
    this.title,
    this.icon,
    this.description,
    this.media,
    this.domain,
    this.redirectUrl,
  });

  String toJson() => json.encode({
        'link': link,
        'title': title,
        'icon': icon,
        'description': description,
        'media': media?.toJson(),
        'domain': domain,
        'redirectUrl': redirectUrl,
      });

  factory LinkInfo.fromJson(String source) {
    if (source?.isNotEmpty != true) return null;
    final map = json.decode(source) as Map;
    if (map?.containsKey('link') != true) return null;
    return LinkInfo(
      link: map['link'] ?? '',
      title: map['title'] ?? '',
      icon: map['icon'] ?? '',
      description: map['description'] ?? '',
      media: LinkMedia.fromJson(map['media']),
      domain: map['domain'] ?? '',
      redirectUrl: map['redirectUrl'] ?? '',
    );
  }
}
