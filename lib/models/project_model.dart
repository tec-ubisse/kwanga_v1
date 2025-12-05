import 'package:uuid/uuid.dart';

class ProjectModel {
  final String id;
  final int userId;
  final String monthlyGoalId;

  final String title;
  final String purpose;
  final String expectedResult;

  final List<String> brainstormIdeas;
  final String? firstAction;

  final bool isDeleted;
  final bool isSynced;

  ProjectModel({
    String? id,
    required this.userId,
    required this.monthlyGoalId,
    required this.title,
    required this.purpose,
    required this.expectedResult,
    this.brainstormIdeas = const [],
    this.firstAction,
    required this.isDeleted,
    required this.isSynced,
  }) : id = id ?? const Uuid().v4();

  /// Modelo "vazio" — usado para dropdowns ou estados temporários
  static ProjectModel empty(String monthlyGoalId) {
    return ProjectModel(
      id: "empty-$monthlyGoalId",
      userId: -1,
      monthlyGoalId: monthlyGoalId,
      title: "",
      purpose: "",
      expectedResult: "",
      brainstormIdeas: const [],
      firstAction: null,
      isDeleted: false,
      isSynced: false,
    );
  }

  bool get isEmpty => id.startsWith("empty-");
  bool get isNotEmpty => !isEmpty;

  ProjectModel copyWith({
    String? id,
    int? userId,
    String? monthlyGoalId,
    String? title,
    String? purpose,
    String? expectedResult,
    List<String>? brainstormIdeas,
    String? firstAction,
    bool? isDeleted,
    bool? isSynced,
  }) {
    return ProjectModel(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      monthlyGoalId: monthlyGoalId ?? this.monthlyGoalId,
      title: title ?? this.title,
      purpose: purpose ?? this.purpose,
      expectedResult: expectedResult ?? this.expectedResult,
      brainstormIdeas: brainstormIdeas ?? List.from(this.brainstormIdeas),
      firstAction: firstAction ?? this.firstAction,
      isDeleted: isDeleted ?? this.isDeleted,
      isSynced: isSynced ?? this.isSynced,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'user_id': userId,
      'monthly_goal_id': monthlyGoalId,
      'title': title,
      'purpose': purpose,
      'expected_result': expectedResult,
      'brainstorm_ideas': brainstormIdeas,
      'first_action': firstAction,
      'is_deleted': isDeleted ? 1 : 0,
      'is_synced': isSynced ? 1 : 0,
    };
  }

  factory ProjectModel.fromMap(Map<String, dynamic> map) {
    return ProjectModel(
      id: map['id'] as String,
      userId: map['user_id'] as int,
      monthlyGoalId: map['monthly_goal_id'] as String,
      title: map['title'] as String? ?? "",
      purpose: map['purpose'] as String? ?? "",
      expectedResult: map['expected_result'] as String? ?? "",
      brainstormIdeas: (map['brainstorm_ideas'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList() ??
          [],
      firstAction: map['first_action'] as String?,
      isDeleted: (map['is_deleted'] ?? 0) == 1,
      isSynced: (map['is_synced'] ?? 0) == 1,
    );
  }
}
