import 'package:agritungotest/Model/Categories_Model.dart';
import 'package:flutter/cupertino.dart';

class CategoryProvider extends ChangeNotifier {
  List<CategoriesData>? _subList = [];
  int _curCat = 0;

  get subList => _subList;

  get curCat => _curCat;

  setCurSelected(int index) {
    _curCat = index;
    notifyListeners();
  }

  setSubList(List<CategoriesData>? subList) {
    _subList = subList;
    notifyListeners();
  }
}
