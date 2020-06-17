import 'package:flutter/material.dart';

class LogPage extends StatelessWidget {
  final _controller = ScrollController();
  @override
  Widget build(BuildContext context) {
    final logs =
        ModalRoute.of(context).settings.arguments.toString().split('\n');
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blueGrey,
        child: Icon(Icons.keyboard_arrow_down),
        onPressed: () {
          _controller.jumpTo(_controller.position.maxScrollExtent);
        },
      ),
      backgroundColor: Colors.black,
      body: ListView.builder(
        controller: _controller,
        itemCount: logs.length,
        itemBuilder: (context, i) {
          List<String> l = logs[i].split(': ');
          Color highlight = Colors.greenAccent;
          // Join strings if length > 2
          if (l.length > 2) l[1] = l.sublist(1).join();
          // Highlight color
          if (l[0].contains('router'))
            highlight = Colors.orange;
          else if (l[0].contains('heroku')) highlight = Colors.pinkAccent;
          return RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: l[0] + ' ',
                  style: TextStyle(color: highlight),
                ),
                TextSpan(
                    text: (l.length > 1) ? l[1] : '',
                    style: TextStyle(color: Colors.grey[350])),
              ],
            ),
          );
        },
      ),
    );
  }
}
