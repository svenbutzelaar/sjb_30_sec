import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:csv/csv.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'dart:math';

void main() {
  runApp(const MyHomePage());
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key}) : super(key: key);

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  TextStyle style = const TextStyle(
    fontSize: 50,
    fontWeight: FontWeight.bold,
  );

  List _words = [];
  List _items = <String>[];
  Random random = Random();

  Timer? countdownTimer;
  Duration timeLeft = const Duration(seconds: 30);
  bool counting = false;
  bool waiting = false;

  Future<List> readCSV() async {
    final String response =
        await rootBundle.loadString('assets/sint_jansbrug_words.csv');
    final List<List> csv = const CsvToListConverter().convert(response);
    return csv.expand((i) => i).toList();
  }

  Future<void> refreshWords() async {
    _items = [];
    if (_words.length < 5) _words = await readCSV();
    setState(() {
      for (var i = 0; i < 5; i++) {
        int randomIndex = random.nextInt(_words.length);
        _items.add(_words.removeAt(randomIndex));
      }
    });
    startTimer();
  }

  void readyScreen() {
    setState(() {
      waiting = true;
      counting = false;
      timeLeft = const Duration(seconds: 5);
    });
      countdownTimer = 
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());    
  }

  void startTimer() {
    setState(() {
      waiting = false;
      counting = true;
      timeLeft = const Duration(seconds: 30);
    });
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    setState(() {
      final seconds = timeLeft.inSeconds - 1;
      if (seconds == 0 && waiting == false) {
        counting = false;
        playAlarm();
        countdownTimer!.cancel();
      } else if (seconds == 0 && waiting == true) {
        waiting = false;
        countdownTimer!.cancel();
        refreshWords();
      } else {
        timeLeft = Duration(seconds: seconds);
        counting = true;
      }
    });
  }

  Future<void> playAlarm() async {
    final player = AudioPlayer();
    await player.setSource(AssetSource('alarm.wav'));
    await player.resume();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        home: Scaffold(
      appBar: AppBar(
        title: const Text('SJB Seconds'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          
          if (counting) Text(timeLeft.inSeconds.toString(), style: style),
          if (!counting)
            if (!waiting)
              ElevatedButton(
                onPressed: readyScreen,
                child: Text('Start!', style: style),
              ),
            if(waiting)
              Text(timeLeft.inSeconds.toString(), style: style),

          ListView.separated(
            padding: const EdgeInsets.all(8),
            
            itemBuilder: (BuildContext, index) {
                return Container(
                  height: 50,
                  color: Color.fromARGB(246, 14, 5, 100),
                  child: Center(child: Text(_items[index].toString(),
                  style: const TextStyle(color: Color.fromARGB(255, 250, 250, 248)))),
                );
            },
            itemCount: _items.length,
            shrinkWrap: true,
            separatorBuilder: (BuildContext context, int index) => const Divider(),
          )
          
          /*
          ListView.builder(
            itemBuilder: (BuildContext, index) {
              return Text(_items[index].toString(),
                  style: const TextStyle(fontSize: 25));
            },
            itemCount: _items.length,
            shrinkWrap: true,
          )*/

        ]),
      ),
    ));
  }
}
