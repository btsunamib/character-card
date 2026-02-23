import 'package:equatable/equatable.dart';
import '../../../data/models/character_card_model.dart';

abstract class GenerateState extends Equatable {
  const GenerateState();

  @override
  List<Object?> get props => [];
}

class GenerateInitial extends GenerateState {
  const GenerateInitial();
}

class GenerateLoading extends GenerateState {
  final String? message;

  const GenerateLoading({this.message});

  @override
  List<Object?> get props => [message];
}

class GenerateSuccess extends GenerateState {
  final CharacterCard card;
  final bool isSaved;

  const GenerateSuccess({
    required this.card,
    this.isSaved = false,
  });

  GenerateSuccess copyWith({
    CharacterCard? card,
    bool? isSaved,
  }) {
    return GenerateSuccess(
      card: card ?? this.card,
      isSaved: isSaved ?? this.isSaved,
    );
  }

  @override
  List<Object?> get props => [card, isSaved];
}

class GenerateError extends GenerateState {
  final String message;
  final CharacterCard? previousCard;

  const GenerateError({
    required this.message,
    this.previousCard,
  });

  @override
  List<Object?> get props => [message, previousCard];
}
