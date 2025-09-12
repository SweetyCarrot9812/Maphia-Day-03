import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/card_model.dart';
import '../models/vocabulary_model.dart';
import '../services/firebase_service.dart';

// Firebase service provider
final firebaseServiceProvider = Provider<FirebaseService>((ref) {
  return FirebaseService.instance;
});

// Current vocabulary provider
final currentVocabularyProvider = StateProvider<VocabularyModel?>((ref) => null);

// Cards stream provider
final cardsStreamProvider = StreamProvider.family<List<CardModel>, String?>((ref, vocabularyId) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getCardsStream(vocabularyId: vocabularyId);
});

// Vocabularies stream provider
final vocabulariesStreamProvider = StreamProvider<List<VocabularyModel>>((ref) {
  final firebaseService = ref.watch(firebaseServiceProvider);
  return firebaseService.getVocabulariesStream();
});

// Card form providers
final frontInputProvider = StateProvider<String>((ref) => '');
final backInputProvider = StateProvider<String>((ref) => '');
final noteInputProvider = StateProvider<String>((ref) => '');

// Card operations provider
final cardOperationsProvider = Provider<CardOperations>((ref) {
  return CardOperations(ref);
});

class CardOperations {
  final Ref _ref;

  CardOperations(this._ref);

  FirebaseService get _firebaseService => _ref.read(firebaseServiceProvider);

  Future<void> addCard({
    required String front,
    required String back,
    String note = '',
    String? vocabularyId,
  }) async {
    if (front.trim().isEmpty || back.trim().isEmpty) {
      throw Exception('Front and back text cannot be empty');
    }

    final card = CardModel.create(
      front: front.trim(),
      back: back.trim(),
      note: note.trim(),
      vocabularyId: vocabularyId ?? 'default',
    );

    await _firebaseService.addCard(card);

    // Clear form inputs
    _ref.read(frontInputProvider.notifier).state = '';
    _ref.read(backInputProvider.notifier).state = '';
    _ref.read(noteInputProvider.notifier).state = '';
  }

  Future<void> updateCard(String id, CardModel card) async {
    await _firebaseService.updateCard(id, card);
  }

  Future<void> deleteCard(String id) async {
    await _firebaseService.deleteCard(id);
  }

  Future<void> deleteAllCards({String? vocabularyId}) async {
    await _firebaseService.deleteAllCards(vocabularyId: vocabularyId);
  }

  Future<void> importCards(List<CardModel> cards) async {
    await _firebaseService.importCards(cards);
  }

  void clearForm() {
    _ref.read(frontInputProvider.notifier).state = '';
    _ref.read(backInputProvider.notifier).state = '';
    _ref.read(noteInputProvider.notifier).state = '';
  }
}

// Vocabulary operations provider
final vocabularyOperationsProvider = Provider<VocabularyOperations>((ref) {
  return VocabularyOperations(ref);
});

class VocabularyOperations {
  final Ref _ref;

  VocabularyOperations(this._ref);

  FirebaseService get _firebaseService => _ref.read(firebaseServiceProvider);

  Future<String> addVocabulary({
    required String name,
    String description = '',
  }) async {
    if (name.trim().isEmpty) {
      throw Exception('Vocabulary name cannot be empty');
    }

    final vocabulary = VocabularyModel.create(
      name: name.trim(),
      description: description.trim(),
    );

    return await _firebaseService.addVocabulary(vocabulary);
  }

  Future<void> updateVocabulary(String id, VocabularyModel vocabulary) async {
    await _firebaseService.updateVocabulary(id, vocabulary);
  }

  Future<void> deleteVocabulary(String id) async {
    await _firebaseService.deleteVocabulary(id);
  }

  Future<void> updateVocabularyCardCount(String vocabularyId, int count) async {
    await _firebaseService.updateVocabularyCardCount(vocabularyId, count);
  }
}

// Loading states
final isLoadingProvider = StateProvider<bool>((ref) => false);
final errorMessageProvider = StateProvider<String?>((ref) => null);

// UI state providers
final selectedCardProvider = StateProvider<CardModel?>((ref) => null);
final isEditingCardProvider = StateProvider<bool>((ref) => false);

// Search and filter providers
final searchQueryProvider = StateProvider<String>((ref) => '');
final filteredCardsProvider = Provider<AsyncValue<List<CardModel>>>((ref) {
  final cardsAsync = ref.watch(cardsStreamProvider(
    ref.watch(currentVocabularyProvider)?.id
  ));
  final searchQuery = ref.watch(searchQueryProvider);

  return cardsAsync.when(
    data: (cards) {
      if (searchQuery.isEmpty) {
        return AsyncData(cards);
      }
      
      final filtered = cards.where((card) {
        final query = searchQuery.toLowerCase();
        return card.front.toLowerCase().contains(query) ||
               card.back.toLowerCase().contains(query) ||
               card.note.toLowerCase().contains(query);
      }).toList();
      
      return AsyncData(filtered);
    },
    loading: () => const AsyncLoading(),
    error: (error, stack) => AsyncError(error, stack),
  );
});