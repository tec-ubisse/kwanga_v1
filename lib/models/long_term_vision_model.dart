import 'package:kwanga/models/user.dart';
import 'package:kwanga/models/life_area_model.dart';

class LongTermVision {
  User user;
  LifeArea lifeArea;
  String designation;
  String deadline;
  String status;

  LongTermVision(
    this.user,
    this.lifeArea,
    this.designation,
    this.deadline,
    this.status,
  );
}
