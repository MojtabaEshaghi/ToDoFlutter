import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:todo_list/generated/assets.dart';
import 'package:todo_list/main.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          Assets.assetsEmptyState,
          width: 120,
        ),
        SizedBox(
          height: 14,
        ),
        Text("Your Task is Empty")
      ],
    );
  }
}

class MyCheckBox extends StatelessWidget {
  const MyCheckBox({Key? key, required this.value, required this.onTap})
      : super(key: key);
  final bool value;
  final GestureTapCallback onTap;

  @override
  Widget build(BuildContext context) {
    final ThemeData themeData = Theme.of(context);
    return InkWell(
      onTap: onTap,
      child: Container(
          width: 20,
          height: 20,
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: !value
                  ? Border.all(color: secondaryTextColor, width: 2)
                  : null,
              color: value ? primaryColor : null),
          child: value
              ? Icon(
            CupertinoIcons.check_mark,
            color: themeData.colorScheme.onPrimary,
            size: 14,
          )
              : null),
    );
  }
}
