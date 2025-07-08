import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:plaquetvapp/plaque_model.dart';
import 'package:plaquetvapp/network.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:plaquetvapp/plaque_page.dart';
import 'package:kosher_dart/kosher_dart.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final HebrewDateFormatter hebrewDateFormatter = HebrewDateFormatter()
    ..hebrewFormat = true;
  final TextEditingController codeController = TextEditingController();

  String error = '';
  bool isLoading = false;
  bool hasId = false;
  String timer = '30';
  List<String> webPages = [];
  String currentUrl = '';
  int currentIndex = 0;
  int currentUrlIndex = 0;
  Timer? _slideTimer;
  InAppWebViewController? webViewController;

  List<PlaqueModel> plaqueList = [];
  List<PlaqueModel> maleList = [];
  List<PlaqueModel> femaleList = [];

  Timer? _dataRefreshTimer;

  @override
  void initState() {
    super.initState();
    initFunc();
  }

  Future<void> initFunc() async {
    final id = await getCodeFromStorage();
    if (id == null) {
      setState(() => hasId = false);
      return;
    }

    setState(() {
      hasId = true;
      isLoading = true;
    });

    await getPlaquesLatest(id);
    // await getWebsites(id);

    setState(() => isLoading = false);
  }

  // Future<void> getWebsites(String id) async {
  //   final response = await NetworkCalls().getWebsites(id);
  //   final decoded = response.contains('Error:')
  //       ? {}
  //       : Map<String, dynamic>.from(jsonDecode(response));
  //   webPages = [decoded['link1'], decoded['link2'], decoded['link3']]
  //       .where(
  //           (url) => url != null && url != 'null' && url.toString().isNotEmpty)
  //       .map((url) => url.toString())
  //       .toList();
  //   timer = decoded['timer']?.toString() ?? '30';

  //   if (webPages.isNotEmpty) {
  //     currentUrl = webPages[0];
  //     currentIndex = 0;
  //     startSlideTimer();
  //   }
  // }
  // void startDataRefreshTimer(String id) {
  //   _dataRefreshTimer?.cancel(); // Clear previous if any
  //   _dataRefreshTimer = Timer.periodic(Duration(minutes: 10), (_) async {
  //     initFunc();
  //   });
  // }

  void startSlideTimer() {
    int interval = int.tryParse(timer) ?? 30;
    _slideTimer?.cancel();
    _slideTimer = Timer.periodic(Duration(seconds: interval), (_) {
      setState(() {
        if (currentIndex == 0) {
          currentUrlIndex++;
          if (currentUrlIndex >= webPages.length) {
            currentIndex = 1;
            currentUrlIndex = 0;
          } else {
            currentUrl = webPages[currentUrlIndex];
            webViewController?.loadUrl(
                urlRequest: URLRequest(url: WebUri(currentUrl)));
          }
        } else {
          currentIndex = 0;
          currentUrl = webPages[0];
          webViewController?.loadUrl(
              urlRequest: URLRequest(url: WebUri(currentUrl)));
        }
      });
    });
  }

  Future<void> getPlaquesLatest(String id) async {
    final response = await NetworkCalls().getPlaque(id);
    final resList = plaqueModelFromJson(response);
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // Step 1: Calculate range from last Friday to upcoming Sunday
    int daysSinceFriday = (today.weekday - DateTime.friday + 7) % 7;
    DateTime rangeStart = today.subtract(Duration(days: daysSinceFriday));
    DateTime rangeEnd =
        rangeStart.add(Duration(days: 9)); // Friday → next Sunday

    // Step 2: Build Hebrew date keys only for dates from TODAY onward
    Set<String> hebrewWeekKeys = {};
    for (int i = 0; i < 9; i++) {
      DateTime gregorianDay = rangeStart.add(Duration(days: i));
      if (gregorianDay.isBefore(today)) continue; // Skip past days

      JewishDate hebrewDay = JewishDate.fromDateTime(gregorianDay);
      hebrewWeekKeys.add(
          "${hebrewDay.getJewishMonth()}-${hebrewDay.getJewishDayOfMonth()}");
    }

    // Step 3: Filter plaques matching the Hebrew dates from today to end of range
    final nineDayPlaques = resList.where((plaque) {
      DateTime dodDate = DateTime.parse(plaque.predate);
      JewishDate dodHebrew = JewishDate.fromDateTime(dodDate);
      String key =
          "${dodHebrew.getJewishMonth()}-${dodHebrew.getJewishDayOfMonth()}";
      return hebrewWeekKeys.contains(key);
    }).toList();

    plaqueList = nineDayPlaques;
    maleList =
        nineDayPlaques.where((e) => e.gender.toUpperCase() == 'MALE').toList();
    femaleList =
        nineDayPlaques.where((e) => e.gender.toUpperCase() != 'MALE').toList();
  }

  Future<String?> getCodeFromStorage() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('id');
  }

  Future<void> setCodeInLocalStorage(String id) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('id', id);
  }

  Widget getCodeWidget() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: TextField(
                controller: codeController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  contentPadding: EdgeInsets.all(5),
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () async {
                await setCodeInLocalStorage(codeController.text);
                initFunc();
              },
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _slideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SizedBox(
        width: MediaQuery.of(context).size.width,
        height: MediaQuery.of(context).size.height,
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : error.isNotEmpty
                ? Center(child: Text(error))
                : !hasId
                    ? getCodeWidget()
                    :
                    // : IndexedStack(
                    //     index: currentIndex,
                    //     children: [
                    // InAppWebView(
                    //   initialUrlRequest:
                    //       URLRequest(url: WebUri(currentUrl)),
                    //   onWebViewCreated: (controller) =>
                    //       webViewController = controller,
                    // ),
                    PlaquePage(
                        plaqueList: plaqueList,
                        hebrewDateFormatter: hebrewDateFormatter,
                      ),
        //   ],
        // ),
      ),
    );
  }
}
