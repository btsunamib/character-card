import 'package:flutter_test/flutter_test.dart';
import 'package:sillytavern_card_generator/data/models/character_card_model.dart';

void main() {
  group('CharacterCard', () {
    test('should create CharacterCard from JSON', () {
      final json = {
        'name': 'Test Character',
        'description': 'A test character',
        'personality': 'Friendly',
        'scenario': 'Fantasy world',
        'first_message': 'Hello!',
        'example_dialogue': 'Hi there!',
        'worldbook': [
          {
            'name': 'Magic',
            'content': 'Magic exists here',
            'keywords': ['spell', 'wizard'],
            'enabled': true,
          }
        ],
        'extensions': {
          'avatar': 'https://example.com/avatar.png',
          'tags': ['fantasy', 'mage'],
        },
      };

      final card = CharacterCard.fromJson(json);

      expect(card.name, 'Test Character');
      expect(card.description, 'A test character');
      expect(card.personality, 'Friendly');
      expect(card.worldbook.length, 1);
      expect(card.worldbook[0].name, 'Magic');
      expect(card.extensions.avatar, 'https://example.com/avatar.png');
    });

    test('should convert CharacterCard to JSON', () {
      final card = CharacterCard(
        id: 'test-id',
        name: 'Test Character',
        description: 'A test character',
        personality: 'Friendly',
        scenario: 'Fantasy world',
        firstMessage: 'Hello!',
        exampleDialogue: 'Hi there!',
        worldbook: const [
          WorldbookEntry(
            name: 'Magic',
            content: 'Magic exists here',
            keywords: ['spell', 'wizard'],
            enabled: true,
          )
        ],
        extensions: const CharacterExtensions(
          avatar: 'https://example.com/avatar.png',
          tags: ['fantasy', 'mage'],
        ),
        createdAt: DateTime(2024, 1, 1),
      );

      final json = card.toJson();

      expect(json['name'], 'Test Character');
      expect(json['worldbook'], isA<List>());
      expect((json['worldbook'] as List).length, 1);
    });

    test('should handle empty worldbook', () {
      final json = {
        'name': 'Test Character',
        'description': 'A test character',
      };

      final card = CharacterCard.fromJson(json);

      expect(card.worldbook, isEmpty);
    });
  });

  group('WorldbookEntry', () {
    test('should create WorldbookEntry from JSON', () {
      final json = {
        'name': 'Location',
        'content': 'A mysterious cave',
        'keywords': ['cave', 'dark', 'monster'],
        'enabled': false,
      };

      final entry = WorldbookEntry.fromJson(json);

      expect(entry.name, 'Location');
      expect(entry.content, 'A mysterious cave');
      expect(entry.keywords, ['cave', 'dark', 'monster']);
      expect(entry.enabled, false);
    });

    test('should convert WorldbookEntry to JSON', () {
      const entry = WorldbookEntry(
        name: 'Location',
        content: 'A mysterious cave',
        keywords: ['cave', 'dark'],
        enabled: true,
      );

      final json = entry.toJson();

      expect(json['name'], 'Location');
      expect(json['keywords'], ['cave', 'dark']);
    });
  });
}
