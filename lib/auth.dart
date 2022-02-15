part of tab_authentication;

class TabAuth extends FirebasePluginPlatform {
  static Platform get currentPlatform {
    if (kIsWeb) {
      return Platform.web;
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
        return Platform.ios;
      case TargetPlatform.android:
        return Platform.android;
      default:
        throw UnsupportedError(
          'TABAuth are not supported for this platform.',
        );
    }
  }

  FirebaseApp app;

  TabAuth._({required this.app})
      : super(app.name, 'plugins.flutter.io/tab_authentication');

  // ignore: prefer_final_fields
  static Map<String, TabAuth> _instances = {};

  static TabAuth get I => _getInstance;
  static TabAuth get instance => _getInstance;

  static TabAuth get _getInstance {
    try {
      return TabAuth.instanceFor(app: Firebase.app());
    } catch (e) {
      throw ("Firebase app not initialized correctly");
    }
  }

  factory TabAuth.instanceFor({required FirebaseApp app}) {
    return _instances.putIfAbsent(app.name, () {
      return TabAuth._(app: app);
    });
  }

  Future<TabAuth> signInWithEmail(
      {required String email,
      required String password,
      TABEmailOptions? options}) async {
    await _TabSignIn._withEmail(
        email: email, password: password, options: options);
    return this;
  }

  Future<bool> phone({
    required String phone,
    required Function(Function({required String smsCode}) test) confirm,
    RecaptchaVerifier? verifierForWeb,
    TABPhoneOptions? options,
  }) async {
    return await _TabSignInWithPhone._withPhoneNumber(
        phone: phone, confirm: confirm, options: options);
  }

  // Future<bool> sendSignInLink({
  //   required String email,
  //   required ActionCodeSettings actionCodeSettings,
  //   SignInWithlOptions? options,
  // }) async {
  //   _TabSignIn signIn = _TabSignIn();
  //   if (TabAuth.I.isSignIn) {
  //     signIn._options = options;
  //     signIn._alreadyLoggedIn();
  //     return false;
  //   }
  //   try {
  //     await FirebaseAuth.instance.sendSignInLinkToEmail(
  //       email: email,
  //       actionCodeSettings: actionCodeSettings,
  //     );
  //   } catch (e) {
  //     signIn._onFailed(e.toString());
  //     return false;
  //   }
  //   signIn._onSuccess()
  //   return true;
  // }

  // Future<TabAuth> signInWithEmailLink(
  //     {required String email,
  //     required String emailLink,
  //     SignInWithOptions? options}) async {
  //   await _TabSignIn._withEmailLink(
  //       email: email, emailLink: emailLink, options: options);
  //   return this;
  // }

  signOut({Function(bool status)? getStatus}) =>
      _TabAuthSignOut(getStatus: getStatus);

  User? get getCurrentUser => FirebaseAuth.instance.currentUser;
  bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;
}
