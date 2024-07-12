import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class TextInputPage extends StatefulWidget {
  final String title;

  const TextInputPage({super.key, required this.title});

  @override
  State<TextInputPage> createState() => _TextInputPageState();
}

class _TextInputPageState extends State<TextInputPage> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GestureDetector(
        onTap: () {
          Navigator.pop(context);
        },
        child: Container(
          color: Theme.of(context).shadowColor.withOpacity(0.5),
          child: Center(
            child: GestureDetector(
              onTap: () {
                // Do nothing to prevent pop when tapping the box
              },
              child: Container(
                width: 100.w,
                height: 100.h,
                decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    borderRadius: BorderRadius.all(Radius.circular(10.h))),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      widget.title,
                      style: const TextStyle(fontSize: 20),
                    ),
                    Center(
                      child: Padding(
                        padding: EdgeInsets.all(8.h),
                        child: TextField(
                          controller: _controller,
                          decoration: InputDecoration(
                            filled: true,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.h),
                              borderSide: BorderSide(
                                width: 1.h,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(20.h),
                              borderSide: BorderSide(
                                width: 1.h,
                              ),
                            ),
                            hintText: 'Input Text...',
                          ),
                        ),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            child: const Text("Cancel")),
                        ElevatedButton(
                            onPressed: () {
                              Navigator.pop(context, _controller.text);
                            },
                            child: const Text("Enter"))
                      ],
                    )
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
