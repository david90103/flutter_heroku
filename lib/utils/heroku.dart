import 'dart:convert';
import "package:collection/collection.dart";
import 'package:http/http.dart' as http;

class HerokuAPI {
  static final HerokuAPI _instance = HerokuAPI._internal();
  final client = http.Client();
  String token;

  factory HerokuAPI() {
    return _instance;
  }

  static HerokuAPI get instance {
    return _instance;
  }

  Map<String, String> _buildHeaders() {
    return {
      'Authorization': "Bearer $token",
      'Accept': 'application/vnd.heroku+json; version=3'
    };
  }

  Future<bool> checkAccount(t) async {
    token = t;
    try {
      var res = await client.get(
        "https://api.heroku.com/account",
        headers: _buildHeaders(),
      );
      if (res.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  Future<List> getApps() async {
    if (token.isEmpty) throw Exception('Heroku Token is empty.');
    try {
      var res = await client.get(
        "https://api.heroku.com/apps",
        headers: _buildHeaders(),
      );
      if (res.statusCode == 200) {
        List list = jsonDecode(res.body);
        list.sort((a, b) =>
            compareAsciiUpperCase(b['released_at'], a['released_at']));
        return list;
      }
    } catch (e) {
      print(e);
    }
    return List();
  }

  Future<List> getDynos(appid) async {
    if (token.isEmpty) throw Exception('Heroku Token is empty.');
    try {
      var res = await client.get(
        "https://api.heroku.com/apps/$appid/dynos",
        headers: _buildHeaders(),
      );
      if (res.statusCode == 200) {
        return jsonDecode(res.body);
      }
    } catch (e) {
      print(e);
    }
    return List();
  }

  Future<String> getLog(appid) async {
    if (token.isEmpty) throw Exception('Heroku Token is empty.');
    try {
      var res = await client.post(
          "https://api.heroku.com/apps/$appid/log-sessions",
          headers: _buildHeaders(),
          body: {
            'lines': '1000',
          });
      var log = await client.get(jsonDecode(res.body)['logplex_url']);
      if (log.statusCode == 200) {
        return log.body;
      }
    } catch (e) {
      print(e);
    }
    return '';
  }

  Future<bool> restartAllDynos(appid) async {
    if (token.isEmpty) throw Exception('Heroku Token is empty.');
    try {
      var res = await client.delete(
        "https://api.heroku.com/apps/$appid/dynos",
        headers: _buildHeaders(),
      );
      if (res.statusCode == 200) {
        return true;
      }
    } catch (e) {
      print(e);
    }
    return false;
  }

  HerokuAPI._internal();
}
