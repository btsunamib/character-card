import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:uuid/uuid.dart';
import '../../../data/models/character_card_model.dart';
import '../../../domain/repositories/repositories.dart';
import 'generate_event.dart';
import 'generate_state.dart';

class GenerateBloc extends Bloc<GenerateEvent, GenerateState> {
  final CharacterRepository characterRepository;
  final Uuid _uuid = const Uuid();

  GenerateBloc({required this.characterRepository}) : super(const GenerateInitial()) {
    on<GenerateCharacterCard>(_onGenerateCharacterCard);
    on<UpdateCharacterCard>(_onUpdateCharacterCard);
    on<SaveCharacterCard>(_onSaveCharacterCard);
    on<ClearGeneratedCard>(_onClearGeneratedCard);
  }

  Future<void> _onGenerateCharacterCard(
    GenerateCharacterCard event,
    Emitter<GenerateState> emit,
  ) async {
    emit(const GenerateLoading(message: '正在生成角色卡...'));

    final result = await characterRepository.generateCharacterCard(
      characterInfo: event.characterInfo,
      model: event.model,
      temperature: event.temperature,
      maxTokens: event.maxTokens,
      nsfwLevel: event.nsfwLevel,
    );

    result.fold(
      (failure) {
        final previousCard = state is GenerateSuccess
            ? (state as GenerateSuccess).card
            : null;
        emit(GenerateError(
          message: failure.message,
          previousCard: previousCard,
        ));
      },
      (card) {
        final cardWithId = card.copyWith(
          id: card.id.isEmpty ? _uuid.v4() : card.id,
          createdAt: DateTime.now(),
        );
        emit(GenerateSuccess(card: cardWithId));
      },
    );
  }

  Future<void> _onUpdateCharacterCard(
    UpdateCharacterCard event,
    Emitter<GenerateState> emit,
  ) async {
    if (state is GenerateSuccess) {
      final currentState = state as GenerateSuccess;
      emit(currentState.copyWith(card: event.card, isSaved: false));
    } else {
      emit(GenerateSuccess(card: event.card));
    }
  }

  Future<void> _onSaveCharacterCard(
    SaveCharacterCard event,
    Emitter<GenerateState> emit,
  ) async {
    if (state is GenerateSuccess) {
      final currentState = state as GenerateSuccess;
      final cardToSave = currentState.card.copyWith(
        id: currentState.card.id.isEmpty ? _uuid.v4() : currentState.card.id,
        createdAt: DateTime.now(),
      );

      final result = await characterRepository.saveToHistory(cardToSave);

      result.fold(
        (failure) => emit(GenerateError(
          message: failure.message,
          previousCard: currentState.card,
        )),
        (_) => emit(currentState.copyWith(card: cardToSave, isSaved: true)),
      );
    }
  }

  Future<void> _onClearGeneratedCard(
    ClearGeneratedCard event,
    Emitter<GenerateState> emit,
  ) async {
    emit(const GenerateInitial());
  }
}
