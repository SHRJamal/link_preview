# link_preview

URL preview package to previews the content of a URL

## Getting Started

```dart
LinkPreview(
  text: "https://pub.dev",
)
```

![Result Image](images/1.png)

```dart
LinkPreview(
  text: "https://youtube.com",
  linkDirection: LinkDirection.horizontal,
)
```

![Result Image](images/2.png)

## Custom Widget

```dart
LinkPreview(
  key: UniqueKey(),
  text: "flutter.dev",
  builder: (info) {
    // ... custom widget here and you have access to: title, icon, descriptio, media
  },
),
```
