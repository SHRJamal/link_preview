import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

class LinkHeader extends StatelessWidget {
  final String icon;
  final String title;

  const LinkHeader({
    Key key,
    this.icon = "",
    this.title = "",
  }) : super(key: key);
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return title?.isNotEmpty == true
        ? Padding(
            padding: const EdgeInsets.symmetric(vertical: 2),
            child: Row(
              children: [
                CachedNetworkImage(
                  imageUrl: icon,
                  fit: BoxFit.contain,
                  width: 30,
                  height: 30,
                  errorWidget: (_, error, stackTrace) =>
                      Icon(Icons.link, size: 30, color: theme.primaryColor),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.subtitle2
                        .copyWith(color: theme.primaryColor),
                  ),
                ),
              ],
            ),
          )
        : const SizedBox();
  }
}
