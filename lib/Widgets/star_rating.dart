// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import '../Helper/Color.dart';
import '../Helper/Constant.dart';

class StarRating extends StatelessWidget {
  String totalRating, noOfRatings;
  bool needToShowNoOfRatings;

  StarRating(
      {Key? key,
        required this.totalRating,
        required this.noOfRatings,
        required this.needToShowNoOfRatings})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return // Subtraction 1
      Row(
        children: [
          Container(
            width: 15,
            height: 15,
            decoration: BoxDecoration(
              gradient:  const LinearGradient(
                begin: Alignment(0, 0),
                end: Alignment(1, 1),
                colors: [
                  colors.grad1Color,
                  colors.grad2Color,
                ],
              ),
              borderRadius: BorderRadius.circular(3),
            ),
            child: const FittedBox(
              child: Icon(
                Icons.star,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(
            width: 5.0,
          ),
          Flexible(
            child: Text(
              totalRating,
            ),
          ),
          needToShowNoOfRatings
              ? const SizedBox(
            width: 5.0,
          )
              : Container(),
          needToShowNoOfRatings
              ? Flexible(
            child: Text(
              '($noOfRatings)',
              style: const TextStyle(
                fontSize: textFontSize10,
                fontWeight: FontWeight.w300,
                fontStyle: FontStyle.normal,
              ),
            ),
          )
              : Container(),
        ],
      );
  }
}
