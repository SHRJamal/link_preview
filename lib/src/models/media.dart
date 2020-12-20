import 'dart:convert';

class LinkMedia {
  final String url;
  final MediaType type;

  LinkMedia(this.url, this.type);

  factory LinkMedia.create(String url, MediaType type) =>
      url?.isNotEmpty == true ? LinkMedia(url, type) : null;

  bool get isImage => [MediaType.image, MediaType.gif].contains(type);
  bool get isVideo => type == MediaType.video;

  String toJson() => json.encode({
        'url': url,
        'type': _typeToString(type),
      });

  factory LinkMedia.fromJson(String source) {
    final map = json.decode(source);
    return LinkMedia(
      map['url'] ?? '',
      _typeFromString(map['type']),
    );
  }
}

enum MediaType { image, gif, video }

MediaType _typeFromString(String str) {
  if (str == 'image') return MediaType.image;
  if (str == 'gif') return MediaType.gif;
  return MediaType.video;
}

String _typeToString(MediaType type) {
  if (type == MediaType.image) return "image";
  if (type == MediaType.gif) return "gif";
  return "video";
}
