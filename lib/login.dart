import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'utils/heroku.dart';

class LoginPage extends StatefulWidget {
  LoginPage({Key key}) : super(key: key);

  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _loginTextController = TextEditingController();
  final client = http.Client();

  void login(token) async {
    if (await HerokuAPI.instance.checkAccount(token)) {
      final prefs = await SharedPreferences.getInstance();
      prefs.setString('HEROKU_TOKEN', token);

      Navigator.pushNamed(context, '/home');
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: new Text("Invalid access token"),
            content: new Text(
                "Please enter your access token from heroku website or cli."),
            actions: <Widget>[
              new FlatButton(
                child: new Text(
                  "Close",
                  style: TextStyle(color: Colors.purple),
                ),
                onPressed: () {
                  Navigator.of(context).pop();
                },
              ),
            ],
          );
        },
      );
    }

    // int count = prefs.getInt('TOKEN_COUNT');
    // count = (count == null) ? 1 : (count + 1);
    // prefs.setInt('TOKEN_COUNT', count);
    // prefs.setString('HEROKU_TOKEN_' + count.toString(), token);
    // print(count);
  }

  void _checkPreviousLogin() async {
    final prefs = await SharedPreferences.getInstance();
    var tk = prefs.getString('HEROKU_TOKEN');
    if (tk != null) {
      _loginTextController.text = tk;
    }
  }

  @override
  void initState() {
    super.initState();
    _checkPreviousLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        color: Colors.purple,
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'Enter heroku access token to continue',
                  style: TextStyle(fontSize: 36, color: Colors.white),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(20),
                child: TextField(
                  obscureText: true,
                  style: TextStyle(color: Colors.white),
                  controller: _loginTextController,
                  decoration: InputDecoration(
                      hintText: 'Your access token',
                      hintStyle: TextStyle(color: Colors.white54),
                      fillColor: Colors.white,
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide(width: 1, color: Colors.white54),
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.all(Radius.circular(4)),
                        borderSide: BorderSide(width: 1, color: Colors.white54),
                      )),
                ),
              ),
              FlatButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: EdgeInsets.symmetric(vertical: 15, horizontal: 25),
                child: Text(
                  'Continue',
                  style: TextStyle(color: Colors.purpleAccent, fontSize: 22),
                ),
                color: Colors.white,
                onPressed: () {
                  login(_loginTextController.text);
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
