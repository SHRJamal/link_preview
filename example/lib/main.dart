import 'package:flutter/material.dart';
import 'package:link_preview/link_preview.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MaterialApp(
    title: 'Link Preview Demo',
    home: App(),
  ));
}

class App extends StatefulWidget {
  const App({Key key}) : super(key: key);

  @override
  _AppState createState() => _AppState();
}

class _AppState extends State<App> {
  TextEditingController _controller;
  int _index = 0;

  @override
  void initState() {
    _controller = TextEditingController(text: links[0]);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              TextField(controller: _controller),
              Row(
                children: <Widget>[
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_left_sharp,
                      size: 40,
                    ),
                    onPressed: _index <= 0
                        ? null
                        : () {
                            _index--;
                            _controller.text = links[_index];
                            if (mounted) setState(() {});
                          },
                  ),
                  IconButton(
                    icon: const Icon(
                      Icons.arrow_right_sharp,
                      size: 40,
                    ),
                    onPressed: _index >= links.length - 1
                        ? null
                        : () {
                            _index++;
                            _controller.text = links[_index];
                            if (mounted) setState(() {});
                          },
                  ),
                  Spacer(),
                  IconButton(
                    icon: const Icon(
                      Icons.refresh,
                      size: 40,
                    ),
                    onPressed: () {
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: 15),
                  IconButton(
                    icon: const Icon(
                      Icons.close,
                      size: 40,
                    ),
                    onPressed: () {
                      _controller.clear();
                      setState(() {});
                    },
                  ),
                ],
              ),
              const SizedBox(height: 15),
              LinkPreview(
                key: UniqueKey(),
                text: _controller.value.text,
                linkDirection: LinkDirection.horizontal,
                showLink: true,
                builder: (info) {
                  return Container(
                    padding: EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(8),
                      color: theme.accentColor.withAlpha(50),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: <Widget>[
                            Image.network(
                              info.media.url,
                              fit: BoxFit.cover,
                              height: 200,
                              width: double.maxFinite,
                            ),
                            Text(
                              info.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 2),
                              child: Text(
                                info?.description ?? '',
                                maxLines: 5,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              (info?.domain ?? '').toUpperCase(),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ],
                        )
                      ],
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

final links = [
  "http://pub.dev",
  "https://www.youtube.com",
  "http://flutter.dev",
  "https://blog.codemagic.io/uploads/2020/04/codemagic-blog-flutter-tutorial-architect-your-app-using-provider-and-stream-.png",
  "https://www.bilibili.com/video/BV1F64y1c7hd?spm_id_from=333.851.b_7265706f7274466972737431.12",
  "https://mp.weixin.qq.com/s/qj7gkU-Pbdcdn3zO6ZQxqg",
  "https://mp.weixin.qq.com/s/43GznPLxi5i3yOdvrlr1JQ",
];
