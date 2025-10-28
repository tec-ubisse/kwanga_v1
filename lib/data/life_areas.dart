import '../models/life_area_model.dart';
import 'package:uuid/uuid.dart';

final _uuid = Uuid();

List<LifeArea> initialLifeAreas = [
  LifeArea('Acadêmica', "university", _uuid.v4(),userId: 0, isDefault: true, isSynced: false),
  LifeArea('Profissional', "professional", _uuid.v4(),userId: 0, isDefault: true, isSynced: false),
  LifeArea('Carreira', "career", _uuid.v4(),userId: 0,  isDefault: true, isSynced: false),
  LifeArea('Networking', "networking", _uuid.v4(),userId: 0,  isDefault: true, isSynced: false),
  LifeArea('Família', "family", _uuid.v4(),userId: 0,  isDefault: true, isSynced: false),
  LifeArea('Financeira', "finances", _uuid.v4(),userId: 0,  isDefault: true, isSynced: false),
  LifeArea('Saúde', "health", _uuid.v4(),userId: 0,  isDefault: true, isSynced: false),
  LifeArea('Emocional', "emotion", _uuid.v4(),userId: 0,  isDefault: true, isSynced: false),
];