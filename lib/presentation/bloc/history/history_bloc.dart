import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../domain/repositories/repositories.dart';
import 'history_event.dart';
import 'history_state.dart';

class HistoryBloc extends Bloc<HistoryEvent, HistoryState> {
  final CharacterRepository characterRepository;

  HistoryBloc({required this.characterRepository}) : super(const HistoryInitial()) {
    on<LoadHistory>(_onLoadHistory);
    on<DeleteHistoryItem>(_onDeleteHistoryItem);
    on<ClearAllHistory>(_onClearAllHistory);
  }

  Future<void> _onLoadHistory(LoadHistory event, Emitter<HistoryState> emit) async {
    emit(const HistoryLoading());

    final result = await characterRepository.getHistory();
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (cards) => emit(HistoryLoaded(cards)),
    );
  }

  Future<void> _onDeleteHistoryItem(
    DeleteHistoryItem event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await characterRepository.deleteFromHistory(event.id);
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (_) => add(const LoadHistory()),
    );
  }

  Future<void> _onClearAllHistory(
    ClearAllHistory event,
    Emitter<HistoryState> emit,
  ) async {
    final result = await characterRepository.clearHistory();
    result.fold(
      (failure) => emit(HistoryError(failure.message)),
      (_) => emit(const HistoryLoaded([])),
    );
  }
}
