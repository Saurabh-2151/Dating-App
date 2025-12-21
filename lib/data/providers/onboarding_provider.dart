import 'package:flutter/foundation.dart';

class OnboardingProvider with ChangeNotifier {
  String _name = '';
  String? _gender;
  String? _genderDetail;
  String? _orientation;
  String? _interestIn;
  final Set<String> _lookingFor = {};
  double _distance = 50;
  final Set<String> _extras = {};
  bool _fantasyEnabled = false;
  String? _fantasyRole;
  final Set<String> _kinks = {};
  int _currentPage = 0;

  String get name => _name;
  String? get gender => _gender;
  String? get genderDetail => _genderDetail;
  String? get orientation => _orientation;
  String? get interestIn => _interestIn;
  Set<String> get lookingFor => _lookingFor;
  double get distance => _distance;
  Set<String> get extras => _extras;
  bool get fantasyEnabled => _fantasyEnabled;
  String? get fantasyRole => _fantasyRole;
  Set<String> get kinks => _kinks;
  int get currentPage => _currentPage;

  void setName(String value) {
    _name = value;
    notifyListeners();
  }

  void setGender(String value) {
    _gender = value;
    notifyListeners();
  }

  void setGenderDetail(String value) {
    _genderDetail = value;
    notifyListeners();
  }

  void setOrientation(String value) {
    _orientation = value;
    notifyListeners();
  }

  void setInterestIn(String value) {
    _interestIn = value;
    notifyListeners();
  }

  void toggleLookingFor(String value) {
    if (_lookingFor.contains(value)) {
      _lookingFor.remove(value);
    } else {
      _lookingFor.add(value);
    }
    notifyListeners();
  }

  void setDistance(double value) {
    _distance = value;
    notifyListeners();
  }

  void toggleExtra(String value) {
    if (_extras.contains(value)) {
      _extras.remove(value);
    } else {
      _extras.add(value);
    }
    notifyListeners();
  }

  void setFantasyEnabled(bool value) {
    _fantasyEnabled = value;
    if (!value) {
      _fantasyRole = null;
    }
    notifyListeners();
  }

  void setFantasyRole(String value) {
    _fantasyRole = value;
    notifyListeners();
  }

  void toggleKink(String value) {
    if (_kinks.contains(value)) {
      _kinks.remove(value);
    } else {
      _kinks.add(value);
    }
    notifyListeners();
  }

  void setCurrentPage(int index) {
    _currentPage = index;
    notifyListeners();
  }
}
