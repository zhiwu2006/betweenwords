import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

class StudyState {
  final String unitName;
  final String categoryName;
  final String subcategoryName;
  final Set<String> reviewWords;

  StudyState({
    required this.unitName,
    required this.categoryName,
    required this.subcategoryName,
    required this.reviewWords,
  });

  Map<String, dynamic> toJson() => {
    'unitName': unitName,
    'categoryName': categoryName,
    'subcategoryName': subcategoryName,
    'reviewWords': reviewWords.toList(),
  };

  factory StudyState.fromJson(Map<String, dynamic> json) => StudyState(
    unitName: json['unitName'] as String,
    categoryName: json['categoryName'] as String,
    subcategoryName: json['subcategoryName'] as String,
    reviewWords: Set<String>.from(json['reviewWords'] as List),
  );
}

class StudyStateProvider with ChangeNotifier {
  late SharedPreferences _prefs;
  StudyState? _currentState;
  static const String _stateKey = 'studyState';
  static const String _deletedWordsKey = 'deletedWords';
  Set<String> _deletedWords = {};

  StudyState? get currentState => _currentState;
  Set<String> get reviewWords => _currentState?.reviewWords ?? {};
  Set<String> get deletedWords => _deletedWords;

  StudyStateProvider() {
    _loadState();
  }

  Future<void> _loadState() async {
    _prefs = await SharedPreferences.getInstance();
    final String? stateJson = _prefs.getString(_stateKey);
    final String? deletedWordsJson = _prefs.getString(_deletedWordsKey);
    
    if (stateJson != null) {
      _currentState = StudyState.fromJson(json.decode(stateJson));
    }
    
    if (deletedWordsJson != null) {
      _deletedWords = Set<String>.from(json.decode(deletedWordsJson));
    }
    
    notifyListeners();
  }

  Future<void> deleteWord(String word) async {
    _deletedWords.add(word);
    if (_currentState?.reviewWords.contains(word) ?? false) {
      _currentState!.reviewWords.remove(word);
    }
    await _saveDeletedWords();
    notifyListeners();
  }

  Future<void> _saveDeletedWords() async {
    await _prefs.setString(_deletedWordsKey, json.encode(_deletedWords.toList()));
  }

  bool isWordDeleted(String word) {
    return _deletedWords.contains(word);
  }

  Future<void> updateState({
    required String unitName,
    required String categoryName,
    required String subcategoryName,
  }) async {
    _currentState = StudyState(
      unitName: unitName,
      categoryName: categoryName,
      subcategoryName: subcategoryName,
      reviewWords: _currentState?.reviewWords ?? {},
    );
    await _saveState();
  }

  Future<void> toggleReviewWord(String word) async {
    if (_currentState == null) return;

    if (_currentState!.reviewWords.contains(word)) {
      _currentState!.reviewWords.remove(word);
    } else {
      _currentState!.reviewWords.add(word);
    }
    await _saveState();
    notifyListeners();
  }

  Future<void> _saveState() async {
    if (_currentState != null) {
      await _prefs.setString(_stateKey, json.encode(_currentState!.toJson()));
    }
  }

  bool needsReview(String word) {
    return _currentState?.reviewWords.contains(word) ?? false;
  }
} 