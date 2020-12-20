import 'package:flutter/material.dart';
import '../link_preview.dart';
import 'data/analyzer.dart';
import 'helpers/utils.dart';
import 'models/link_info.dart';
import 'previews/horizontal.dart';
import 'previews/vertical.dart';
import 'previews/widgets/link_text.dart';

/// Link Preview Widget
class LinkPreview extends StatefulWidget {
  /// Web address, HTTP and HTTPS support
  final String text;

  /// Customized rendering methods
  final Widget Function(LinkInfo info) builder;

  final bool showLink;

  final LinkDirection linkDirection;

  const LinkPreview({
    Key key,
    @required this.text,
    this.builder,
    this.showLink = true,
    this.linkDirection = LinkDirection.horizontal,
  }) : super(key: key);

  @override
  _LinkPreviewState createState() => _LinkPreviewState();
}

class _LinkPreviewState extends State<LinkPreview> {
  LinkInfo _info;
  var isLoading = true;
  @override
  void initState() {
    init();
    super.initState();
  }

  void init() async {
    try {
      _info = await WebAnalyzerRepo.getInfo(widget.text);
    } catch (e) {
      print(e);
    }
    isLoading = false;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return LinearProgressIndicator();
    if (_info == null) return const SizedBox();
    if (widget.builder != null) return widget.builder(_info);
    final theme = Theme.of(context);
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: theme.accentColor.withAlpha(50),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (widget.showLink ?? true)
            LinkifyText(
              widget.text,
              textColor: Colors.black,
            ),
          SizedBox(height: 8),
          GestureDetector(
            child: widget.linkDirection == LinkDirection.vertical ||
                    LinkUtils.isEmpty(_info.title)
                ? VerticalPreview(info: _info)
                : HorizontalPreview(info: _info),
            onTap: () => LinkUtils.launchURL(_info.link),
          )
        ],
      ),
    );
  }
}

enum LinkDirection { horizontal, vertical }
