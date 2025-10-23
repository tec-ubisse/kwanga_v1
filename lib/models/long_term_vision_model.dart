import 'package:kwanga/models/user.dart';
import 'package:kwanga/models/life_area_model.dart';

class LongTermVision {
  int user_id; // foreign key
  LifeArea lifeArea;
  String designation;
  String deadline;
  String status;

  LongTermVision(
    this.user_id,
    this.lifeArea,
    this.designation,
    this.deadline,
    this.status,
  );
}
