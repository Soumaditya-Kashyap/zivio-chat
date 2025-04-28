import 'package:flutter/material.dart';
import 'package:chat_app/core/enums/enums.dart';

class BaseViewModel extends ChangeNotifier {
  
  ViewState _state = ViewState.idle; //default state, when the viewmodel is created,
  ViewState get state => _state; //getter for the state, to be used in the UI

  setState(ViewState state) { //function to set the state as per the requirement
    _state = state;
    notifyListeners();
  }
}
