package com.pyago.app

import io.flutter.embedding.android.FlutterFragmentActivity

// local_auth (biometric/PIN App Lock) requires the host Activity to be a
// FragmentActivity, so this extends FlutterFragmentActivity rather than
// the default FlutterActivity.
class MainActivity : FlutterFragmentActivity()
