
import 'dart:developer';

import 'package:collection/src/iterable_extensions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

Future<List<ControlObject>> getControlObjects() async {
  final controlObjects = List<ControlObject>.empty(growable: true);

  // Connect to the database and get the correct path
  FirebaseDatabase db = FirebaseDatabase(app: Firebase.apps.first);
  final reference = db.reference().child('gestures/user:${FirebaseAuth.instance.currentUser?.email?.replaceAll('.', '')}');
  final snapshot = await reference.get();

  // Create the control objects from the list
  if (snapshot.value is List) {
    (snapshot.value as List).forEachIndexed((index, gesture) =>
        controlObjects.add(ControlObject(
            gesture['name'].toString(),
            index.toString(),
            gestureIconMap[gesture['icon'].toString()] ?? Icons.light,
            gesture['ip'] ?? ""
        ))
    );
  }

  return controlObjects;
}

Future<bool> saveControlObjects(List<ControlObject> controlObjects) async {
  try {
    // Connect to the database and get the correct path
    FirebaseDatabase db = FirebaseDatabase(app: Firebase.apps.first);
    final reference = db.reference().child(
        'gestures/user:${FirebaseAuth.instance.currentUser?.email?.replaceAll(
            '.', '')}');

    // Update the values in the database for the user
    for (var i = 0; i < controlObjects.length; i++) {
      reference.child(i.toString()).child("name").set(controlObjects[i].name);
      reference.child(i.toString()).child("ip").set(controlObjects[i].ip);
    }

    // Push the changes
    reference.push();

    return true;
  } on Exception catch (_, e) {
    log(e.toString());
    return false;
  }
}

final gestureIconMap = {
  "Light": Icons.light,
  "Door": Icons.sensor_door,
  "Window": Icons.sensor_window,
  "Circle": Icons.stop_circle,
  "Food": Icons.coffee
};

class ControlObject {
  String name;
  String id;
  IconData icon;
  String ip;

  ControlObject(this.name, this.id, this.icon, this.ip);
}