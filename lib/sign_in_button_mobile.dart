// Copyright 2013 The Flutter Authors. All rights reserved.
// Use of this source code is governed by a BSD-style license that can be
// found in the LICENSE file.

import 'package:flutter/material.dart';

import 'sign_in_button_stub.dart';
import "printer.dart";

/// Renders a SIGN IN button that calls `handleSignIn` onclick.
Widget buildSignInButton({HandleSignInFn? onPressed}) {
  Log.drive.log("BLUE: Android sign in button.");
  return ElevatedButton(onPressed: onPressed, child: const Text('SIGN IN'));
}
