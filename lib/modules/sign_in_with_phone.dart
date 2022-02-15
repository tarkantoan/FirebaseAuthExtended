part of tab_authentication;

class TABPhoneOptions {
  bool Function()? condition;
  Function()? alreadyLoggedIn;
  Function(UserCredential userCredential)? onSuccess;
  Function(dynamic error)? onFailed;
  Function()? onTimeOut;
  int timeout;
  TABPhoneOptions({
    this.condition,
    this.alreadyLoggedIn,
    this.onSuccess,
    this.onFailed,
    this.onTimeOut,
    this.timeout = 60,
  });
}

class _TabSignInWithPhone {
  String phone;
  TABPhoneOptions? options;
  bool isTimeOut = false;
  Function(Function({required String smsCode}) test) confirm;

  _TabSignInWithPhone(
      {required this.phone, this.options, required this.confirm});

  static Future<bool> _withPhoneNumber({
    required String phone,
    required Function(Function({required String smsCode}) test) confirm,
    TABPhoneOptions? options,
  }) async {
    _TabSignInWithPhone signIn =
        _TabSignInWithPhone(phone: phone, options: options, confirm: confirm);

    if (!_TabSignInWithPhone.checkCondition(options)) {
      return false;
    }

    if (signIn.alreadyLoggedIn()) return false;

    bool status = false;

    if (TabAuth.currentPlatform == Platform.web) {
      status = await signIn._forWeb();
    }
    if (TabAuth.currentPlatform == Platform.android) {
      status = await signIn._forMobile();
    }
    return status;
  }

  Future<bool> _forWeb() async {
    ConfirmationResult confirmationResult;
    UserCredential userCredential;

    try {
      final confirmationResultQuery =
          FirebaseAuth.instance.signInWithPhoneNumber(phone);
      confirmationResultQuery.timeout(
        Duration(seconds: options?.timeout ?? 2),
        onTimeout: (() {
          onTimeOut();
          return Future.error("timeout", StackTrace.current);
        }),
      );
      confirmationResult = await confirmationResultQuery;
      await confirm(({required String smsCode}) async {
        if (alreadyLoggedIn() || isTimeOut) return false;
        UserCredential credential;
        try {
          credential = await confirmationResult.confirm(smsCode);
          if (credential.user == null) throw ("Failed to login");
        } catch (e) {
          onFailed(e.toString());
          return false;
        }
        onSuccess(credential);
        return true;
      });
    } catch (e) {
      onFailed(e.toString());
      return false;
    }
    return true;
  }

  Future<bool> _forMobile() async {
    try {
      FirebaseAuth.instance.verifyPhoneNumber(
        timeout: Duration(seconds: options?.timeout ?? 120),
        phoneNumber: phone,
        verificationCompleted: (verificationCompleted) async {
          UserCredential userCredential = await FirebaseAuth.instance
              .signInWithCredential(verificationCompleted);
          onSuccess(userCredential);
        },
        verificationFailed: (verificationFailed) {
          onFailed(verificationFailed.toString());
        },
        codeSent: (String verificationId, int? resendToken) async {
          await confirm(({required String smsCode}) async {
            return await _forMobileConfirm(verificationId, smsCode);
          });
        },
        codeAutoRetrievalTimeout: (codeAutoRetrievalTimeout) {
          onTimeOut();
        },
      );
    } catch (e) {
      onFailed(e.toString());
      return false;
    }
    return true;
  }

  Future<bool> _forMobileConfirm(String verificationId, String smsCode) async {
    if (alreadyLoggedIn() || isTimeOut) return false;
    UserCredential credential;
    try {
      PhoneAuthCredential phoneAuthCredential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: smsCode);

      credential =
          await FirebaseAuth.instance.signInWithCredential(phoneAuthCredential);
      if (credential.user == null) throw ("Failed to login");
    } catch (e) {
      onFailed(e.toString());
      return false;
    }
    onSuccess(credential);
    return true;
  }

  alreadyLoggedIn() {
    if (TabAuth.I.isLoggedIn) {
      if (options != null && options?.alreadyLoggedIn != null) {
        print("already");
        options?.alreadyLoggedIn!();
      }
      return true;
    }
    return false;
  }

  onFailed(dynamic error) {
    if (options != null && options?.onFailed != null) {
      options?.onFailed!(error);
    }
  }

  onTimeOut() {
    isTimeOut = true;
    if (options != null && options?.onTimeOut != null) {
      options?.onTimeOut!();
    }
  }

  onSuccess(UserCredential userCredential) {
    if (options != null && options?.onSuccess != null) {
      options?.onSuccess!(userCredential);
    }
  }

  static bool checkCondition(TABPhoneOptions? options) {
    if (options != null && options.condition != null) {
      return options.condition!();
    }
    return true;
  }
}
