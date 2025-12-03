import 'package:flutter/material.dart';

AppBar buildAppBar({
  required BuildContext context,
  required String title,
  List<Widget>? actions,
  Color? backgroundColor,
}) {
  final bool showBack = Navigator.canPop(context);

  return AppBar(
    leading: showBack
        ? IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).maybePop(),
          )
        : null,
    title: Text(title),
    centerTitle: true,
    backgroundColor: backgroundColor ?? Colors.deepPurple,
    actions: actions,
    elevation: 2,
  );
}
