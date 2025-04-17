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
      await getPlaques(id);
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
      getPlaques(id);
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
      website1 = decodedResponse['link1'];
      website2 = decodedResponse['link2'];
      website3 = decodedResponse['link3'];
      print(decodedResponse);
      isLoading = false;
      setState(() {});
    }
    isLoading = false;
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
            ? CircularProgressIndicator()
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
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
                            child: InAppWebView(
                              keepAlive: InAppWebViewKeepAlive(),
                              onWebViewCreated: (controller) {
                                print('created');
                              },
                              initialUrlRequest:
                                  URLRequest(url: WebUri(website1)),
                            ),
                          ),
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
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
                          Container(
                            width: MediaQuery.of(context).size.width,
                            margin: const EdgeInsets.symmetric(horizontal: 5.0),
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
