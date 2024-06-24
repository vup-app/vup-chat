# Vup Chat

A cross-platform, ATProto & S5 powered chat client.

![](static/UI.png)

### Usage

Currently not published in app stores. The dev site is available [here](https://vup-chat.jptr.tech). Alternatively you can build the app yourself for any supported platform.

```bash
# Prerec, install flutter (https://flutter.dev/)
git clone https://github.com/vup-app/vup-chat.git
cd vup-chat
flutter pub get
flutter build exe --your-params
```

### TODO:

- [x] Basic bsky compatibility
- [x] Move backend to messaging service w/ local sqlite db
- [ ] E2EE messaging over S5 streams
- [ ] Other data over S5 network (images, videos, voice memos)
- [ ] Regular backups of sqlite DB to S5

### Acknowledgement

This work is supported by a [Sia Foundation](https://sia.tech/) grant
