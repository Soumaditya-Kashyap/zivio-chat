import 'package:flutter/material.dart';

extension ContextExtensin on BuildContext{
  showSnackBar(String message){
    ScaffoldMessenger.of(this).showSnackBar(SnackBar(content: Text(message)));
  }
}