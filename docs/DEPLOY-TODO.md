# Deploy Directions

Directions of what to do when pushing a new version.

### Update Version Numbers

Locations:

1. pubspec.yaml
2. lib/constants.dart
3. linux/metadata/app.vup.Chat.metainfo.xml

### Deploy Website

Run: `./deploy.sh`

### Publish New Flathub Version

Go to [flathub github](github.com/flathub/app.vup.Chat). Bump release version in build script `app.vup.Chat.yaml` and update checksum.
