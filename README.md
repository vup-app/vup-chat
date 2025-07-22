> ⚠️ This app is now deprecated and is not maintained. However, the core of it still lives on in the [s5_messenger](https://github.com/s5-dev/s5_messenger) package. This allows anyone to use this messaging protocol to handle inter-app communication in a decentralized & private manner. An example app using this tech is [luogo](https://github.com/lukehmcc/luogo). To see the more finished state of this app, check out the [rust branch](https://github.com/vup-app/vup-chat/tree/rust).

# Vup Chat

A cross-platform, ATProto & S5 powered chat client.

![Flathub Version](https://img.shields.io/flathub/v/app.vup.VupChat)
![Flathub Downloads](https://img.shields.io/flathub/downloads/app.vup.VupChat)
![GitHub License](https://img.shields.io/github/license/vup-app/vup-chat)

![](static/UI.png)

### What

Vup Chat is a messaging client build on top of the [AT Protocol](https://atproto.com/). It both provides dedicated messaging clients for cross-platform usage. By utilizing the S5 network, it allows users to have more advanced features like E2EE and media embeds (coming soon).

### Usage

> ⚠️ This app is still in rapid development, so things are likely to change and break. All messages are currently backed up to ATProto. Once E2EE is implemented, the DB will become stable and breaking changes will not be pushed on minor (x.X.x) versions.

| Supported Platforms |                                                                                                               |
| ------------------- | ------------------------------------------------------------------------------------------------------------- |
| Android             | [releases](https://github.com/vup-app/vup-chat/releases)                                                      |
| iOS                 | 🗙                                                                                                             |
| Macos               | 🗙                                                                                                             |
| Linux               | [releases](https://github.com/vup-app/vup-chat/releases), [flathub](https://flathub.org/apps/app.vup.VupChat) |
| Windows             | 🗙                                                                                                             |
| Web                 | [releases](https://github.com/vup-app/vup-chat/releases), [dev site](https://vup-chat.jptr.tech)              |

> iOS, MacOS, & Windows are theoretically supported, but have not been tested and are not currently being distributed. PR's welcome :)

```bash
# Prerec, install flutter (https://flutter.dev/)
git clone https://github.com/vup-app/vup-chat.git
cd vup-chat
flutter pub get
flutter build your-platform-command
```

### TODO:

- [x] Basic bsky compatibility
- [x] Move backend to messaging service w/ local sqlite db
- [ ] E2EE messaging over S5 streams
- [ ] Other data over S5 network (images, videos, voice memos)
- [ ] Regular backups of sqlite DB to S5

### Acknowledgement

This work is supported by a [Sia Foundation](https://sia.tech/) grant
