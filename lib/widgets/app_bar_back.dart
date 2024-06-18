import 'package:flutter/material.dart';
import 'package:vup_chat/functions/general.dart';

Widget backButton(BuildContext context) {
  return (!isDesktop())
      ? IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pop(context);
          },
        )
      : Container();
}
