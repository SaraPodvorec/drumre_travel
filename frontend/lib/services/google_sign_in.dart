// ignore_for_file: unused_field

import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as web;
import 'package:http/browser_client.dart' as browser;


/// The scopes required by this application
const List<String> scopes = <String>[
  'https://www.googleapis.com/auth/contacts.readonly',
];


class GoogleSignInWidget extends StatefulWidget {
  const GoogleSignInWidget({super.key});

  @override
  State<GoogleSignInWidget> createState() =>  GoogleSignInWidgetState();
}

class  GoogleSignInWidgetState extends State<GoogleSignInWidget> {

  GoogleSignInAccount? _currentUser;
  bool _isAuthorized = false;
  String _errorMessage = '';


  @override
  void initState() {
    super.initState();

    final GoogleSignIn googleSignIn = GoogleSignIn.instance;
    unawaited(
      googleSignIn.initialize().then((_) {
      googleSignIn.authenticationEvents
          .listen(_handleAuthenticationEvent);
    }),
    );
  }


  Future<void> _handleAuthenticationEvent(GoogleSignInAuthenticationEvent event) async {
    final GoogleSignInAccount? user = switch (event) {
          GoogleSignInAuthenticationEventSignIn() => event.user,
          GoogleSignInAuthenticationEventSignOut() => null,
        };

    // Check for existing authorization.
    final GoogleSignInClientAuthorization? authorization = await user
        ?.authorizationClient
        .authorizationForScopes(scopes);

    setState(() {
      _currentUser = user;
      _isAuthorized = authorization != null;
      _errorMessage = '';
    });

  try {

    final auth = user!.authentication; 
    final idToken = auth.idToken;

    if (idToken != null && idToken.isNotEmpty) {
      final client = browser.BrowserClient()..withCredentials = true;
      final res = await client.post(
        Uri.parse('http://localhost:3000/api/auth/google'), 
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': idToken}), 
      );
      client.close();

      if (res.statusCode == 200) {
        final data = jsonDecode(res.body);
        print('Backend auth OK: $data');
      } else {
        print('Backend rejected idToken: ${res.statusCode} ${res.body}');
      }
    } else {
      print('No idToken available for user');
    }
  } catch (e, st) {
    print('Error sending idToken to backend: $e\n$st');
  }
  }


  Future<void> _handleSignOut() async {
    // Disconnect instead of just signing out, to reset the example state as
    // much as possible.
    await GoogleSignIn.instance.disconnect();
  }

  Widget _buildBody() {
    final GoogleSignInAccount? user = _currentUser;

    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        if(user != null)
        ..._buildAuthenticatedWidgets(user)
        else
        ..._buildUnauthenticatedWidgets(),
        if (_errorMessage.isNotEmpty)
          Text(
            _errorMessage,
            style: const TextStyle(color: Colors.red),
          ),
      ],
    );
  }


  /// Returns the list of widgets to include if the user is authenticated.
  List<Widget> _buildAuthenticatedWidgets(GoogleSignInAccount user) {
    return <Widget>[
      // The user is Authenticated.
      ListTile(
        leading: GoogleUserCircleAvatar(identity: user),
        title: Text(user.displayName ?? ''),
        subtitle: Text(user.email),
      ),
      const Text('Signed in successfully.'),
      ElevatedButton(onPressed: _handleSignOut, child: const Text('SIGN OUT')),
    ];
  }


  /// Returns the list of widgets to include if the user is not authenticated.
  List<Widget> _buildUnauthenticatedWidgets() {
    return <Widget>[
      const Text('You are not currently signed in.'),
      
    ...<Widget>[
        if (kIsWeb)
          web.renderButton()
      ],
    ];
  }



  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Sign-In'),
      ),
      body: ConstrainedBox(
        constraints: const BoxConstraints.expand(),
        child: _buildBody(),
      ),
    );
  }

}