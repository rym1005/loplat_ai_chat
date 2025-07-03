import 'package:flutter/material.dart';


class CommonLoading extends StatelessWidget {
  final String? _content;
  final Color backgroundColor;

  const CommonLoading({
    super.key,
    String? content,
    this.backgroundColor = Colors.black26,
  })  : _content = content;

  @override
  Widget build(BuildContext context) {
    final content = _content;
    if (content != null) {
      return Container(
        color: backgroundColor,
        alignment: Alignment.center,
        child: Container(
          decoration: BoxDecoration(color: Color(0xFF2F2F2F), borderRadius: BorderRadius.circular(5)),
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(color: Color(0xFF73abe2)),
              const SizedBox(height: 24),
              DefaultTextStyle(
                style: const TextStyle(fontSize: 14, color: Color(0xFFFFFFFF)),
                child: Text(content),
              ),
            ],
          ),
        ),
      );
    } else {
      return Container(
        color: backgroundColor,
        alignment: Alignment.center,
        child: const CircularProgressIndicator(color:  Color(0xFF73abe2)),
      );
    }
  }
}
