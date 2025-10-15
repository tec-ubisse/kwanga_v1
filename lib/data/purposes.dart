import 'package:kwanga/models/life_area_model.dart';
import 'package:kwanga/models/purpose_model.dart';

enum Area {
  emotion,
  finances,
  health,
  networking,
  family,
  social,
  university,
  professional,
  career,
}

List<Purpose> initialPurposes = [
  Purpose(
    "Contribuir com excelência, ética e"
    "inovação para transformar desafios em"
    " soluções sustentáveis, promovendo "
    "impacto positivo na organização"
    "e na sociedade",
    LifeArea('Profissional', Area.professional.name, 1),1
  ),
];
