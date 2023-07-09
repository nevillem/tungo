import 'package:flutter/material.dart';

class HomeProvider extends ChangeNotifier {
  int _curSlider = 0;
  bool _catLoading = true;
  bool _cropsLoading = true;
  bool _secLoading = true;
  bool _sliderLoading = true;
  bool _offerLoading = true;
  bool _sellerLoading = true;
  bool _milkcollectionLoading = true;
  bool _catalogLoading = true;
  bool _animalsLoading = true;
  bool _cropSelectionLoading = true;
  bool _showBars = true;
  bool _cropsSelectedLoading = true;
  bool _favLoading= true;
  late AnimationController _animationController;
  late Animation<Offset> _animationBottomBarOffset;
   Animation<Offset>? _animationAppBarOffset;

  get catalogLoading => _catalogLoading;
  get cropSelectionLoading => _cropSelectionLoading;
  get sellerLoading => _sellerLoading;
  get milkcollectionLoading => _milkcollectionLoading;
  get favLoading => _favLoading;

  get catLoading => _catLoading;
  get cropLoading => _cropsLoading;
  get cropsSelectedLoading => _cropsSelectedLoading;
  get animalLoading => _animalsLoading;

  get curSlider => _curSlider;

  get secLoading => _secLoading;

  get sliderLoading => _sliderLoading;

  get offerLoading => _offerLoading;

  get getBars => _showBars;

  AnimationController get animationController => _animationController;

  get animationNavigationBarOffset => _animationBottomBarOffset;

  get animationAppBarBarOffset => _animationAppBarOffset;

  showAppAndBottomBars(bool value) {
    _showBars = value;
    notifyListeners();
  }

  void setAnimationController(AnimationController animationController) {
    _animationController = animationController;
    notifyListeners();
  }

  setBottomBarOffsetToAnimateController(
      AnimationController animationController) {
    _animationBottomBarOffset =
        Tween<Offset>(begin: Offset.zero, end: const Offset(0.0, 1.0)).animate(
            CurvedAnimation(parent: animationController, curve: Curves.easeIn));
    notifyListeners();
  }

  setAppBarOffsetToAnimateController(AnimationController animationController) {
    _animationAppBarOffset = Tween<Offset>(
        end: const Offset(0.0, -1.25), begin: Offset.zero)
        .animate(
        CurvedAnimation(parent: animationController, curve: Curves.easeIn));
    notifyListeners();
  }

  setCurSlider(int pos) {
    _curSlider = pos;
    notifyListeners();
  }

  setOfferLoading(bool loading) {
    _offerLoading = loading;
    notifyListeners();
  }

  setSliderLoading(bool loading) {
    _sliderLoading = loading;
    notifyListeners();
  }

  setSecLoading(bool loaidng) {
    _secLoading = loaidng;
    notifyListeners();
  }

  setSellerLoading(bool loading) {
    _sellerLoading = loading;
    notifyListeners();
  }
  setMilkCollectionLoading(bool loading) {
    _milkcollectionLoading = loading;
    notifyListeners();
  }

  setCatalogLoading(bool loading) {
    _catalogLoading = loading;
    notifyListeners();
  }
  setAnimalLoading(bool loading) {
    _animalsLoading = loading;
    notifyListeners();
  }

  setCatLoading(bool loading) {
    _catLoading = loading;
    notifyListeners();
  }
  setSelectionCropLoading(bool loading) {
    _cropSelectionLoading = loading;
    notifyListeners();
  }
  setCropsLoading(bool loading) {
    _cropsLoading = loading;
    notifyListeners();
  }
  setCropsSelectedLoading(bool loading) {
    _cropsSelectedLoading = loading;
    notifyListeners();
  }
  setfavLoading(bool loading) {
    _favLoading = loading;
    notifyListeners();
  }

}
