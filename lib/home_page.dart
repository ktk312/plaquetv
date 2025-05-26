import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:kosher_dart/kosher_dart.dart';
import 'package:plaquetvapp/network.dart';
import 'package:plaquetvapp/plaque_model.dart';

import 'package:plaquetvapp/plaque_page.dart';
import 'package:shared_preferences/shared_preferences.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  CarouselSliderController carousellController = CarouselSliderController();
  HebrewDateFormatter hebrewDateFormatter = HebrewDateFormatter();
  final textStyle = const TextStyle(fontSize: 32.0, height: 1.5);

  String error = '';
  bool isLoading = false;
  bool hasId = false;

  String website1 = '';
  String website2 = '';
  String website3 = '';

  int count = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    hebrewDateFormatter.hebrewFormat = true;
    initFunc();
  }

  void initFunc() async {
    final id = await getCodeFromStorage();
    if (id == null) {
      hasId = false;
      setState(() {});
    } else {
      hasId = true;
      isLoading = true;
      setState(() {});
      await getPlaquesLatest(id);
      await getWebsites(id);
      _startTimer(id);
      isLoading = false;
      setState(() {});
    }
  }

  Timer? _timer;

  void _startTimer(String id) {
    // Check every 10 minutes (600 seconds)
    _timer = Timer.periodic(Duration(minutes: 10), (timer) {
      getPlaquesLatest(id);
      getWebsites(id);
    });
  }

  getWebsites(String id) async {
    isLoading = true;
    final response = await NetworkCalls().getWebsites(id);
    if (response.contains('Error:')) {
      error = response;
    } else {
      final decodedResponse = jsonDecode(response);
      website1 = decodedResponse['link1'].toString();
      website2 = decodedResponse['link2'].toString();
      website3 = decodedResponse['link3'].toString();

      print(decodedResponse);
      isLoading = false;
      setState(() {});
    }
    isLoading = false;
    setState(() {});
  }

  getPlaquesLatest(String id) async {
    final response = await NetworkCalls().getPlaque(id);
    print(response);

    final resList = plaqueModelFromJson(response);
    DateTime now = DateTime.now();
    DateTime today = DateTime(now.year, now.month, now.day);

    // Calculate the most recent Friday (including today if Friday)
    int daysSinceFriday = (today.weekday - DateTime.friday + 7) % 7;
    DateTime currentFriday = today.subtract(Duration(days: daysSinceFriday));

    // If today is Friday and it's NOT the same as the currentFriday, move to today
    if (today.weekday == DateTime.friday && today.isAfter(currentFriday)) {
      currentFriday = today;
    }

    // Define the 9-day range: Friday to next Sunday (inclusive)
    DateTime rangeStart = currentFriday;
    DateTime rangeEnd =
        rangeStart.add(Duration(days: 9)); // Exclusive of this date

    List<PlaqueModel> nineDayPlaques = resList.where((plaque) {
      DateTime dodDate = DateTime.parse(plaque.dod);
      return !dodDate.isBefore(rangeStart) && dodDate.isBefore(rangeEnd);
    }).toList();

    plaqueList = nineDayPlaques;
    maleList.clear();
    femaleList.clear();
    for (var element in nineDayPlaques) {
      if (element.gender.toUpperCase() == "MALE") {
        maleList.add(element);
      } else {
        femaleList.add(element);
      }
    }
    setState(() {});
  }

  getPlaques(String id) async {
    try {
      DateTime now = DateTime.now();
      DateTime currentWeekStart =
          DateTime(now.year, now.month, now.day - (now.weekday - 1)); // Monday
      DateTime currentWeekEnd =
          DateTime(now.year, now.month, now.day + (7 - now.weekday)); // Sunday

      final response = await NetworkCalls().getPlaque(id);
      print(response);

      final resList = plaqueModelFromJson(response);

      List<PlaqueModel> currentWeekPlaques = resList.where((plaque) {
        DateTime dodDate =
            DateTime.parse(plaque.dod); // Assuming dod is in ISO 8601 format
        return dodDate.isAfter(currentWeekStart.subtract(Duration(days: 1))) &&
            dodDate.isBefore(currentWeekEnd.add(Duration(days: 1)));
      }).toList();

      plaqueList = currentWeekPlaques;

      maleList.clear();
      femaleList.clear();

      for (var element in currentWeekPlaques) {
        if (element.gender.toUpperCase() == "MALE") {
          maleList.add(element);
        } else {
          femaleList.add(element);
        }
      }
      setState(() {});
    } on Exception catch (e) {
      print(e);
    }
  }

  Future<String?> getCodeFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    final code = await prefs.getString('id');
    return code;
  }

  Future<void> setCodeInLocalStorage(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', id);
  }

  Widget getCodeWidget() {
    return Container(
      padding: EdgeInsets.only(left: 30, right: 30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.grey, width: 1)),
              child: TextField(
                decoration: const InputDecoration(
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.all(5)),
                controller: codeController,
              ),
            ),
            SizedBox(
              height: 20,
            ),
            ElevatedButton(
                onPressed: () async {
                  await setCodeInLocalStorage(codeController.text);
                  initFunc();
                },
                child: Container(
                  child: Text('Submit'),
                ))
          ],
        ),
      ),
    );
  }

  final codeController = TextEditingController();

  DateTime now = DateTime.now();

  List<PlaqueModel> plaqueList = [];
  List<PlaqueModel> maleList = [];
  List<PlaqueModel> femaleList = [];

  DateTime getDate(DateTime d) => DateTime(d.year, d.month, d.day);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.sizeOf(context).width,
        height: MediaQuery.sizeOf(context).height,
        child: isLoading
            ? Container(child: Center(child: CircularProgressIndicator()))
            : !isLoading && error != ''
                ? Center(
                    child: Text(error),
                  )
                : !hasId
                    ? getCodeWidget()
                    : CarouselSlider(
                        carouselController: carousellController,
                        disableGesture: true,
                        options: CarouselOptions(
                            viewportFraction: 1,
                            autoPlayInterval: Duration(seconds: 60),
                            // autoPlayAnimationDuration: Duration(seconds: 5),
                            height: MediaQuery.sizeOf(context).height,
                            enableInfiniteScroll: true,
                            autoPlay: true),
                        items: [
                          if (website1 != 'null' && website1 != '')
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: InAppWebView(
                                keepAlive: InAppWebViewKeepAlive(),
                                onWebViewCreated: (controller) {
                                  print('created');
                                },
                                initialUrlRequest:
                                    URLRequest(url: WebUri(website1)),
                              ),
                            ),
                          if (website2 != 'null' && website2 != '')
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: InAppWebView(
                                keepAlive: InAppWebViewKeepAlive(),
                                onWebViewCreated: (controller) {},
                                initialUrlRequest:
                                    URLRequest(url: WebUri(website2)),
                              ),
                            ),
                          PlaquePage(
                            plaqueList: plaqueList,
                            hebrewDateFormatter: hebrewDateFormatter,
                          ),
                          if (website3 != 'null' && website3 != '')
                            Container(
                              width: MediaQuery.of(context).size.width,
                              margin:
                                  const EdgeInsets.symmetric(horizontal: 5.0),
                              child: InAppWebView(
                                keepAlive: InAppWebViewKeepAlive(),
                                onWebViewCreated: (controller) {},
                                initialSettings: InAppWebViewSettings(),
                                initialUrlRequest:
                                    URLRequest(url: WebUri(website3)),
                              ),
                            ),
                        ],
                      ),
      ),
    );
  }
}
