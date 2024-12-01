import 'package:flutter/material.dart';

/*

  INPUT ALERT BOX

  This is an alert dialog box hat has a textfield where the user can type in. We will use this
  for things like editing bio, posting a new message, etc.
  ----------------------------------------------------------------------------------------------

  To use this widget, you need:

  - Text controller () ( to access what the user type ) 
  - hint text ( e.g. "empty bio" )
  - a function ( e.g. saveBio() )
  - text for button ( e.g. "Save")
*/

class MyInputAlertBox extends StatelessWidget {
  const MyInputAlertBox({
    super.key,
    required this.textController,
    required this.hintText,
    required this.onPressed,
    required this.onPressedText,
  });
  final TextEditingController textController;
  final String hintText;
  final void Function()? onPressed;
  final String onPressedText;

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: TextField(
        controller: textController,
        maxLength: 140,
        maxLines: 3,
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          fillColor: Theme.of(context).colorScheme.secondary,
          counterStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
          filled: true,
          // When textfield is unselected
          enabledBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.tertiary),
            borderRadius: BorderRadius.circular(12),
          ),
          // when text field is selected
          focusedBorder: OutlineInputBorder(
            borderSide:
                BorderSide(color: Theme.of(context).colorScheme.primary),
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(8),
        ),
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      actions: [
        // cancel button
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            textController.clear();
          },
          child: Text('Cancel'),
        ),

        // yes button

        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            onPressed!();
            textController.clear();
          },
          child: Text(onPressedText),
        ),
      ],
    );
  }
}
