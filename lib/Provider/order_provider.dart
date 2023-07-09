
import 'package:flutter/material.dart';

import '../Helper/ApiBaseHelper.dart';
import '../Helper/String.dart';
import '../model/Order_Model.dart';


class OrderProvider extends ChangeNotifier {

  late List<OrderModel> _orders = [];

  late bool isLoading = true;
  late bool hasError = false;
  ApiBaseHelper apiBaseHelper = ApiBaseHelper();

  List<OrderModel>  get orders => _orders;

  void changeIsLoading() {
    isLoading = !isLoading;
    notifyListeners();
  }

  void changeHasError() {
    hasError = !hasError;
    notifyListeners();
  }

  fetchOrderDetails(var userID,[var activeStatus]) async {


    var parameter = {USER_ID: userID};

        parameter[ACTIVE_STATUS] = activeStatus;

      final result = await apiBaseHelper.postAPICall(getOrderApi,parameter);
      if(result['error']) {
        isLoading = !isLoading;
        hasError = true;
        notifyListeners();
      }
      else {
        isLoading = false;
        var orders = result['data'] as List;
        _orders = orders.map((e) => OrderModel.fromJson(Map.from(e))).toList();
        notifyListeners();
      }
  }
}