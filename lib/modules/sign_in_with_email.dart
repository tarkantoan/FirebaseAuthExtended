part of tab_authentication;

class TABEmailOptions {
  bool Function()? condition;
  Function()? alreadyLoggedIn;
  Function(UserCredential userCredential)? onSuccess;
  Function(dynamic error)? onFailed;

  TABEmailOptions({
    this.condition,
    this.alreadyLoggedIn,
    this.onSuccess,
    this.onFailed,
  });
}

class _TabSignIn {
  String? _email;
  String? _emailLink;
  String? _password;
  TABEmailOptions? _options;
  UserCredential? userCredential;
  ConfirmationResult? confirmationResult;

  static Future<bool> _withEmail({
    required email,
    required String? password,
    TABEmailOptions? options,
  }) async {
    _TabSignIn signIn = _TabSignIn();
    signIn._email = email;
    signIn._password = password;
    signIn._options = options;
    if (!signIn._checkCondition()) return false;
    if (await signIn._signInWithEmail()) return true;
    return false;
  }

  Future<bool> _signInWithEmail() async {
    /// if user already logged in return false
    if (TabAuth.I.isLoggedIn) {
      _alreadyLoggedIn();
      return false;
    }

    try {
      userCredential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: _email!, password: _password!);
    } catch (e) {
      await _onFailed(e.toString());
      return false;
    }

    // if signIn success full return true
    return _signInRequestResult(userCredential!);
  }

  bool _signInRequestResult(UserCredential userCredential) {
    if (userCredential.user != null) {
      _onSuccess(userCredential);
      return true;
    }
    _options?.onFailed!(null);
    return false;
  }

  bool _checkCondition() {
    if (!(_options!.condition ?? () => true)()) {
      _onFailed("Condition is false");
      return false;
    }
    return true;
  }

  _alreadyLoggedIn() {
    _options?.alreadyLoggedIn!();
  }

  _onSuccess(userCredential) {
    _options?.onSuccess!(userCredential);
  }

  _onFailed(String errText) {
    _options?.onFailed!(errText);
  }
}


  // static Future<bool> _withEmailLink(
  //     {required email,
  //     required String? emailLink,
  //     TABEmailOptions? options}) async {
  //   if (!(options!.condition ?? () => true)()) return false;
  //   _TabSignIn signIn = _TabSignIn();
  //   signIn._email = email;
  //   signIn._emailLink = emailLink;
  //   signIn._options = options;
  //   if (await signIn._signInWithEmailLink()) return true;
  //   return false;
  // }

  // Future _signInWithEmailLink() async {
  //   /// if user already logged in return status
  //   if (TabAuth.I.isSignIn) {
  //     _alreadyLoggedIn();
  //     return false;
  //   }

  //   try {
  //     userCredential = await FirebaseAuth.instance
  //         .signInWithEmailLink(email: _email!, emailLink: _emailLink!);
  //   } catch (e) {
  //     await _onFailed(e.toString());
  //     return false;
  //   }

  //   // if signIn success full return true
  //   return _signInRequestResult(userCredential!);
  // }

