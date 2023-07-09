class CropData {
  String? name,id;
  String? type;
  String? image;
  List<Informationitems>? informationitems;
  List<Cropdiseases>? cropdiseases;
  List<Croppest>? croppest;

  CropData(
    {this.id,
      this.name,
      this.type,
      this.image,
      this.informationitems,
      this.cropdiseases,
      this.croppest});

  CropData.fromJson(Map<String, dynamic> json) {
id = json['id'];
name = json['name'];
type = json['type'];
image = json['image'];
if (json['informationitems'] != null) {
informationitems = <Informationitems>[];
json['informationitems'].forEach((v) {
informationitems?.add(new Informationitems.fromJson(v));
});
}
if (json['cropdiseases'] != null) {
cropdiseases = <Cropdiseases>[];
json['cropdiseases'].forEach((v) {
cropdiseases?.add(new Cropdiseases.fromJson(v));
});
}
if (json['croppest'] != null) {
croppest = <Croppest>[];
json['croppest'].forEach((v) {
croppest?.add(new Croppest.fromJson(v));
});
}
}

Map<String, dynamic> toJson() {
  final Map<String, dynamic> data = new Map<String, dynamic>();
  data['id'] = this.id;
  data['name'] = this.name;
  data['type'] = this.type;
  data['image'] = this.image;
  if (this.informationitems != null) {
    data['informationitems'] =
        this.informationitems?.map((v) => v.toJson()).toList();
  }
  if (this.cropdiseases != null) {
    data['cropdiseases'] = this.cropdiseases?.map((v) => v.toJson()).toList();
  }
  if (this.croppest != null) {
    data['croppest'] = this.croppest?.map((v) => v.toJson()).toList();
  }
  return data;
}
}

class Informationitems {
  String? name,id;
  List<Information>? information;

  Informationitems({this.id, this.name, this.information});

  Informationitems.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    name = json['name'];
    if (json['information'] != null) {
      information = <Information>[];
      json['information'].forEach((v) {
        information?.add(new Information.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['name'] = this.name;
    if (this.information != null) {
      data['information'] = this.information?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
class Information {
  String? infid,information;

  Information({this.infid, this.information});

  Information.fromJson(Map<String, dynamic> json) {
    infid = json['infid'];
    information = json['information'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['infid'] = this.infid;
    data['information'] = this.information;
    return data;
  }
}

class Cropdiseases {
  String? id, disease;
  String? image;
  List<DiseaseDetails>? diseaseDetails;

  Cropdiseases({this.id, this.disease, this.image, this.diseaseDetails});

  Cropdiseases.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    disease = json['disease'];
    image = json['image'];
    if (json['diseaseDetails'] != null) {
      diseaseDetails = <DiseaseDetails>[];
      json['diseaseDetails'].forEach((v) {
        diseaseDetails?.add(new DiseaseDetails.fromJson(v));
      });
    }
  }
  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['disease'] = this.disease;
    data['image'] = this.image;
    if (this.diseaseDetails != null) {
      data['diseaseDetails'] =
          this.diseaseDetails?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}
class DiseaseDetails {
  String? deseaseid,details;

  DiseaseDetails({this.deseaseid, this.details});

  DiseaseDetails.fromJson(Map<String, dynamic> json) {
    deseaseid = json['deseaseid'];
    details = json['details'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['deseaseid'] = this.deseaseid;
    data['details'] = this.details;
    return data;
  }
}

class Croppest {
  String? id, pest;
  String? image;
  List<PestDetails>? pestDetails;

  Croppest({this.id, this.pest, this.image, this.pestDetails});

  Croppest.fromJson(Map<String, dynamic> json) {
    id = json['id'];
    pest = json['pest'];
    image = json['image'];
    if (json['pestDetails'] != null) {
      pestDetails = <PestDetails>[];
      json['pestDetails'].forEach((v) {
        pestDetails?.add(new PestDetails.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['id'] = this.id;
    data['pest'] = this.pest;
    data['image'] = this.image;
    if (this.pestDetails != null) {
      data['pestDetails'] = this.pestDetails?.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class PestDetails {
  String? pestdetailid,details;

  PestDetails({this.pestdetailid, this.details});

  PestDetails.fromJson(Map<String, dynamic> json) {
    pestdetailid = json['pestdetailid'];
    details = json['details'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['pestdetailid'] = this.pestdetailid;
    data['details'] = this.details;
    return data;
  }
}