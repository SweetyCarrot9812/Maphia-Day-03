import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/card_model.dart';
import '../models/vocabulary_model.dart';

class FirebaseService {
  static FirebaseService? _instance;
  static FirebaseService get instance => _instance ??= FirebaseService._();
  FirebaseService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Collections
  CollectionReference get _cardsCollection => _firestore.collection('lingumo_cards');
  CollectionReference get _vocabulariesCollection => _firestore.collection('lingumo_vocabularies');

  // Cards CRUD operations
  Future<String> addCard(CardModel card) async {
    try {
      final docRef = await _cardsCollection.add(card.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add card: $e');
    }
  }

  Future<void> updateCard(String id, CardModel card) async {
    try {
      await _cardsCollection.doc(id).update(card.toFirestore());
    } catch (e) {
      throw Exception('Failed to update card: $e');
    }
  }

  Future<void> deleteCard(String id) async {
    try {
      await _cardsCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete card: $e');
    }
  }

  Future<List<CardModel>> getAllCards({String? vocabularyId}) async {
    try {
      Query query = _cardsCollection.orderBy('createdAt', descending: true);
      
      if (vocabularyId != null) {
        query = query.where('vocabularyId', isEqualTo: vocabularyId);
      }
      
      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CardModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get cards: $e');
    }
  }

  Future<void> deleteAllCards({String? vocabularyId}) async {
    try {
      Query query = _cardsCollection;
      
      if (vocabularyId != null) {
        query = query.where('vocabularyId', isEqualTo: vocabularyId);
      }
      
      final snapshot = await query.get();
      final batch = _firestore.batch();
      
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to delete all cards: $e');
    }
  }

  // Vocabularies CRUD operations
  Future<String> addVocabulary(VocabularyModel vocabulary) async {
    try {
      final docRef = await _vocabulariesCollection.add(vocabulary.toFirestore());
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to add vocabulary: $e');
    }
  }

  Future<void> updateVocabulary(String id, VocabularyModel vocabulary) async {
    try {
      await _vocabulariesCollection.doc(id).update(vocabulary.toFirestore());
    } catch (e) {
      throw Exception('Failed to update vocabulary: $e');
    }
  }

  Future<void> deleteVocabulary(String id) async {
    try {
      // Delete all cards in this vocabulary first
      await deleteAllCards(vocabularyId: id);
      // Then delete the vocabulary
      await _vocabulariesCollection.doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete vocabulary: $e');
    }
  }

  Future<List<VocabularyModel>> getAllVocabularies() async {
    try {
      final snapshot = await _vocabulariesCollection
          .orderBy('createdAt', descending: false)
          .get();
      return snapshot.docs
          .map((doc) => VocabularyModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id))
          .toList();
    } catch (e) {
      throw Exception('Failed to get vocabularies: $e');
    }
  }

  // Update card count for vocabulary
  Future<void> updateVocabularyCardCount(String vocabularyId, int count) async {
    try {
      await _vocabulariesCollection.doc(vocabularyId).update({
        'cardCount': count,
        'updatedAt': DateTime.now(),
      });
    } catch (e) {
      throw Exception('Failed to update vocabulary card count: $e');
    }
  }

  // Batch operations
  Future<void> importCards(List<CardModel> cards) async {
    try {
      final batch = _firestore.batch();
      
      for (final card in cards) {
        final docRef = _cardsCollection.doc();
        batch.set(docRef, card.toFirestore());
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to import cards: $e');
    }
  }

  // Real-time streams
  Stream<List<CardModel>> getCardsStream({String? vocabularyId}) {
    try {
      Query query = _cardsCollection.orderBy('createdAt', descending: true);
      
      if (vocabularyId != null) {
        query = query.where('vocabularyId', isEqualTo: vocabularyId);
      }
      
      return query.snapshots().map((snapshot) => 
          snapshot.docs.map((doc) => 
              CardModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)
          ).toList()
      );
    } catch (e) {
      throw Exception('Failed to get cards stream: $e');
    }
  }

  Stream<List<VocabularyModel>> getVocabulariesStream() {
    try {
      return _vocabulariesCollection
          .orderBy('createdAt', descending: false)
          .snapshots()
          .map((snapshot) => 
              snapshot.docs.map((doc) => 
                  VocabularyModel.fromFirestore(doc.data() as Map<String, dynamic>, doc.id)
              ).toList()
          );
    } catch (e) {
      throw Exception('Failed to get vocabularies stream: $e');
    }
  }
}