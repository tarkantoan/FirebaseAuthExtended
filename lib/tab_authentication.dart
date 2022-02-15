library tab_authentication;

import 'dart:convert';

import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/firebase_core_platform_interface.dart';
import 'package:tab_authentication/enums/platform.dart';

part 'auth.dart';
part 'modules/sign_in_with_email.dart';
part 'modules/sign_in_with_phone.dart';
part 'sign_out.dart';
