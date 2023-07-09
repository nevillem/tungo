import 'package:agritungotest/Helper/Color.dart';
import 'package:agritungotest/Helper/Constant.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';

class Features extends StatelessWidget {
  final String svgSrc;
  final String title;
  final VoidCallback press;
  const Features({
    Key? key,
    required this.svgSrc,
    required this.title,
    required this.press,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: Card(
      color: Theme.of(context).colorScheme.white,
      elevation: 1.0,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: press,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                children: <Widget>[
                  Spacer(),
                  SvgPicture.asset(svgSrc, height: 75, width: 110,),
                  Spacer(),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize:textFontSize14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'opensans',
                        color: Theme.of(context).colorScheme.lightBlack,
                        // color: Colors.blue[600]
                    ),

                    // style: Theme.of(context)
                    //     .textTheme
                    //     .title
                    //     .copyWith(fontSize: 15),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}