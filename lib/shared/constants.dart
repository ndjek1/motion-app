import 'package:flutter/material.dart';


const backgroundColor = Colors.indigo; // Main theme color
const appBarColor = Colors.indigoAccent;
const textFieldFillColor = Colors.white10;
const buttonColor = Colors.indigoAccent;
const primaryTextColor = Colors.white;
const errorTextColor = Colors.red;

const textInputDecoration = InputDecoration(
    fillColor: Colors.white,
    filled: true,
    enabledBorder: OutlineInputBorder(
        borderSide: BorderSide(
      color: Colors.white,
      width: 2.0,
    )),
    focusedBorder: OutlineInputBorder(
        borderSide: BorderSide(color: Colors.indigo, width: 2.0)));
