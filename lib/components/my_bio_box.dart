/*

USER BIO BOX

This is a simple box with text inside. We will use this for the user bio
on their profile.
------------------------------------------------------------------------------------
To user this widget - You just need text

*/

import 'package:flutter/material.dart';

class MyBioBox extends StatelessWidget {
  const MyBioBox({super.key, required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25),
        color: Theme.of(context).colorScheme.secondary,
      ),
      margin: const EdgeInsets.symmetric(horizontal: 25),
      padding: const EdgeInsets.all(25),
      child: Text(
        text.isNotEmpty ? text : 'Empty bio...',
        style: TextStyle(
          color: Theme.of(context).colorScheme.inversePrimary,
        ),
      ),
    );
  }
}
