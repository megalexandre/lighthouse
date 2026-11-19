import 'dart:convert';

import 'package:lighthouse/features/auth/data/session.dart';
import 'package:lighthouse/features/auth/data/session_store.dart';

import 'world.dart';

/// The session the app keeps in its keyring.
Session storedSession() => Session.fromJson(
  jsonDecode(store.values[SessionStore.sessionKey]!) as Map<String, dynamic>,
);
