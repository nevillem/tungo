import 'package:collection/src/iterable_extensions.dart';
import 'package:agritungotest/Model/Section_Model.dart';
import 'package:flutter/material.dart';

class CartProvider extends ChangeNotifier {
  final List<SectionModel> _cartList = [];

  get cartList => _cartList;
  bool _isProgress = false;

  get cartIdList => _cartList.map((fav) => fav.productId).toList();

  String? qtyList(String id) {
    SectionModel? tempId =
    _cartList.firstWhereOrNull((cp) => cp.id == id);
    notifyListeners();
    if (tempId != null) {
      /// notifyListeners();
      return tempId.qty;
    } else {
      ///notifyListeners();
      return '0';
    }
  }

  get isProgress => _isProgress;

  setProgress(bool progress) {
    _isProgress = progress;
    notifyListeners();
  }

  removeCartItem(String id) {
    _cartList.removeWhere((item) => item.productId == id);
    notifyListeners();
  }

  addCartItem(SectionModel? item) {
    if (item != null) {
      _cartList.add(item);
      notifyListeners();
    }
  }

  updateCartItem(String? id, String qty, int index) {
    final i = _cartList.indexWhere((cp) => cp.id == id );

    _cartList[i].qty = qty;
    // _cartList[i].productList![0].prVarientList![index].cartCount = qty;
    // _cartList[i].productList![0].qtyStepSize = qty;

    notifyListeners();
  }

  setCartlist(List<SectionModel> cartList) {
    _cartList.clear();
    _cartList.addAll(cartList);
    notifyListeners();
  }
}
