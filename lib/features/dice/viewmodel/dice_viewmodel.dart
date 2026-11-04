import 'dart:math';
import 'package:flutter/material.dart';

class RollResult {
  final int diceType;
  final List<int> rolls;
  final int modifier;
  final int total;
  final DateTime timestamp;

  RollResult({
    required this.diceType,
    required this.rolls,
    required this.modifier,
    required this.total,
    required this.timestamp,
  });
}

class DiceRollViewModel extends ChangeNotifier {
  final Random _random = Random();

  int _selectedDice = 20; // d20 por padrão
  int _quantity = 1;
  int _modifier = 0;
  RollResult? _lastResult;
  final List<RollResult> _history = [];

  int get selectedDice => _selectedDice;
  int get quantity => _quantity;
  int get modifier => _modifier;
  RollResult? get lastResult => _lastResult;
  List<RollResult> get history => List.unmodifiable(_history);

  void selectDice(int dice) {
    _selectedDice = dice;
    notifyListeners();
  }

  void updateQuantity(int delta) {
    if (_quantity + delta >= 1 && _quantity + delta <= 20) {
      _quantity += delta;
      notifyListeners();
    }
  }

  void updateModifier(int delta) {
    _modifier += delta;
    notifyListeners();
  }

  void rollDice() {
    List<int> rolls = List.generate(
      _quantity,
      (_) => _random.nextInt(_selectedDice) + 1,
    );

    int total = rolls.reduce((a, b) => a + b) + _modifier;

    _lastResult = RollResult(
      diceType: _selectedDice,
      rolls: rolls,
      modifier: _modifier,
      total: total,
      timestamp: DateTime.now(),
    );

    _history.insert(0, _lastResult!);
    notifyListeners();
  }
}