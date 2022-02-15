part of tab_authentication;

class _TabAuthSignOut {
  Function(bool status)? getStatus;

  _TabAuthSignOut({this.getStatus}) {
    signOut();
  }

  signOut() async {
    if (!TabAuth.I.isLoggedIn) return getStatus!(true);
    try {
      await FirebaseAuth.instance.signOut();
      getStatus!(true);
    } catch (e) {
      getStatus!(false);
    }
  }
}
