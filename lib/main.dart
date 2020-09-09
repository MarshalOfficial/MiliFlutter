import 'package:shared_preferences/shared_preferences.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:flutter_webview_plugin/flutter_webview_plugin.dart';
import 'dart:async';

import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(MaterialApp(home: MyApp(), debugShowCheckedModeBanner: false));
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final LocalAuthentication _localAuthentication = LocalAuthentication();
  // bool _canCheckBiometric = false;
  String _authorizedOrNot = "Not Authorized";
  // List<BiometricType> _availableBiometricTypes = List<BiometricType>();
  final flutterWebviewPlugin = new FlutterWebviewPlugin();
  StreamSubscription _onDestroy;
  StreamSubscription<String> _onUrlChanged;
  StreamSubscription<WebViewStateChanged> _onStateChanged;
  SharedPreferences prefs;
  String baseUrl = 'https://app.hoo.club';
  WebViewController controller;

  @override
  void dispose() {
    // Every listener should be canceled, the same should be done with this stream.
    _onDestroy.cancel();
    _onUrlChanged.cancel();
    _onStateChanged.cancel();
    flutterWebviewPlugin.dispose();
    super.dispose();
  }
  // Future<void> _checkBiometric() async {
  //   bool canCheckBiometric = false;
  //   try {
  //     canCheckBiometric = await _localAuthentication.canCheckBiometrics;
  //   } on PlatformException catch (e) {
  //     print(e);
  //   }

  //   if (!mounted) return;

  //   setState(() {
  //     _canCheckBiometric = canCheckBiometric;
  //   });
  // }

  // Future<void> _getListOfBiometricTypes() async {
  //   List<BiometricType> listofBiometrics;
  //   try {
  //     listofBiometrics = await _localAuthentication.getAvailableBiometrics();
  //   } on PlatformException catch (e) {
  //     print(e);
  //   }

  //   if (!mounted) return;

  //   setState(() {
  //     _availableBiometricTypes = listofBiometrics;
  //   });
  // }

  Future<void> _authorizeNow() async {
    // SharedPreferences prefs = await SharedPreferences.getInstance();
    // String storedtoken = (prefs.getString('token') ?? '');
    // bool blanks = storedtoken?.trim()?.isEmpty ?? true;
    // if (!blanks) {
    //   setState(() {
    //     {
    //       _authorizedOrNot = "Authorized";
    //     }
    //   });
    //   return;
    // }
    bool isAuthorized = false;
    try {
      isAuthorized = await _localAuthentication.authenticateWithBiometrics(
        localizedReason: "Put your finfer to authenticate",
        useErrorDialogs: true,
        stickyAuth: true,
      );
    } on PlatformException catch (e) {
      print(e);
    }

    if (!mounted) return;

    setState(() {
      if (isAuthorized) {
        _authorizedOrNot = "Authorized";
      } else {
        _authorizedOrNot = "Not Authorized";
      }
    });
  }

  void loadSharedPreferences() async {
    prefs = await SharedPreferences.getInstance();
  }

  @override
  void initState() {
    super.initState();
    loadSharedPreferences();
    _authorizeNow();
    flutterWebviewPlugin.close();

    // Add a listener to on destroy WebView, so you can make came actions.
    _onDestroy = flutterWebviewPlugin.onDestroy.listen((_) {
      print("destroy");
    });

    _onStateChanged =
        flutterWebviewPlugin.onStateChanged.listen((WebViewStateChanged state) {
      flutterWebviewPlugin.getCookies().then((Map<String, String> _cookies) {
        String _usrinf = _cookies[" userInfo"];
        String _useInfoOk = Uri.decodeFull(_usrinf);
        if (_useInfoOk.toLowerCase().contains("access_token")) {
          String token =
              _useInfoOk.substring(_useInfoOk.indexOf('"access_token":"') + 16);
          token = token.substring(0, token.indexOf('","token_type"'));
          bool blank = token?.trim()?.isEmpty ?? true;
          if (!blank) {
            prefs.setString('token', token);
          }

          print('baseUrl:' + baseUrl);
        }
      });
      print("onStateChanged: ${state.type} ${state.url}");
    });

    // Add a listener to on url changed
    _onUrlChanged = flutterWebviewPlugin.onUrlChanged.listen((String url) {
      try {
        if (mounted) {
          print("URL changed: $url");
        }
      } catch (e) {
        print(e);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    // if (_canCheckBiometric) {
    //while (_authorizedOrNot != "Authorized") {
    //_authorizeNow();
    //}
    //}
    loadSharedPreferences();
    if (prefs != null) {
      String storedtoken = (prefs.getString('token') ?? '');
      bool blanks = storedtoken?.trim()?.isEmpty ?? true;
      if (!blanks) {
        baseUrl = 'https://app.hoo.club/#/mobile/' + storedtoken;
        flutterWebviewPlugin.reloadUrl(baseUrl);
      } else {
        baseUrl = 'https://app.hoo.club';
      }
    }

    return WebviewScaffold(url: baseUrl);
  }
}

// void main() => runApp(MyApp());

// class MyApp extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Auth Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(title: 'Flutter Local Auth'),
//     );
//   }
// }

// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key key, this.title}) : super(key: key);

//   final String title;

//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }

// class _MyHomePageState extends State<MyHomePage> {
//   final LocalAuthentication _localAuthentication = LocalAuthentication();
//   bool _canCheckBiometric = false;
//   String _authorizedOrNot = "Not Authorized";
//   List<BiometricType> _availableBiometricTypes = List<BiometricType>();

//   Future<void> _checkBiometric() async {
//     bool canCheckBiometric = false;
//     try {
//       canCheckBiometric = await _localAuthentication.canCheckBiometrics;
//     } on PlatformException catch (e) {
//       print(e);
//     }

//     if (!mounted) return;

//     setState(() {
//       _canCheckBiometric = canCheckBiometric;
//     });
//   }

//   Future<void> _getListOfBiometricTypes() async {
//     List<BiometricType> listofBiometrics;
//     try {
//       listofBiometrics = await _localAuthentication.getAvailableBiometrics();
//     } on PlatformException catch (e) {
//       print(e);
//     }

//     if (!mounted) return;

//     setState(() {
//       _availableBiometricTypes = listofBiometrics;
//     });
//   }

//   Future<void> _authorizeNow() async {
//     bool isAuthorized = false;
//     try {
//       isAuthorized = await _localAuthentication.authenticateWithBiometrics(
//         localizedReason: "انگشت خود را بنه",
//         useErrorDialogs: true,
//         stickyAuth: true,
//       );
//     } on PlatformException catch (e) {
//       print(e);
//     }

//     if (!mounted) return;

//     setState(() {
//       if (isAuthorized) {
//         _authorizedOrNot = "Authorized";
//       } else {
//         _authorizedOrNot = "Not Authorized";
//       }
//     });
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text(widget.title),
//       ),
//       body: Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: <Widget>[
//             Text("Can we check Biometric : $_canCheckBiometric"),
//             RaisedButton(
//               onPressed: _checkBiometric,
//               child: Text("Check Biometric"),
//               color: Colors.red,
//               colorBrightness: Brightness.light,
//             ),
//             Text("List Of Biometric : ${_availableBiometricTypes.toString()}"),
//             RaisedButton(
//               onPressed: _getListOfBiometricTypes,
//               child: Text("List of Biometric Types"),
//               color: Colors.red,
//               colorBrightness: Brightness.light,
//             ),
//             Text("Authorized : $_authorizedOrNot"),
//             RaisedButton(
//               onPressed: _authorizeNow,
//               child: Text("Authorize now"),
//               color: Colors.red,
//               colorBrightness: Brightness.light,
//             ),
//           ],
//         ),
//       ),
//     );
//   }
// }
