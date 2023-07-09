import 'package:flutter/cupertino.dart';
import '../Model/other_dashboard_report.dart';

class MilkDashboardProvider extends ChangeNotifier {
  final List<Gender> _genderList = [];
  get genderList => _genderList;

  bool _isProgress = true;
  get isProgress => _isProgress;

  setProgress(bool progress) {
    _isProgress = progress;
    notifyListeners();
  }

  setDashboardList(List<Gender> genderList) {
    _genderList.clear();
    _genderList.addAll(genderList);
    notifyListeners();
  }
}