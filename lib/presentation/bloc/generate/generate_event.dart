import 'package:equatable/equatable.dart';
import '../../../data/models/character_card_model.dart';

abstract class GenerateEvent extends Equatable {
  const GenerateEvent();

  @override
  List<Object?> get props => [];
}

class GenerateCharacterCard extends GenerateEvent {
  final String characterInfo;
  final String model;
  final double temperature;
  final int maxTokens;
  final int nsfwLevel;

  const GenerateCharacterCard({
    required this.characterInfo,
    required this.model,
    required this.temperature,
    required this.maxTokens,
    required this.nsfwLevel,
  });

  @override
  List<Object?> get props => [characterInfo, model, temperature, maxTokens, nsfwLevel];
}

class UpdateCharacterCard extends GenerateEvent {
  final CharacterCard card;

  const UpdateCharacterCard(this.card);

  @override
  List<Object?> get props => [card];
}

class SaveCharacterCard extends GenerateEvent {
  const SaveCharacterCard();
}

class ClearGeneratedCard extends GenerateEvent {
  const ClearGeneratedCard();
}
