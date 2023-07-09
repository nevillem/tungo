import 'package:agritungotest/Helper/Color.dart';
import 'package:flutter/material.dart';

import '../Helper/Constant.dart';
class AnimalContainer extends StatelessWidget {
  final String stallno,gender, breed, litres, pregancyStatus;
  final VoidCallback pressDelete;
  final VoidCallback press;
  final String imageUrl;

  const AnimalContainer({Key? key, required this.stallno,
    required this.gender, required this.breed, required this.litres,
    required this.pregancyStatus, required this.press, required this.pressDelete, required this.imageUrl
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    String capitalize(String s) => s[0].toUpperCase() + s.substring(1);
    return Container(
      margin: const EdgeInsets.symmetric(
        //horizontal: 20.0,
        vertical:5,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.white,
        borderRadius: BorderRadius.circular(5.0),
        // boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.5), spreadRadius: 5, blurRadius: 7,
        //   offset: Offset(0, 3), // changes position of shadow
        // )],
      ),
      padding: EdgeInsets.only(top: 10,right: 20.0,left: 10.0,bottom: 10.0),
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              // mainAxisAlignment: MainAxisAlignment.start,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text("TAG No: $stallno",
                      style: Theme.of(context)
                          .textTheme.titleLarge!
                          .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14),
                      textAlign: TextAlign.left,
                    ),
                    Container(
                      alignment: Alignment.bottomRight,
                      child: Text(
                        gender,
                        style: Theme.of(context)
                            .textTheme.titleLarge!
                            .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14),
                        textAlign: TextAlign.left,
                      ),
                    ),
                  ],
                ),
                const Divider(color: Colors.black12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Row(
                          children: [
                             Text("Breed:",
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Color(0xFF737373),
                                fontSize: 12.0,
                              ),
                              textAlign: TextAlign.left,
                            ),
                            const SizedBox(width: 5,),
                            Text(breed,
                                style: Theme.of(context)
                                    .textTheme.titleLarge!
                                    .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14)

                            ),
                          ],
                        ),

                         gender=="female"?Row(
                          children: [
                             const Text("Litres Per day:",
                               style: TextStyle(
                                 fontWeight: FontWeight.bold,
                                 color: Color(0xFF737373),
                                 fontSize: 12.0,
                               ),
                               textAlign: TextAlign.left,
                            ),
                            SizedBox(width: 5,),
                            Text(litres,
                                style: Theme.of(context)
                                    .textTheme.titleLarge!
                                    .copyWith(color: Theme.of(context).colorScheme.fontColor, fontSize: textFontSize14),
                            )
                          ],
                        ):Text(""),
                      ],
                    ),
                    Container(
                      width:50,
                      height: 50,
                      decoration: BoxDecoration(
                        border: Border.all(width: 1, color:Color(0XFFC2C1C1)),
                        borderRadius: BorderRadius.circular(4), //<-- SEE HERE
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(4.0),
                        child: FadeInImage(placeholder: AssetImage("assets/images/cow.png"), image: NetworkImage(imageUrl),),
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    gender=="female"? Text("Pregnancy status: " ,
                      style: TextStyle(
                          color: Color(0xFF737373),
                          fontSize: 12.0,
                          fontWeight: FontWeight.bold
                      ),
                    ):Text(""),
                    gender=="female"? pregancyStatus=="pregnant"?Container(
                      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                      decoration: BoxDecoration(color: Color(0xFF73B41A),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(
                        capitalize(pregancyStatus.toLowerCase()),
                        style: const TextStyle(
                          color: Color(0xFFFFFFFF),
                          fontSize: 12.0,
                        ),
                      ),
                    ):Container(
                      padding: EdgeInsets.fromLTRB(20, 5, 20, 5),
                      decoration: BoxDecoration(color: Color(0xFFF9C404),
                          borderRadius: BorderRadius.circular(20)
                      ),
                      child: Text(
                        capitalize(pregancyStatus.toLowerCase()),
                        style: const TextStyle(
                          //backgroundColor: Color(0xFFF9C404),
                          color: Color(0xFFFFFFFF),
                          fontSize: 12.0,
                        ),
                      ),
                    ):Container(),

                    Container(
                      margin: EdgeInsets.only(left:30),
                      // child: GestureDetector(
                      //   onTap: press,
                      //   child: const Text("Edit",
                      //     style: TextStyle(
                      //       //backgroundColor: Color(0xFFF9C404),
                      //       color: Color(0xFF73B41A),
                      //       fontSize: 12.0,
                      //       fontWeight: FontWeight.w800,
                      //     ),
                      //   ),
                      // ),
                    ),
                    Container(
                      margin: EdgeInsets.only(left:5, right: 0),
                      child: GestureDetector(
                        onTap: pressDelete,
                        child: const Text("Delete",
                          style: TextStyle(
                            //backgroundColor: Color(0xFFF9C404),
                            color: Color(0xFFF00000),
                            fontSize: 12.0,
                            fontWeight: FontWeight.w800,
                          ),

                        ),
                      ),
                    )
                  ],
                ),

              ],
            ),
          ),
        ],
      ),
    );
  }
}
