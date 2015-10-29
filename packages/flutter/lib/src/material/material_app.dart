// Copyright 2015 The Chromium Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'dart:ui' as ui;

import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';

import 'package:flutter/src/widgets/navigator2.dart' as n2;

import 'theme.dart';
import 'title.dart';

const TextStyle _errorTextStyle = const TextStyle(
  color: const Color(0xD0FF0000),
  fontFamily: 'monospace',
  fontSize: 48.0,
  fontWeight: FontWeight.w900,
  textAlign: TextAlign.right,
  decoration: underline,
  decorationColor: const Color(0xFFFF00),
  decorationStyle: TextDecorationStyle.double
);

AssetBundle _initDefaultBundle() {
  if (rootBundle != null)
    return rootBundle;
  const String _kAssetBase = '/packages/material_design_icons/icons/';
  return new NetworkAssetBundle(Uri.base.resolve(_kAssetBase));
}

final AssetBundle _defaultBundle = _initDefaultBundle();

const bool _kUseNavigator2 = false;

class MaterialApp extends StatefulComponent {
  MaterialApp({
    Key key,
    this.title,
    this.theme,
    this.routes,
    this.onGenerateRoute
  }) : super(key: key);

  final String title;
  final ThemeData theme;
  final Map<String, RouteBuilder> routes;
  final RouteGenerator onGenerateRoute;

  _MaterialAppState createState() => new _MaterialAppState();
}

class _MaterialAppState extends State<MaterialApp> {

  GlobalObjectKey _navigator;

  Size _size;

  void initState() {
    super.initState();
    _navigator = new GlobalObjectKey(this);
    WidgetFlutterBinding.instance.addEventListener(_backHandler);
    _size = ui.window.size;
    FlutterBinding.instance.addMetricListener(_metricHandler);
  }

  void dispose() {
    WidgetFlutterBinding.instance.removeEventListener(_backHandler);
    FlutterBinding.instance.removeMetricListener(_metricHandler);
    super.dispose();
  }

  void _backHandler(InputEvent event) {
    assert(mounted);
    if (event.type == 'back') {
      NavigatorState navigator = _navigator.currentState;
      assert(navigator != null);
      if (navigator.hasPreviousRoute)
        navigator.pop();
      else
        activity.finishCurrentActivity();
    }
  }

  void _metricHandler(Size size) => setState(() { _size = size; });

  Widget build(BuildContext context) {
    Widget navigator;
    if (_kUseNavigator2) {
      navigator = new n2.Navigator(
        key: _navigator,
        routes: config.routes
      );
    } else {
      navigator = new Navigator(
        key: _navigator,
        routes: config.routes,
        onGenerateRoute: config.onGenerateRoute
      );
    }
    return new MediaQuery(
      data: new MediaQueryData(size: _size),
      child: new Theme(
        data: config.theme ?? new ThemeData.fallback(),
        child: new DefaultTextStyle(
          style: _errorTextStyle,
          child: new DefaultAssetBundle(
            bundle: _defaultBundle,
            child: new Title(
              title: config.title,
              child: navigator
            )
          )
        )
      )
    );
  }

}
