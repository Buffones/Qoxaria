
import 'package:flutter/material.dart';
import 'package:qoxaria/core/models/version.dart';
import 'package:qoxaria/core/widgets/hover_text_widget.dart';


class VersionWidget extends StatelessWidget {
  final QoxariaVersion version;

  const VersionWidget({super.key, required this.version});

  @override
  Widget build(BuildContext context) {
    const style = TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: Colors.white,
      height: 1,
    );
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Minecraft:', style: style),
                  Text('Forge:', style: style),
                  Text('Modpack:', style: style.copyWith(fontSize: 14, height: 1.5)),
                ]
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(8.0),
                child: Column(children: [
                  Text(version.minecraft.toString(), style: style),
                  Text(version.forge.toString(), style: style),
                  HoverTextWidget(
                    visibleChild: Text(
                      version.modpack.substring(0, 7),
                      style: style.copyWith(fontSize: 14, height: 1.5),
                    ),
                    hoverChild: Text(
                      version.modpack,
                      style: style.copyWith(fontSize: 14, height: 1.5),
                    ),
                  ),
                ]),
              ),
          ]
        )
      ]
    );
  }
}
