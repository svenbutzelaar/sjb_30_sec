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
    color: Color.fromARGB(255, 250, 250, 248),
    fontSize: 50,
    fontWeight: FontWeight.bold,
  );

//States: List with countdown + Countdown to new list + Start
  List _words = [];
  List _items = <String>[];
  Random random = Random();

  Timer? countdownTimer;
  Duration timeLeft = const Duration(seconds: 30);

  //List states = <String>["Start", "Countdown30", "Countdown5"];
  String currentState = "Start";

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
      currentState = "Countdown5";
      timeLeft = const Duration(seconds: 5);
    });
      countdownTimer = 
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());    
  }

  void startTimer() {
    setState(() {
      timeLeft = const Duration(seconds: 30);
    });
    countdownTimer =
        Timer.periodic(const Duration(seconds: 1), (_) => setCountDown());
  }

  void setCountDown() {
    setState(() {
      final seconds = timeLeft.inSeconds - 1;


      if (seconds == 0 && currentState == "Countdown30") {
        currentState = "Start";
        playAlarm();
        countdownTimer!.cancel();
      } else if (seconds == 0 && currentState == "Countdown5") {
        currentState = "Countdown30";
        countdownTimer!.cancel();
        refreshWords();
      } else {
        timeLeft = Duration(seconds: seconds);
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
          theme: ThemeData(
          scaffoldBackgroundColor: Color.fromARGB(255, 63, 81, 129),
          fontFamily: 'Roboto',
        ),
        home: Scaffold(
        appBar: AppBar(
        backgroundColor: Color.fromARGB(255, 24, 46, 105),
        title: Text('SJB Seconds', style: style),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(children: [
          if(currentState == "Start")
            ElevatedButton(
                onPressed: readyScreen,
                child: Text('Start!', style: style),
              )            
          else if(currentState == "Countdown30")
            Text(timeLeft.inSeconds.toString(), style: style)
          else
            Text(timeLeft.inSeconds.toString(), style: style),
        
          ListView.separated(
            padding: const EdgeInsets.all(8),
            
            itemBuilder: (BuildContext, index) {
                return Container(
                  height: 50,
                  color: Color.fromARGB(255, 223, 70, 59),
                  //Color.fromARGB(255, 63, 81, 129),
                  child: Center(child: Text(_items[index].toString(),
                  style: const TextStyle(color: Color.fromARGB(255, 250, 250, 248)))),
                );
            },
            itemCount: _items.length,
            shrinkWrap: true,
            separatorBuilder: (BuildContext context, int index) => const Divider(),
          )

        ]),
      ),
    ));
  }
}
