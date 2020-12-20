mixin LinkRegExp {
  static final bodyReg = RegExp(
    r"<body[^>]*>([\s\S]*?)<\/body>",
    caseSensitive: false,
  );

  static final htmlReg = RegExp(
    r"(<head[^>]*>([\s\S]*?)<\/head>)|(<script[^>]*>([\s\S]*?)<\/script>)|(<style[^>]*>([\s\S]*?)<\/style>)|(<[^>]+>)|(<link[^>]*>([\s\S]*?)<\/link>)|(<[^>]+>)",
    caseSensitive: false,
  );

  static final metaReg = RegExp(
    r"<(meta|link)(.*?)\/?>|<title(.*?)</title>",
    caseSensitive: false,
    dotAll: true,
  );

  static final titleReg = RegExp(
    "(title|icon|description|image)",
    caseSensitive: false,
  );

  static final lineReg = RegExp(
    r"[\n\r]|&nbsp;|&gt;",
  );

  static final spaceReg = RegExp(
    r"\s+",
  );
}
