import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:plaquetvapp/home_page.dart';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
// import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:webview_flutter/webview_flutter.dart';

// WebViewEnvironment? webViewEnvironment;
// final keepAlive = InAppWebViewKeepAlive();

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // if (!kIsWeb && defaultTargetPlatform == TargetPlatform.windows) {
  //   final availableVersion = await WebViewEnvironment.getAvailableVersion();
  //   assert(availableVersion != null,
  //       'Failed to find an installed WebView2 Runtime or non-stable Microsoft Edge installation.');

  //   webViewEnvironment = await WebViewEnvironment.create(
  //       settings:
  //           WebViewEnvironmentSettings(userDataFolder: 'YOUR_CUSTOM_PATH'));
  // }

  // if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
  //   await InAppWebViewController.setWebContentsDebuggingEnabled(kDebugMode);
  // }

  runApp(const MaterialApp(home: MyApp()));
}

// class MyApp extends StatefulWidget {
//   const MyApp({super.key});

//   @override
//   State<MyApp> createState() => _MyAppState();
// }

// class _MyAppState extends State<MyApp> {
//   final chatWebViewController = WebViewController()
//     ..setJavaScriptMode(JavaScriptMode.unrestricted)
//     ..loadRequest(Uri.parse('https://deadsimplechat.com/IyL5YkDM3'));

//   final youtubeVideoWebViewController = WebViewController()
//     ..setJavaScriptMode(JavaScriptMode.unrestricted)
//     ..loadRequest(Uri.parse('https://www.youtube.com/embed/nA9UZF-SZoQ'));

//   var items = [];

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text("Flutter WebView"),
//       ),
//       body:
//           // Row(
//           //   children: [
//           CarouselSlider(
//         options: CarouselOptions(height: 400.0),
//         items: [1, 2, 3, 4, 5].map((i) {
//           return Builder(
//             builder: (BuildContext context) {
//               return Container(
//                   width: MediaQuery.of(context).size.width,
//                   margin: const EdgeInsets.symmetric(horizontal: 5.0),
//                   decoration: const BoxDecoration(color: Colors.amber),
//                   child: Text(
//                     'text $i',
//                     style: const TextStyle(fontSize: 16.0),
//                   ));
//             },
//           );
//         }).toList(),
//       ),
//       //   Container(
//       //       height: 270,
//       //       width: MediaQuery.sizeOf(context).width / 2.2,
//       //       child:
//       //           WebViewWidget(controller: youtubeVideoWebViewController)),
//       //   Container(
//       //     height: 540,
//       //     width: MediaQuery.sizeOf(context).width / 2.2,
//       //     child: WebViewWidget(controller: chatWebViewController),
//       //   )
//       // ],
//       // )
//     );
//   }
// }

// class MyApp extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       home: CarouselWebView(),
//     );
//   }
// }

// class CarouselWebView extends StatefulWidget {
//   @override
//   _CarouselWebViewState createState() => _CarouselWebViewState();
// }

// class _CarouselWebViewState extends State<CarouselWebView> {
//   InAppWebViewController? webViewController;

//   final List<String> links = [
//     'https://66d2eb3f7f08f4ecc2b2ffef--monumental-biscuit-20a6d6.netlify.app/#/minified:qP'
//   ];

//   @override
//   Widget build(BuildContext context) {
//     String carouselHTML = """

//     <!DOCTYPE html>
//     <html lang="en">
//     <head>
//         <meta charset="UTF-8">
//         <meta name="viewport" content="width=device-width, initial-scale=1.0">
//         <title>Circular URL Carousel Slider</title>
//         <style>
//             * {
//                 box-sizing: border-box;
//             }
//             body {
//                 font-family: Arial, sans-serif;
//                 margin: 0;
//                 padding: 0;
//             }
//             .carousel-container {
//                 width: 100%;
//                 max-width: 600px;
//                 margin: 50px auto;
//                 position: relative;
//                 overflow: hidden;
//             }
//             .carousel-slide {
//                 display: flex;
//                 transition: transform 0.5s ease-in-out;
//                 width: 100%;
//             }
//             .carousel-item {
//                 min-width: 100%;
//                 box-shadow: 0 4px 8px rgba(0, 0, 0, 0.1);
//             }
//             iframe {
//                 width: 100%;
//                 height: 400px;
//                 border: none;
//             }
//             .prev, .next {
//                 position: absolute;
//                 top: 50%;
//                 transform: translateY(-50%);
//                 background-color: rgba(0, 0, 0, 0.5);
//                 color: white;
//                 border: none;
//                 padding: 10px;
//                 cursor: pointer;
//             }
//             .prev {
//                 left: 0;
//             }
//             .next {
//                 right: 0;
//             }
//         </style>
//     </head>
//     <body>

//     <div class="carousel-container">
//         <div class="carousel-slide" id="carousel-slide">
//             <div class="carousel-item">
//                 <iframe src="https://www.example.com"></iframe>
//             </div>
//             <div class="carousel-item">
//                 <iframe src="${links[0]}"></iframe>
//             </div>
//             <div class="carousel-item">
//                 <iframe src="https://www.yetanotherexample.com"></iframe>
//             </div>
//         </div>
//         <button class="prev" onclick="moveSlide(-1)">&#10094;</button>
//         <button class="next" onclick="moveSlide(1)">&#10095;</button>
//     </div>

//     <script>
//         let slideIndex = 0;
//         const totalSlides = document.querySelectorAll('.carousel-item').length;

//         function moveSlide(direction) {
//             const carouselSlide = document.getElementById('carousel-slide');
//             slideIndex += direction;

//             // Circular behavior for the carousel
//             if (slideIndex < 0) {
//                 slideIndex = totalSlides - 1; // Go to last slide if reaching before the first one
//             } else if (slideIndex >= totalSlides) {
//                 slideIndex = 0; // Go to the first slide if reaching after the last one
//             }

//             const slideWidth = carouselSlide.clientWidth;
//             carouselSlide.style.transform = `translateX(-\${slideWidth * slideIndex}px)`;
//         }

//         // Optional: Auto-slide every 5 seconds
//         setInterval(() => {
//             moveSlide(1);
//         }, 5000);
//     </script>

//     </body>
//     </html>
//     """;

//     return Scaffold(
//       appBar: AppBar(
//         title: Text('Carousel in WebView'),
//       ),
//       body: InAppWebView(
//         initialData: InAppWebViewInitialData(
//           data: carouselHTML,
//           mimeType: 'text/html',
//           encoding: 'utf-8',
//         ),
//         onWebViewCreated: (controller) {
//           webViewController = controller;
//         },
//       ),
//     );
//   }
// }

// class PageA extends StatelessWidget {
//   const PageA({super.key});

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Page A - Keep Alive Example'),
//         actions: [
//           ElevatedButton(
//               onPressed: () {
//                 // Navigator.of(context).pushReplacement(
//                 //   MaterialPageRoute(
//                 //     builder: (context) => const PageB(),
//                 //   ),
//                 // );
//               },
//               child: const Text('Go To Page B'))
//         ],
//       ),
//       body: Row(children: <Widget>[
//         SizedBox(
//           height: 300,
//           width: MediaQuery.sizeOf(context).width / 2.2,
//           child: InAppWebView(
//             webViewEnvironment: webViewEnvironment,
//             keepAlive: keepAlive,
//             initialUrlRequest:
//                 URLRequest(url: WebUri("http://github.com/flutter")),
//             initialSettings: InAppWebViewSettings(
//               isInspectable: kDebugMode,
//             ),
//           ),
//         ),
//         // SizedBox(
//         //   height: 300,
//         //   width: MediaQuery.sizeOf(context).width / 2.2,
//         //   child: InAppWebView(
//         //     webViewEnvironment: webViewEnvironment,
//         //     keepAlive: keepAlive,
//         //     initialUrlRequest:
//         //         URLRequest(url: WebUri("http://github.com/flutter")),
//         //     initialSettings: InAppWebViewSettings(
//         //       isInspectable: kDebugMode,
//         //     ),
//         //   ),
//         // )
//       ]),
//     );
//   }
// }

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        useMaterial3: true,
      ),
      home: const HomePage(),
    );
  }
}
