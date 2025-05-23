import 'package:http/http.dart' as http;

class NetworkCalls {
  Future<String> getPlaque(String userID) async {
    String returnString = '';

    try {
      var url =
          Uri.parse('https://bsdjudaica.com/plaq/tv/postPlaque.php?id=$userID');
      print(url);

      http.Response res = await http.get(url);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        returnString = res.body;
      } else {
        returnString = "Error: ${res.reasonPhrase.toString()}";
      }
    } on Exception catch (e) {
      print(e);
    }
    return returnString;
  }

  Future<String> getWebsites(String userID) async {
    String returnString = '';

    try {
      var url =
          Uri.parse('https://bsdjudaica.com/plaq/tv/links.php?id=$userID');
      print(url);
      http.Response res = await http.get(url);

      if (res.statusCode >= 200 && res.statusCode < 300) {
        returnString = res.body;
      } else {
        returnString = "Error: ${res.reasonPhrase.toString()}";
      }
    } on Exception catch (e) {
      print(e);
    }
    return returnString;
  }
}
