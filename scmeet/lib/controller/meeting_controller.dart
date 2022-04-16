import 'package:get/get.dart';
import 'package:scmeet/model/user.dart';

class MeetingController extends GetxController {

  int connectionLength = 0;

  List<User> allUsers = [];

  RxMap odResults = {}.obs;

  int? port;

  updateOdResults(Map<String,int> results) {
    results.forEach((key, val) {
      if (odResults.containsKey(key)) {
        odResults.update(key,
            (value) => val);
      } else {
        odResults.putIfAbsent(
            key, () => val);
      }
    });
  }


}