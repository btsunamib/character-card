import 'package:equatable/equatable.dart';

class CharacterCard extends Equatable {
  final String id;
  final String name;
  final String description;
  final String personality;
  final String scenario;
  final String firstMessage;
  final String exampleDialogue;
  final List<WorldbookEntry> worldbook;
  final CharacterExtensions extensions;
  final DateTime createdAt;
  final DateTime? updatedAt;

  const CharacterCard({
    required this.id,
    required this.name,
    required this.description,
    required this.personality,
    required this.scenario,
    required this.firstMessage,
    required this.exampleDialogue,
    required this.worldbook,
    required this.extensions,
    required this.createdAt,
    this.updatedAt,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'description': description,
      'personality': personality,
      'scenario': scenario,
      'first_message': firstMessage,
      'example_dialogue': exampleDialogue,
      'worldbook': worldbook.map((e) => e.toJson()).toList(),
      'extensions': extensions.toJson(),
    };
  }

  factory CharacterCard.fromJson(Map<String, dynamic> json) {
    return CharacterCard(
      id: json['id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      personality: json['personality'] ?? '',
      scenario: json['scenario'] ?? '',
      firstMessage: json['first_message'] ?? '',
      exampleDialogue: json['example_dialogue'] ?? '',
      worldbook: (json['worldbook'] as List<dynamic>?)
              ?.map((e) => WorldbookEntry.fromJson(e))
              .toList() ??
          [],
      extensions: json['extensions'] != null
          ? CharacterExtensions.fromJson(json['extensions'])
          : const CharacterExtensions(),
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  CharacterCard copyWith({
    String? id,
    String? name,
    String? description,
    String? personality,
    String? scenario,
    String? firstMessage,
    String? exampleDialogue,
    List<WorldbookEntry>? worldbook,
    CharacterExtensions? extensions,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return CharacterCard(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      personality: personality ?? this.personality,
      scenario: scenario ?? this.scenario,
      firstMessage: firstMessage ?? this.firstMessage,
      exampleDialogue: exampleDialogue ?? this.exampleDialogue,
      worldbook: worldbook ?? this.worldbook,
      extensions: extensions ?? this.extensions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        personality,
        scenario,
        firstMessage,
        exampleDialogue,
        worldbook,
        extensions,
        createdAt,
        updatedAt,
      ];
}

class WorldbookEntry extends Equatable {
  final String name;
  final String content;
  final List<String> keywords;
  final bool enabled;

  const WorldbookEntry({
    required this.name,
    required this.content,
    required this.keywords,
    this.enabled = true,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'content': content,
      'keywords': keywords,
      'enabled': enabled,
    };
  }

  factory WorldbookEntry.fromJson(Map<String, dynamic> json) {
    return WorldbookEntry(
      name: json['name'] ?? '',
      content: json['content'] ?? '',
      keywords: (json['keywords'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      enabled: json['enabled'] ?? true,
    );
  }

  @override
  List<Object?> get props => [name, content, keywords, enabled];
}

class CharacterExtensions extends Equatable {
  final String? avatar;
  final List<String> tags;
  final Map<String, dynamic>? additionalData;

  const CharacterExtensions({
    this.avatar,
    this.tags = const [],
    this.additionalData,
  });

  Map<String, dynamic> toJson() {
    final map = <String, dynamic>{};
    if (avatar != null && avatar!.isNotEmpty) {
      map['avatar'] = avatar;
    }
    if (tags.isNotEmpty) {
      map['tags'] = tags;
    }
    if (additionalData != null) {
      map.addAll(additionalData!);
    }
    return map;
  }

  factory CharacterExtensions.fromJson(Map<String, dynamic> json) {
    return CharacterExtensions(
      avatar: json['avatar']?.toString(),
      tags: (json['tags'] as List<dynamic>?)
              ?.map((e) => e.toString())
              .toList() ??
          [],
      additionalData: json,
    );
  }

  @override
  List<Object?> get props => [avatar, tags, additionalData];
}
