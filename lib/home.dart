import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'utils/heroku.dart';

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = false;

  void onAppMenuSelected(String value, String id, String url) async {
    switch (value) {
      case 'Open in browser':
        if (await canLaunch(url)) {
          await launch(url);
        } else {
          print('Could not launch $url');
        }
        break;
      case 'View log':
        setState(() {
          loading = true;
        });
        var res = await HerokuAPI.instance.getLog(id);
        Navigator.pushNamed(context, '/log', arguments: res);
        break;
      case 'Restart app':
        showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: new Text("Restart Dynos"),
              content: new Text(
                  "This may result in a brief downtime for your application."),
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
                new FlatButton(
                  child: new Text(
                    "Confirm",
                    style: TextStyle(color: Colors.purple),
                  ),
                  onPressed: () {
                    HerokuAPI.instance.restartAllDynos(id);
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
        break;
    }
    setState(() {
      loading = false;
    });
  }

  Widget _buildLoading() {
    return Center(
      child: SpinKitRotatingCircle(
        color: Colors.white,
        size: 50.0,
      ),
    );
  }

  Widget _buildListView() {
    return FutureBuilder(
      builder: (context, appSnap) {
        if (appSnap.connectionState == ConnectionState.none &&
            appSnap.hasData == null) {
          return Text('App list is empty.');
        }
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 10),
          child: ListView.builder(
            itemCount: (appSnap.data != null) ? appSnap.data.length : 0,
            itemBuilder: (context, index) {
              return Container(
                margin: EdgeInsets.only(bottom: 5),
                decoration: BoxDecoration(
                  color: Colors.deepPurple[500],
                  shape: BoxShape.rectangle,
                  borderRadius: BorderRadius.all(
                    Radius.circular(5),
                  ),
                ),
                child: Padding(
                    padding: EdgeInsets.only(top: 5, bottom: 15, left: 15),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: <Widget>[
                            Text(
                              appSnap.data[index]['name'],
                              style: TextStyle(
                                fontSize: 22,
                                color: Colors.white,
                              ),
                            ),
                            PopupMenuButton<String>(
                              icon: Icon(Icons.more_vert, color: Colors.white),
                              onSelected: (selected) {
                                onAppMenuSelected(
                                    selected,
                                    appSnap.data[index]['id'],
                                    appSnap.data[index]['web_url']);
                              },
                              itemBuilder: (BuildContext context) {
                                return {
                                  'Open in browser',
                                  'View log',
                                  'Restart app'
                                }.map((String choice) {
                                  return PopupMenuItem<String>(
                                    value: choice,
                                    child: Text(choice),
                                  );
                                }).toList();
                              },
                            ),
                          ],
                        ),
                        Text(
                          appSnap.data[index]['id'],
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                        ),
                        Text(
                          'Latest release: ' +
                              appSnap.data[index]['released_at'],
                          style: TextStyle(
                            color: Colors.grey[400],
                          ),
                        ),
                      ],
                    )),
              );
            },
          ),
        );
      },
      future: HerokuAPI.instance.getApps(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.deepPurple[900],
      body: (loading == true) ? _buildLoading() : _buildListView(),
    );
  }
}
