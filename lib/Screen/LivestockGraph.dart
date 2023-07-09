import 'dart:convert';

import 'package:agritungotest/Helper/Session.dart';
import 'package:flutter/material.dart';
import 'package:charts_flutter/flutter.dart' as charts;
import 'package:http/http.dart';

import '../Helper/String.dart';
import '../Helper/graph_network_helper.dart';
import '../Model/Income.dart';
//const Color blueColor = Color(0xff1565C0);
const Color blueColor = Color(0xFFF9C404);
//const Color orangeColor = Color(0xffFFA000);
const Color orangeColor = Color(0xFF73B41A);

class LiveStockStatistics extends StatefulWidget {
  const LiveStockStatistics({Key? key}) : super(key: key);
  @override
  _LiveStockStatisticsState createState() => _LiveStockStatisticsState();
}


class _LiveStockStatisticsState extends State<LiveStockStatistics> {
  List<IncomeModel> incomes = [];
  List<IncomeModel> expenditure = [];
  bool loading = true;
  static const secondaryMeasureAxisId = 'secondaryMeasureAxisId';
  NetworkHelper _networkHelper = NetworkHelper();

  @override
  void initState() {
    super.initState();
    getData();
    getExpensesData();
  }

  void getData() async {
    var response = await get(incometChartUrl, headers: headers);
    // var getdata=jsonDecode(response.body)['data']['incomes'];
    var getdata= response.body;
    // print("chart api:${getdata}");
    List<IncomeModel> tempdata = incomeModelFromJson(response.body);
    setState(() {
      incomes = tempdata;
      loading = false;
    });
  }
  void getExpensesData() async {
    var response = await get(expenditureChartUrl, headers: headers);
    // var getdata=jsonDecode(response.body)['data']['incomes'];
    var getdata= response.body;
    // print("chart api:${getdata}");
    List<IncomeModel> tempdata = incomeModelFromJson(response.body);
    setState(() {
      expenditure = tempdata;
      loading = false;
    });
  }

  // void getData() async {
  //   var response = await _networkHelper.get(
  //       "https://api.genderize.io/?name[]=balram&name[]=deepa&name[]=saket&name[]=bhanu&name[]=aquib");
  //   print(response.body);
  //   List<IncomeModel> tempdata = incomeModelFromJson(response.body);
  //   setState(() {
  //     incomes = tempdata;
  //     loading = false;
  //   });
  // }

  List<charts.Series<IncomeModel, String>> _createSampleData() {
    return [
      charts.Series<IncomeModel, String>(
        data: incomes,
        id: 'income',
        // colorFn: (_, __) => charts.MaterialPalette.teal.shadeDefault,
        domainFn: (IncomeModel incomeModel, _) => incomeModel.month,
        measureFn: (IncomeModel incomeModel, _) => incomeModel.income,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(orangeColor),
        labelAccessorFn: (IncomeModel incomeModel, _)=>
        'income: ${incomeModel.month.toString()}',
        displayName: "Income",
      ),
      charts.Series<IncomeModel, String>(
        id: 'expense',
        domainFn: (IncomeModel expenditureModel, _) => expenditureModel.month,
        measureFn: (IncomeModel expenditureModel, _) => expenditureModel.income,
        data: expenditure,
        colorFn: (_, __) => charts.ColorUtil.fromDartColor(blueColor),
        displayName: "Expenses",
      )..setAttribute(charts.measureAxisIdKey, secondaryMeasureAxisId),
    ];
  }
  @override
  Widget build(BuildContext context) {
    return charts.BarChart(
      _createSampleData(),
      animate: true,
      barGroupingType: charts.BarGroupingType.grouped,
      defaultRenderer: charts.BarRendererConfig(
          cornerStrategy:  const charts.ConstCornerStrategy(50)),
      primaryMeasureAxis: const charts.NumericAxisSpec(
        tickProviderSpec: charts.BasicNumericTickProviderSpec(
          desiredMinTickCount: 6,
          desiredMaxTickCount: 10,
        ),
      ),
      secondaryMeasureAxis: const charts.NumericAxisSpec(
          tickProviderSpec: charts.BasicNumericTickProviderSpec(
              desiredTickCount: 6, desiredMaxTickCount: 10)),
      selectionModels: [
        charts.SelectionModelConfig(
            changedListener: (charts.SelectionModel model) {
              if (model.hasDatumSelection)
                print(model.selectedSeries[0]
                    .measureFn(model.selectedDatum[0].index));
            })
      ],
      behaviors: [
        charts.SeriesLegend(),
      ],

    );
  }
}
