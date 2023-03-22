import 'dart:async';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  runApp(const MyApp());
}

class Controller extends GetxController {
  var next = 1.obs;
  increment() => next++;
  List<int> numberList = [for (var i = 1; i <= 25; i++) i]..shuffle();
  // RxInt score = 1.obs;
  // RxInt previousScore = 1.obs;
  // RxInt bestScore = 10000.obs;
  // RxDouble difference = 1.1.obs;
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      home: const MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  //String screen_width = MediaQuery.of(context).size.width.toString();
  final stopwatch = Stopwatch();
  late Timer _timer;

  @override
  void initState() {
    // TODO: implement initState
    stopwatch.start();
    _timer = new Timer.periodic(new Duration(milliseconds: 200), (timer) {
      setState(() {});
    });
    super.initState();
  }

  final Controller c = Get.put(Controller());
  @override
  Widget build(BuildContext context) {
    int elapsed = stopwatch.elapsedMilliseconds ~/ 100;

    void handleScore() async {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      // c.previousScore = c.score;
      // c.score = elapsed.obs;
      // if (c.score.toInt() < c.bestScore.toInt()) {
      //   c.bestScore = c.score;
      // }
      // c.difference = ((c.previousScore.toInt() - c.score.toInt()) /
      //         c.previousScore.toInt() *
      //         100)
      //     .obs;
      late int tempPrev, tempScore, tempBest;
      late double tempDiff;
      prefs.get("previous") == null
          ? tempPrev = 1
          : tempPrev = prefs.getInt("previous")!;
      prefs.get("best") == null
          ? tempBest = 10000
          : tempBest = prefs.getInt("best")!;
      prefs.get("score") == null
          ? tempScore = 1
          : tempScore = prefs.getInt("score")!;
      prefs.get("difference") == null
          ? tempDiff = 1
          : tempDiff = prefs.getDouble("difference")!;

      tempPrev = tempScore;
      tempScore = elapsed;
      if (tempScore < tempBest) {
        tempBest = tempScore;
      }
      tempDiff = (tempPrev - tempScore) / tempPrev * 100;

      prefs.setInt("previous", tempPrev);
      prefs.setInt("best", tempBest);
      prefs.setInt("score", tempScore);
      prefs.setDouble("difference", tempDiff);
    }

    void finish() {
      c.next = 1.obs;
      c.numberList.shuffle();
      handleScore();
      Get.to(() => ResultPage());
    }

    void increment() {
      c.next + 1 == 26 ? finish() : null;
    }

    return Scaffold(
        appBar: AppBar(backgroundColor: Colors.white, actions: [
          IconButton(
              onPressed: null /* RestartGame() */,
              icon: Icon(
                Icons.restart_alt,
                color: Colors.black54,
                size: 40,
              ))
        ]),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
                color: Colors.deepPurpleAccent,
                child: Text("Time:      ${elapsed ~/ 10}",
                    style: TextStyle(color: Colors.white),
                    textScaleFactor: 1.6),
                width: MediaQuery.of(context).size.width-40,
                height: 35,
                padding: EdgeInsets.only(top: 3, left: MediaQuery.of(context).size.width-200)),
            Container(
              color: Colors.black87,
              child: Obx((() => Text("Next:      ${c.next}",
                  style: TextStyle(color: Colors.white),
                  textScaleFactor: 1.6))),
              width: MediaQuery.of(context).size.width-40,
              height: 35,
              padding: EdgeInsets.only(top: 3, left: MediaQuery.of(context).size.width-200),
            ),
            SizedBox(
              height: 40,
            ),
            for (int j = 0; j < 5; j++)
              Row(
                children: [
                  for (int i = 0; i < 5; i++)
                    Container(
                      color: (j + i) % 2 == 0
                          ? Colors.deepPurple
                          : Colors.deepPurpleAccent,
                      width: MediaQuery.of(context).size.width / 5,
                      height: 70,
                      child: InkWell(
                        child: Center(
                            child: Text(
                          c.numberList[5 * j + i].toString(),
                          style: TextStyle(
                              fontSize: 35,
                              color: c.numberList[5 * j + i] < c.next.toInt()
                                  ? Colors.white70
                                  : Colors.white),
                        )),
                        onTap: (() {
                          c.numberList[5 * j + i] == c.next.toInt()
                              ? increment()
                              : null;
                          print(5 * j + i);
                          print(c.next);
                        }),
                      ),
                    ),
                ],
              ),
          ],
        ));
  }
}

class ResultPage extends StatefulWidget {
  const ResultPage({super.key});

  @override
  State<ResultPage> createState() => _ResultPageState();
}

class _ResultPageState extends State<ResultPage> {
  int best = 1, prev = 1, score = 1;
  late double diff = 1.1;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    readSharedPreferences();
  }

  Future<void> readSharedPreferences() async {
    var sharedPreferences = await SharedPreferences.getInstance();
    best = sharedPreferences.getInt("best") ?? 0;
    prev = sharedPreferences.getInt("previous") ?? 0;
    score = sharedPreferences.getInt("score") ?? 0;
    diff = sharedPreferences.getDouble("difference") ?? 0.0;
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          children: [
            Container(
                padding: EdgeInsets.only(top: 140),
                height: 200,
                width: MediaQuery.of(context).size.width-40,
                child: Container(
                  color: Colors.lightBlue,
                  child: Center(
                    child: Text(
                      "Best result : ${best == 1000 ? "not set yet" : best / 10}",
                      textScaleFactor: 1.7,
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                )),
            Container(
              padding: EdgeInsets.only(top: 60),
              height: 150,
              child: Text(
                "Result:  ${score / 10}s  ${prev == 0.1 ? "--" : diff.toStringAsFixed(2)}%",
                textScaleFactor: 1.8,
                style: TextStyle(color: Colors.lightGreen),
              ),
            ),
            Container(
              color: Colors.lightBlue,
              width: MediaQuery.of(context).size.width-40,
              height: 60,
              child: Center(
                child: Text(
                  "Previous result: ${prev / 10}s",
                  textScaleFactor: 1.4,
                  style: TextStyle(color:Colors.white),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.only(top: 100),
              child: ElevatedButton(
                child: Text("Continue"),
                onPressed: () => Get.to(MyHomePage()),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
