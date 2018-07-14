// Copyright (c) 2016, the Dart project authors.  Please see the AUTHORS file
// for details. All rights reserved. Use of this source code is governed by a
// BSD-style license that can be found in the LICENSE file.

import "package:test/test.dart";

final Matcher throwsCastError = throwsA(new TypeMatcher<CastError>());

/// A hack to determine whether we are running in a Dart 2 runtime.
final bool isDart2 = _isTypeArgString('');
bool _isTypeArgString<T>(T arg) {
  try {
    return T == String;
  } catch (_) {
    return false;
  }
}
