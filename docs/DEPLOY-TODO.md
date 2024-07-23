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

### Publish New Fdroid Version

In [Fdroid Data](https://gitlab.com/lukehmcc/fdroid-data) repo. Add new line like so:

```
- versionName: 0.5.15
    versionCode: 1
    commit: v0.5.15
    submodules: true
    ...
```

And remember to update the latest version at the bottom.
