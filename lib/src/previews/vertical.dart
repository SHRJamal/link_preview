import 'package:flutter/material.dart';
import '../models/link_info.dart';
import 'widgets/header.dart';
import 'widgets/media.dart';

class VerticalPreview extends StatelessWidget {
  final LinkInfo info;

  const VerticalPreview({Key key, @required this.info}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final title = info?.title ?? '';
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        LinkMediaWidget(
          media: info?.media,
          width: double.maxFinite,
          height: 200,
        ),
        LinkHeader(title: title, icon: info?.icon ?? ''),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 2),
          child: Text(
            info?.description ?? '',
            maxLines: 5,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.caption.copyWith(fontSize: 13),
          ),
        ),
        Text(
          (info?.domain ?? '').toUpperCase(),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: theme.textTheme.caption,
        ),
      ],
    );
  }
}
