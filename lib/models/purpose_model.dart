import 'package:kwanga/models/life_area_model.dart';

class Purpose {
  final int id;
  final LifeArea lifeArea;
  final String description;

  Purpose(this.description, this.lifeArea, this.id);
}