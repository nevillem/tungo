import '../Helper/String.dart';
import 'Section_Model.dart';
import 'package:intl/intl.dart';


class Model {
  String? id,
      type,
      typeId,
      image,
      icon,
      fromTime,
      lastTime,
      title,
      desc,
      status,
      email,
      date,
      msg,
      uid,
      prodId,
      varId;
  bool? isDel;
  var list;
  String? name, banner;
  List<attachment>? attach;
  Model(
      {this.id,
        this.type,
        this.typeId,
        this.image,
        this.icon,
        this.name,
        this.banner,
        this.list,
        this.title,
        this.fromTime,
        this.desc,
        this.email,
        this.status,
        this.lastTime,
        this.msg,
        this.attach,
        this.uid,
        this.date,
        this.prodId,
        this.isDel,
        this.varId
      });

  factory Model.fromSlider(Map<String, dynamic> parsedJson) {
    // var listContent = parsedJson['data'];
    // if (listContent.isEmpty) {
    //   listContent = [];
    // } else {
    //   listContent = listContent[0];
    //   if (parsedJson[TYPE] == 'categories') {
    //     listContent = Product.fromCat(listContent);
    //   } else if (parsedJson[TYPE] == 'products') {
    //     listContent = Product.fromJson(listContent);
    //   }
    // }
    String date = parsedJson[DATE_CREATED];
    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    return Model(
        id: parsedJson[ID],
        name: parsedJson[NAME],
        image: parsedJson[IMAGE],
        icon: parsedJson[ICON],
        desc: parsedJson[DESC],
        typeId: parsedJson[TYPE_ID],
        date:date,
        // list: listContent
    );

  }

  factory Model.fromTimeSlot(Map<String, dynamic> parsedJson) {
    return Model(
        id: parsedJson[ID],
        name: parsedJson[TITLE],
        fromTime: parsedJson[FROMTIME],
        lastTime: parsedJson[TOTIME]);
  }

  factory Model.fromTicket(Map<String, dynamic> parsedJson) {
    String date = parsedJson[DATE_CREATED];
    date = DateFormat('dd-MM-yyyy').format(DateTime.parse(date));
    return Model(
        id: parsedJson[ID],
        title: parsedJson[SUB],
        desc: parsedJson[DESC],
        typeId: parsedJson[TICKET_TYPE],
        email: parsedJson[EMAIL],
        status: parsedJson[STATUS],
        date: date,
        type: parsedJson[TIC_TYPE]);
  }

  factory Model.fromSupport(Map<String, dynamic> parsedJson) {
    return Model(
      id: parsedJson[ID],
      title: parsedJson[TITLE],
    );
  }

  factory Model.fromChat(Map<String, dynamic> parsedJson) {
    //var listContent = parsedJson["attachments"];

    List<attachment> attachList = [];
    var listContent = (parsedJson['attachments'] as List?);
    if (listContent!.isEmpty) {
      attachList = [];
    } else {
      attachList =
          listContent.map((data) => attachment.setJson(data)).toList();
    }

    String date = parsedJson[DATE_CREATED];

    date = DateFormat('dd-MM-yyyy hh:mm a').format(DateTime.parse(date));
    return Model(
        id: parsedJson[ID],
        title: parsedJson[TITLE],
        msg: parsedJson[MESSAGE],
        uid: parsedJson[USER_ID],
        name: parsedJson[NAME],
        date: date,
        attach: attachList);
  }

  factory Model.setAllCat(String id, String name) {
    return Model(
      id: id,
      name: name,
    );
  }

  factory Model.checkDeliverable(Map<String, dynamic> parsedJson) {
    return Model(
        prodId: parsedJson[PRODUCT_ID],
        varId: parsedJson[VARIANT_ID],
        isDel: parsedJson[IS_DELIVERABLE]);
  }
}

class attachment {
  String? media, type;

  attachment({this.media, this.type});

  factory attachment.setJson(Map<String, dynamic> parsedJson) {
    return attachment(
      media: parsedJson[MEDIA],
      type: parsedJson[ICON],
    );
  }
}
