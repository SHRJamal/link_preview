import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../models/media.dart';

class LinkMediaWidget extends StatefulWidget {
  final LinkMedia media;
  final double height;
  final double width;
  final BoxFit fit;
  const LinkMediaWidget({
    Key key,
    @required this.media,
    this.height,
    this.width,
    this.fit,
  }) : super(key: key);

  @override
  _LinkMediaWidgetState createState() => _LinkMediaWidgetState();
}

class _LinkMediaWidgetState extends State<LinkMediaWidget> {
  @override
  void initState() {
    super.initState();
  }

  var hasError = false;
  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: widget.media.url,
      fit: widget.fit ?? BoxFit.cover,
      height: hasError ? 0 : widget.height,
      width: hasError ? 0 : widget.width,
      errorWidget: (_, __, ___) {
        if (!hasError) {
          Future.delayed(Duration(milliseconds: 200)).then((_) {
            setState(() {
              hasError = true;
            });
          });
        }
        return const SizedBox();
      },
    );
  }
}
