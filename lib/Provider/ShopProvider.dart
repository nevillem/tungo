
import 'package:agritungotest/model/Section_Model.dart';
import 'package:flutter/material.dart';

class ShopProvider extends ChangeNotifier {
  String view = 'GridView';
  String totalProducts = '0';
  String totalMilkCollected = '0';
  String totalIncome = '0';
  String totalExpenses = '0';

  get getCurrentView => view;

  changeViewTo(String view) {
    this.view = view;
    notifyListeners();
  }

  get getTotalProducts => totalProducts;
  get getTotalIncome => totalIncome;
  get getTotalExpenses => totalExpenses;

  setProductTotal(String total) {
    totalProducts = total;
    notifyListeners();
  }
  setIncomeTotal(String total) {
    totalIncome = total;
    notifyListeners();
  }
  setExpenseTotal(String total) {
    totalExpenses = total;
    notifyListeners();
  }
    setMilkCollectedTotal(String total) {
    totalMilkCollected = total;
    notifyListeners();
  }

}