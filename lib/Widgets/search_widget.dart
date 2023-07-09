import 'package:agritungotest/Helper/Color.dart';
import 'package:flutter/material.dart';

import '../Helper/Constant.dart';
import '../Helper/Session.dart';

class SearchWidget extends StatefulWidget {
  final String text;
  final ValueChanged<String> onChanged;
  final String hintText;

  const SearchWidget({
    Key? key,
    required this.text,
    required this.onChanged,
    required this.hintText,
  }) : super(key: key);

  @override
  _SearchWidgetState createState() => _SearchWidgetState();
}

class _SearchWidgetState extends State<SearchWidget> {
  final controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final styleActive = TextStyle(color: Colors.black);
    final styleHint = TextStyle(color: Colors.black54);
    final style = widget.text.isEmpty ? styleHint : styleActive;

    return Container(
      decoration: BoxDecoration(
          borderRadius:
          BorderRadius.circular(circularBorderRadius10)),
      height: 44,
      child: TextField(
        controller: controller,
        onChanged: widget.onChanged,
        autofocus: false,
        enabled: true,
        textAlign: TextAlign.left,
        decoration: InputDecoration(
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(
                color:
                Theme
                    .of(context)
                    .colorScheme
                    .lightWhite),
            borderRadius: const BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          enabledBorder: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          contentPadding:
          const EdgeInsets.fromLTRB(15.0, 5.0, 0, 5.0),
          border: const OutlineInputBorder(
            borderSide: BorderSide(color: Colors.transparent),
            borderRadius: BorderRadius.all(
              Radius.circular(10.0),
            ),
          ),
          fillColor: Theme
              .of(context)
              .colorScheme
              .lightWhite,
          filled: true,
          isDense: true,
          hintText: getTranslated(context, 'searchCropHint'),
          hintStyle: Theme
              .of(context)
              .textTheme
              .bodyText2!
              .copyWith(
            color:
            Theme
                .of(context)
                .colorScheme
                .fontColor,
            fontSize: textFontSize12,
            fontWeight: FontWeight.w400,
            fontStyle: FontStyle.normal,
          ),
          prefixIcon: const Padding(
              padding: EdgeInsets.all(15.0),
              child: Icon(Icons.search)),
          suffixIcon: widget.text.isNotEmpty
              ? GestureDetector(
            child: Icon(Icons.close, color: style.color),
            onTap: () {
              controller.clear();
              widget.onChanged('');
              FocusScope.of(context).requestFocus(FocusNode());
            },
          )
              : null,
        ),
      ),
    );
  }
}
