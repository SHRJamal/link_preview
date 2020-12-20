import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import '../../helpers/utils.dart';
import '../../models/word.dart';

class LinkifyText extends StatefulWidget {
  final String text;
  final Color textColor;
  final double fontSize;
  final Color linkColor;
  final String fontFamily;
  final bool isLinkNavigationEnable;
  final FontWeight fontWeight;
  final FontStyle fontStyle;

  LinkifyText(
    this.text, {
    this.textColor,
    this.linkColor,
    this.fontSize,
    this.fontFamily,
    this.fontWeight,
    this.fontStyle,
    this.isLinkNavigationEnable = true,
  });

  @override
  _LinkifyTextState createState() => _LinkifyTextState();
}

class _LinkifyTextState extends State<LinkifyText> {
  var words = <Word>[];

  @override
  void initState() {
    super.initState();
    words = LinkUtils.parseLink(widget.text);
  }

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        children: [
          for (final w in words)
            w.isLink
                ? TextSpan(
                    text: w.text,
                    style: TextStyle(
                        fontSize: widget.fontSize,
                        fontFamily: widget.fontFamily,
                        fontWeight: widget.fontWeight ?? FontWeight.normal,
                        color: widget.linkColor ?? Colors.blue[700],
                        fontStyle: widget.fontStyle ?? FontStyle.normal,
                        decoration: TextDecoration.underline),
                    recognizer: TapGestureRecognizer()
                      ..onTap = () {
                        if (!widget.isLinkNavigationEnable) return;
                        LinkUtils.launchURL(w.text);
                      },
                  )
                : TextSpan(
                    text: w.text,
                    style: TextStyle(
                        fontSize: widget.fontSize ?? 15.0,
                        fontFamily: widget.fontFamily,
                        fontStyle: widget.fontStyle ?? FontStyle.normal,
                        fontWeight: widget.fontWeight ?? FontWeight.normal,
                        color: widget.textColor ?? Colors.white),
                  )
        ],
      ),
    );
  }
}
