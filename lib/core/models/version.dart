class Version {
  final int major;
  final int minor;
  final int patch;

  const Version({
    this.major = 0,
    this.minor = 0,
    this.patch = 0,
  });

  factory Version.fromString(String fullVersion) {
    final splitVersion = fullVersion.split('.');
    return Version(
      major: int.parse(splitVersion[0]),
      minor: int.parse(splitVersion[1]),
      patch: int.parse(splitVersion[2]),
    );
  }

  @override
  String toString() {
    return "$major.$minor.$patch";
  }
}


class QoxariaVersion {
  final Version minecraft;
  final Version forge;
  final String modpack;

  const QoxariaVersion({
    required this.minecraft,
    required this.forge,
    required this.modpack,
  });

  factory QoxariaVersion.fromJson(Map<String, dynamic> json) {
    return switch(json) {
      {
        'minecraft': String minecraft,
        'forge': String forge,
        'modpack': String modpack,
      } =>
        QoxariaVersion(
          minecraft: Version.fromString(minecraft),
          forge: Version.fromString(forge),
          modpack: modpack
        ),
      _ => throw const FormatException('Failed to load version.'),
    };
  }
}
