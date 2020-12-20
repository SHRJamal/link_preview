import 'package:flutter/material.dart';
import '../models/link_info.dart';
import 'widgets/header.dart';
import 'widgets/media.dart';

class HorizontalPreview extends StatelessWidget {
  final LinkInfo info;

  const HorizontalPreview({Key key, @required this.info}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 150,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          LinkMediaWidget(
            media: info?.media,
            height: 150,
            width: 130,
            fit: BoxFit.fill,
          ),
          SizedBox(width: 4),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                LinkHeader(
                  title: info?.title ?? '',
                  icon: info?.icon ?? '',
                ),
                SizedBox(height: 2),
                if (info?.description?.isNotEmpty == true)
                  Expanded(
                    child: Text(
                      info.description,
                      maxLines: 5,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.caption.copyWith(fontSize: 13),
                    ),
                  ),
                SizedBox(height: 4),
                Text(
                  (info?.domain ?? '').toUpperCase(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.caption,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }
}
